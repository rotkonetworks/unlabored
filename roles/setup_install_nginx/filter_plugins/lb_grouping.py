# lb_grouping.py
def lb_grouping(hostvars, hosts):
    """
    This filter plugin will sort and group hosts by `default_public_dns_lb`.
    """
    result = {}

    for host in hosts:
        lb_domain = hostvars[host].get('default_public_dns_lb', None)
        if lb_domain:
            key = lb_domain.split('.')[0]
            if key in result:
                result[key].append(host)
            else:
                result[key] = [host]
    return result


class FilterModule(object):
    """
    Custom Ansible core filter module
    """

    def filters(self):
        return {
            'lb_grouping': lb_grouping
        }
