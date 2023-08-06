# filter_plugins/routeros_filters.py

# 36    chain=dstnat action=dst-nat to-addresses=192.168.69.121 to-ports=33121 protocol=tcp in-interface=ether1 dst-port=33121
# 3    chain=dstnat action=dst-nat to-addresses=192.168.69.121 to-ports=33121 protocol=tcp dst-address=27.131.160.106 dst-port=33121
# 34    chain=dstnat action=dst-nat to-addresses=192.168.69.111 to-ports=33111 protocol=tcp in-interface=ether1 dst-port=33111
# 1    chain=dstnat action=dst-nat to-addresses=192.168.69.111 to-ports=33111 protocol=tcp dst-address=27.131.160.106 dst-port=33111
#
# interface --> address=public-ip

def generate_routeros_command(item, public_ip):
    to_addresses, to_ports = item['to_host'].split(':')
    routeros_command = (
        f"/ip firewall nat add chain=dstnat action=dst-nat "
        f"to-addresses={to_addresses} to-ports={to_ports} "
        f"protocol={item['protocol']} dst-address={public_ip} "
        f"dst-port={item['from_port']}"
    )
    return routeros_command

class FilterModule(object):
    def filters(self):
        return {
            'generate_routeros_command': generate_routeros_command,
        }
