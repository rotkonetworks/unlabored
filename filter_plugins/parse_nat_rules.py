# filter_plugins/parse_nat_rules.py
def parse_line(line):
    if ';;;' in line:  # Handle comments
        return {'comment': line.split(';;;')[1].strip()}

    fields = line.split()
    rule_type = 'dstnat' if 'chain=dstnat' in line else 'srcnat'

    if 'chain={}'.format(rule_type) not in line:
        return None

    # Handle rule ID (the first field) and fields with key=value format
    nat_rule = {field.split('=')[0]: field.split('=')[1]
                for field in fields[1:] if '=' in field}

    # Handle fields without value
    for field in fields[1:]:
        if '=' not in field:
            nat_rule[field] = True

    nat_rule['id'] = fields[0]
    nat_rule['type'] = rule_type
    return nat_rule


def parse_nat_rules(output):
    lines = output.split('\n')
    nat_rules = filter(None, map(parse_line, lines))
    return list(nat_rules)


class FilterModule(object):
    def filters(self):
        return {
            'parse_nat_rules': parse_nat_rules,
        }