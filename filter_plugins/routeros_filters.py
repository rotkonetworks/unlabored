# filter_plugins/routeros_filters.py

def generate_routeros_command(item, in_interface):
    return f"/ip firewall nat add chain=dstnat protocol={item['protocol']} in-interface={in_interface} dst-port={item['from_port']} action=dst-nat to-addresses={item['to_host'].split(':')[0]} to-ports={item['to_host'].split(':')[1]}"

class FilterModule(object):
    def filters(self):
        return {
            'generate_routeros_command': generate_routeros_command,
        }
