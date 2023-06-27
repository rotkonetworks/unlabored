#!/usr/bin/env python3

import re
import json
from collections import ChainMap


token_list_re = re.compile(r"^│\s(?P<tokenid>\w+)\s+│\s+(?P<comment>.*)\s│\s+(?P<expire>\d+)\s+│\s(?P<privsep>\d)\s+│$")
group_data_re = re.compile(r"^│\s(?P<groupid>\w+)\s+│\s+(?P<comment>.*)\s│\s+(?P<users>.*?)\s+│$")
roles_re = re.compile(r"^│\s(?P<roleid>\w+)\s+│\s+(?P<privs>.*?)\s+│\s+(?P<special>\d+)\s+│$")
token_re = re.compile(r"^│\s(full-tokenid\s+│\s(?P<fulltokenid>.*?)|(info\s+│\s(?P<info>.*?))|(value\s+│\s(?P<token>.*?)))\s+│$")
acl_re = re.compile(r"^│\s(?P<path>\/.*?)\s+│\s(?P<roleid>.*?)\s+?│\s(?P<type>.*?)\s+?│\s(?P<ugid>.*?)\s+?│\s+(?P<propagate>\d)\s+?│$")
users_re = re.compile(
    r"^│(?P<userid>.*?)│(?P<comment>.*?)│(?P<email>.*?)│(?P<enable>.*?)│(?P<expire>.*?)│(?P<firstname>.*?)│(?P<groups>.*?)│(?P<keys>.*?)│(?P<lastname>.*?)│(?P<realmtype>.*?)│(?P<tokens>.*?)│$"
)


class FilterModule(object):
    def _get_data(self, matcher, data):
        return_data = []
        for row in data:
            res = matcher.match(row)
            if res:
                return_data.append(res.groupdict())

        return return_data

    def filters(self):
        return {
            "pveum_user_tokens": self.pveum_user_tokens,
            "pveum_groups": self.pveum_groups,
            "pveum_roles": self.pveum_roles,
            "pveum_users": self.pveum_users,
            "pveum_acl_group": self.pveum_acl_group,
            "pveum_user_token": self.pveum_user_token,
            "pveum_generated_token": self.pveum_generated_token,
        }

    def pveum_generated_token(self, data):
        tmp = self._get_data(token_re, data.split("\n"))
        return_data = {}
        for i in tmp:
            return_data.update({k: v for k, v in i.items() if v is not None})
        return return_data["token"]

    def pveum_user_token(self, data):
        def format_data(i):
            return {i["roleid"]: {"prives": i["privs"].split(","), "special": bool(i["special"])}}

        return_data = self._get_data(roles_re, data.split("\n"))
        return dict(ChainMap(*map(format_data, return_data)))

    def pveum_acl_group(self, data):
        def format_data(i):
            return {"path": i["path"], "group": i["ugid"], "roleid": i["roleid"]}

        return_data = filter(lambda i: i["type"] == "group", self._get_data(acl_re, data.split("\n")[3:]))
        return list(map(format_data, return_data))

    def pveum_users(self, data):
        def format_data(i):
            token_data = {}
            # this try block is fugly - but works for now to populate tokendata to userlist
            try:
                tmp = json.loads(i["tokens"])
                for token in tmp:
                    new_entry = token.copy()
                    tokenid = new_entry["tokenid"]
                    del new_entry["tokenid"]
                    token_data[tokenid] = new_entry
            except json.decoder.JSONDecodeError:
                pass

            return {
                i["userid"].strip(): {
                    "comment": i["comment"].strip(),
                    "email": i["email"].strip(),
                    "enable": bool(i["enable"].strip()),
                    "expire": i["expire"].strip(),
                    "firstname": i["firstname"].strip(),
                    "lastname": i["lastname"].strip(),
                    "groups": i["groups"].strip().split(","),
                    "keys": i["keys"].strip(),
                    "realm-type": i["realmtype"].strip(),
                    "tokens": token_data,
                }
            }

        return_data = self._get_data(users_re, data.split("\n")[3:])
        return dict(ChainMap(*map(format_data, return_data)))

    def pveum_roles(self, data):
        def format_data(i):
            return {i["roleid"]: {"prives": i["privs"].split(","), "special": bool(i["special"])}}

        return_data = self._get_data(roles_re, data.split("\n"))
        return dict(ChainMap(*map(format_data, return_data)))

    def pveum_user_tokens(self, data):
        def format_data(i):
            return i["tokenid"]

        return_data = self._get_data(token_list_re, data.split("\n"))
        return list(map(format_data, return_data))

    def pveum_groups(self, data):
        def format_data(i):
            return {i["groupid"]: {"comment": i["comment"], "users": i["users"].split(",")}}

        return_data = self._get_data(group_data_re, data.split("\n"))[1:]

        return dict(ChainMap(*map(format_data, return_data)))
