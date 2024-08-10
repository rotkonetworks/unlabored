#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Globals
readonly SCRIPT_NAME="${0##*/}"
readonly INVENTORY_FILE="inventory"

# Error codes
readonly E_ARGS=1
readonly E_INVENTORY=2
readonly E_EXTRACTION=3
readonly E_CATEGORIZATION=4
readonly E_PIN=5

# Log levels
readonly LOG_ERROR="ERROR"
readonly LOG_WARN="WARN"
readonly LOG_INFO="INFO"
readonly LOG_DEBUG="DEBUG"

log() {
	local level="$1"
	shift
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] [${level}] $*" >&2
}

die() {
	log "${LOG_ERROR}" "$@"
	exit "${E_ARGS}"
}

safe_source() {
	[[ -r "$1" ]] || die "Cannot read file: $1"
	# shellcheck source=/dev/null
	source "$1"
}

validate_inventory() {
	[[ -r "${INVENTORY_FILE}" ]] || die "Cannot read inventory file: ${INVENTORY_FILE}"
	grep -qE '^\[(polkadot|cumulus)\]$' "${INVENTORY_FILE}" || die "Invalid inventory file format"
}

extract_hosts() {
	local group="$1"
	local result
	result=$(awk -v group="[$group]" '
        $0 == group {f=1; next}
        /^\[/ {f=0}
        f && NF && !/^[[:space:]]*#/ {gsub(/[[:space:]]/, ""); print}
    ' "${INVENTORY_FILE}")
	[[ -n "${result}" ]] || die "No hosts found for group: ${group}"
	echo "${result}"
}

categorize_hosts() {
	local -n hosts=$1
	local -n primary=$2
	local -n secondary=$3

	for host in "${hosts[@]}"; do
		if [[ ! "${host}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
			log "${LOG_WARN}" "Invalid hostname: ${host}"
			continue
		fi
		local last_digit
		last_digit=$(echo "${host}" | grep -oE '[0-9]$' || echo "")
		if [[ -n "${last_digit}" ]]; then
			if ((last_digit % 2 == 1)); then
				primary+=("${host}")
			else
				secondary+=("${host}")
			fi
		else
			log "${LOG_WARN}" "No digit found in hostname: ${host}"
			secondary+=("${host}")
		fi
	done
}

pin_host() {
	local host="$1"
	log "${LOG_INFO}" "Pinning ${host}..."
	if ! inv pin "${host}"; then
		log "${LOG_ERROR}" "Failed to pin ${host}"
		return 1
	fi
}

pin_hosts_concurrently() {
	local -n hosts=$1
	local pids=()
	for host in "${hosts[@]}"; do
		pin_host "${host}" &
		pids+=($!)
	done
	for pid in "${pids[@]}"; do
		if ! wait "${pid}"; then
			log "${LOG_ERROR}" "A host pin operation failed"
			return 1
		fi
	done
}

main() {
	if [[ "$#" -ne 1 ]]; then
		die "Usage: ${SCRIPT_NAME} <list_number>
1: polkadot primary (odd last digit)
2: polkadot secondary (even last digit)
3: cumulus primary (odd last digit)
4: cumulus secondary (even last digit)"
	fi

	local list_number="$1"
	validate_inventory

	local polkadot_hosts cumulus_hosts
	readarray -t polkadot_hosts < <(extract_hosts "polkadot")
	readarray -t cumulus_hosts < <(extract_hosts "cumulus")

	local polkadot_primary=() polkadot_secondary=() cumulus_primary=() cumulus_secondary=()
	categorize_hosts polkadot_hosts polkadot_primary polkadot_secondary
	categorize_hosts cumulus_hosts cumulus_primary cumulus_secondary

	case "${list_number}" in
	1)
		log "${LOG_INFO}" "Pinning Polkadot primary hosts (odd last digit):"
		printf '%s\n' "${polkadot_primary[@]}"
		pin_hosts_concurrently polkadot_primary || die "Failed to pin some Polkadot primary hosts"
		;;
	2)
		log "${LOG_INFO}" "Pinning Polkadot secondary hosts (even last digit):"
		printf '%s\n' "${polkadot_secondary[@]}"
		pin_hosts_concurrently polkadot_secondary || die "Failed to pin some Polkadot secondary hosts"
		;;
	3)
		log "${LOG_INFO}" "Pinning Cumulus primary hosts (odd last digit):"
		printf '%s\n' "${cumulus_primary[@]}"
		pin_hosts_concurrently cumulus_primary || die "Failed to pin some Cumulus primary hosts"
		;;
	4)
		log "${LOG_INFO}" "Pinning Cumulus secondary hosts (even last digit):"
		printf '%s\n' "${cumulus_secondary[@]}"
		pin_hosts_concurrently cumulus_secondary || die "Failed to pin some Cumulus secondary hosts"
		;;
	*)
		die "Invalid list number: ${list_number}"
		;;
	esac

	log "${LOG_INFO}" "Pin operation completed successfully"
}

main "$@"
