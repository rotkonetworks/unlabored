import hashlib
import binascii


def generate_mac(hostname):
    md5 = hashlib.md5()
    md5.update(hostname.encode('utf-8'))
    digest = md5.digest()
    mac = binascii.hexlify(digest)[:12]
    mac = ':'.join([mac[i:i+2] for i in range(0, len(mac), 2)])
    mac = '69' + mac[2:]  # modify first octet to make it unicast
    return mac.decode('utf-8')


class FilterModule(object):
    def filters(self):
        return {
            'generate_mac': generate_mac
        }
