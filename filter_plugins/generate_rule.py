def generate_rule(item, rule_type, public_ip=None):
    if rule_type == "nat":
        to_addresses, to_ports = item["to_host"].split(":")
        return (
            f"/ip firewall nat add chain=dstnat action=dst-nat "
            f"to-addresses={to_addresses} to-ports={to_ports} "
            f"protocol={item['protocol']} dst-address={public_ip} "
            f"dst-port={item['from_port']}"
        )
    elif rule_type == "filter":
        return (
            f"/ip firewall filter add chain=forward protocol={item['protocol']} "
            f"dst-port={item['from_port']} action=accept place-before=0"
        )


class FilterModule(object):
    def filters(self):
        return {
            "generate_rule": generate_rule
        }
