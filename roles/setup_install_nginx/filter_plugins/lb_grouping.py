# lb_grouping.py

def lb_grouping(hostvars, hosts):
    """
    This filter plugin will sort and group hosts by `default_public_dns_lb`.
    
    Args:
        hostvars (dict): Host variables provided by Ansible.
        hosts (list): List of hostnames.
        
    Returns:
        dict: A dictionary where keys are the first part of `default_public_dns_lb`
        domains, and values are lists of hostnames associated with that domain.
    """
    if not isinstance(hostvars, dict):
        raise ValueError("hostvars must be a dictionary")

    if not isinstance(hosts, list):
        raise ValueError("hosts must be a list")

    result = {}

    for host in hosts:
        if not isinstance(host, str):
            raise ValueError(f"Invalid host name: {host}")

        lb_domain = hostvars.get(host, {}).get('default_public_dns_lb')

        if lb_domain:
            if not isinstance(lb_domain, str):
                raise ValueError(
                    f"Invalid LB domain for host {host}: {lb_domain}")

            key = lb_domain.split('.')[0]
            result.setdefault(key, []).append(host)

    return result


class FilterModule(object):
    """
    Custom Ansible core filter module
    """

    def filters(self):
        return {
            'lb_grouping': lb_grouping
        }
