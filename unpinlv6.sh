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
readonly E_UNPIN=5

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

validate_inventory() {
  [[ -r "${INVENTORY_FILE}" ]] || die "Cannot read inventory file: ${INVENTORY_FILE}"
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

extract_lv6_groups() {
  # Extract all groups under [lv6:children]
  awk '
    /^\[lv6:children\]/ {f=1; next}
    /^\[/ {f=0}
    f && NF && !/^[[:space:]]*#/ {gsub(/[[:space:]]/, ""); print}
  ' "${INVENTORY_FILE}"
}

unpin_host() {
  local host="$1"
  log "${LOG_INFO}" "Unpinning ${host}..."
  if ! inv unpin "${host}"; then
    log "${LOG_ERROR}" "Failed to unpin ${host}"
    return 1
  fi
}

unpin_hosts_concurrently() {
  local -n hosts=$1
  local pids=()
  for host in "${hosts[@]}"; do
    unpin_host "${host}" &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do
    if ! wait "${pid}"; then
      log "${LOG_ERROR}" "A host unpin operation failed"
      return 1
    fi
  done
}

unpin_all_lv6() {
  log "${LOG_INFO}" "Unpinning ALL LV6 nodes..."

  local lv6_groups
  readarray -t lv6_groups < <(extract_lv6_groups)

  if [[ ${#lv6_groups[@]} -eq 0 ]]; then
    die "No LV6 groups found in inventory"
  fi

  local all_lv6_hosts=()

  for group in "${lv6_groups[@]}"; do
    log "${LOG_INFO}" "Processing group: ${group}"
    local group_hosts
    readarray -t group_hosts < <(extract_hosts "${group}" 2>/dev/null || echo "")
    if [[ ${#group_hosts[@]} -gt 0 ]]; then
      all_lv6_hosts+=("${group_hosts[@]}")
      log "${LOG_INFO}" "Found ${#group_hosts[@]} hosts in ${group}"
    fi
  done

  if [[ ${#all_lv6_hosts[@]} -eq 0 ]]; then
    die "No hosts found in any LV6 group"
  fi

  log "${LOG_INFO}" "Total LV6 hosts to unpin: ${#all_lv6_hosts[@]}"
  printf '%s\n' "${all_lv6_hosts[@]}"

  unpin_hosts_concurrently all_lv6_hosts || die "Failed to unpin some LV6 hosts"
}

unpin_specific_lv6_group() {
  local group_index="$1"

  local lv6_groups
  readarray -t lv6_groups < <(extract_lv6_groups)

  if [[ ${#lv6_groups[@]} -eq 0 ]]; then
    die "No LV6 groups found in inventory"
  fi

  # Adjust index (user provides 2-based, we need 0-based)
  local array_index=$((group_index - 2))

  if [[ ${array_index} -lt 0 || ${array_index} -ge ${#lv6_groups[@]} ]]; then
    log "${LOG_ERROR}" "Invalid group number. Available LV6 groups:"
    show_usage
    exit "${E_ARGS}"
  fi

  local selected_group="${lv6_groups[${array_index}]}"
  log "${LOG_INFO}" "Unpinning hosts from LV6 group: ${selected_group}"

  local group_hosts
  readarray -t group_hosts < <(extract_hosts "${selected_group}" 2>/dev/null || echo "")

  if [[ ${#group_hosts[@]} -eq 0 ]]; then
    die "No hosts found in group: ${selected_group}"
  fi

  log "${LOG_INFO}" "Hosts to unpin from ${selected_group}:"
  printf '%s\n' "${group_hosts[@]}"

  unpin_hosts_concurrently group_hosts || die "Failed to unpin some hosts from ${selected_group}"
}

show_usage() {
  local lv6_groups
  readarray -t lv6_groups < <(extract_lv6_groups)

  echo "Usage: ${SCRIPT_NAME} <number>"
  echo ""
  echo "Options:"
  echo "  1: Unpin ALL LV6 nodes"

  if [[ ${#lv6_groups[@]} -gt 0 ]]; then
    echo ""
    echo "Individual LV6 groups:"
    local i=2
    for group in "${lv6_groups[@]}"; do
      local count
      count=$(extract_hosts "${group}" 2>/dev/null | wc -l || echo "0")
      printf "  %2d: %-20s (%d hosts)\n" "$i" "${group}" "${count}"
      ((i++))
    done
  fi
}

main() {
  if [[ "$#" -ne 1 ]]; then
    show_usage
    exit "${E_ARGS}"
  fi

  local option="$1"
  validate_inventory

  # Check if it's a valid number
  if ! [[ "${option}" =~ ^[0-9]+$ ]]; then
    show_usage
    die "Invalid option: ${option} (must be a number)"
  fi

  case "${option}" in
  1)
    unpin_all_lv6
    ;;
  *)
    unpin_specific_lv6_group "${option}"
    ;;
  esac

  log "${LOG_INFO}" "Unpin operation completed successfully"
}

main "$@"
