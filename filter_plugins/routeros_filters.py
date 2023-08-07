def generate_routeros_command(item, public_ip):
    to_addresses, to_ports = item["to_host"].split(":")
    routeros_command = (
        f"/ip firewall nat add chain=dstnat action=dst-nat " f"to-addresses={to_addresses} to-ports={to_ports} " f"protocol={item['protocol']} dst-address={public_ip} " f"dst-port={item['from_port']}"
    )
    return routeros_command


class FilterModule(object):
    def filters(self):
        return {
            "generate_routeros_command": generate_routeros_command,
        }
