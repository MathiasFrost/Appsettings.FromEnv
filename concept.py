import json
import re

if __name__ == '__main__':
    env_vars = {
        "AFB__Fileshare__APIKey": "test1",
        "AFB__Start__ApiKey": "test2",
        "PhysicalPath": "test3",
        "APIKeys__0__APIKey": "test4",
        "APIKeys__0__Sub": "test5",
        "APIKeys__0__Role": "test6"
    }

    res = {}
    for key, value in env_vars.items():
        curr = res
        parts = [s for s in key.split("__") if s.strip() != ""]
        for i in range(0, len(parts)):
            obj = {}
            skip = False
            if len(parts) > i + 1 and re.match(r"^\d+$", parts[i + 1]):
                curr[parts[i]] = [obj]
                curr = obj
                skip = True

            if parts[i] in curr.keys():
                obj = curr[parts[i]]
            elif i == len(parts) - 1:
                curr[parts[i]] = value
            else:
                curr[parts[i]] = obj
            curr = obj

            if skip:
                continue

    print(json.dumps(res, indent=4).replace("    ", "\t"))
