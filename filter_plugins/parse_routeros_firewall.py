# filter_plugins/parse_routeros_firewall.py

def extract_comment(line):
    """Extracts comment if present."""
    if ";;;" not in line:
        return None
    return {"comment": line.split(";;;")[1].strip()}


def determine_rule_type(line):
    """Determines the rule type based on the chain."""
    if "chain=dstnat" in line:
        return "dstnat"
    if "chain=forward" in line:
        return "forward"
    return None


def parse_rule_fields(fields):
    """Parses fields into a rule dictionary."""
    rule = {field.split("=")[0]: field.split("=")[1]
            for field in fields if "=" in field}
    for field in fields:
        if "=" not in field:
            rule[field] = True
    return rule


def parse_line(line):
    comment = extract_comment(line)
    if comment:
        return comment

    rule_type = determine_rule_type(line)
    if not rule_type:
        return None

    fields = line.split()
    rule = parse_rule_fields(fields[1:])
    rule["id"] = fields[0]
    rule["type"] = rule_type

    return rule


def parse_firewall_rules(output):
    lines = output.split("\n")
    return [rule for rule in map(parse_line, lines) if rule]


def rule_matches_port_forward(rule, port_forward):
    to_addresses, to_ports = port_forward["to_host"].split(":")
    return rule.get("to-addresses") == to_addresses and rule.get("to-ports") == to_ports


def rule_matches_filter_details(rule, filter_details):
    dst_port = filter_details.get('from_port')
    protocol = filter_details.get('protocol')
    return rule.get("dst-port") == dst_port and rule.get("protocol") == protocol


def port_forward_exists(existing_rules, port_forward):
    return any(rule_matches_port_forward(rule, port_forward) for rule in existing_rules)


def firewall_filter_exists(existing_rules, filter_details):
    return any(rule_matches_filter_details(rule, filter_details) for rule in existing_rules)


class FilterModule(object):
    def filters(self):
        return {
            "parse_firewall_rules": parse_firewall_rules,
            "port_forward_exists": port_forward_exists,
            "firewall_filter_exists": firewall_filter_exists,
        }
