# filter_plugins/generate_routeros_rules.py
def generate_rule(item, rule_type, public_ip=None):
    """Generate a rule based on the type (NAT or filter)."""
    rule_generators = {
        "nat": generate_nat_rule,
        "filter": generate_filter_rule
    }

    if rule_type == "nat":
        return rule_generators[rule_type](item, public_ip)
    else:
        return rule_generators[rule_type](item)


def generate_nat_rule(item, public_ip):
    """Generate a NAT rule string for RouterOS."""
    to_addresses, to_ports = item["to_host"].split(":")
    return (
        f"/ip firewall nat add chain=dstnat action=dst-nat "
        f"to-addresses={to_addresses} to-ports={to_ports} "
        f"protocol={item['protocol']} dst-address={public_ip} "
        f"dst-port={item['from_port']}"
    )


def generate_filter_rule(item):
    """Generate a filter rule string for RouterOS."""
    return (
        f"/ip firewall filter add chain=forward protocol={item['protocol']} "
        f"dst-port={item['from_port']} action=accept place-before=0"
    )


class FilterModule(object):
    def filters(self):
        return {"generate_rule": generate_rule}
