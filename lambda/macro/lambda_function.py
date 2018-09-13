"""CloudFormation macro used for additional processing of templates."""
import json
import string
import random
import os

__author__ = "Jason DeBolt (jasondebolt@gmail.com)"

def random_lowercase_string(str_len):
    return ''.join([random.choice(string.ascii_lowercase) for _ in range(str_len)])

def macro_value_replace(obj, old=None, new=None, replace_map=None):
    # This function only replaces values in a JSON CloudFormation template, not keys.
    if isinstance(obj, dict):
        for key, value in obj.items():
            if isinstance(value, str):
                if old is not None and new is not None:
                    if old in value:
                        obj[key] = obj[key].replace(old, new)
                elif replace_map is not None:
                    for replace_key, replace_val in replace_map.items():
                        if replace_key in value:
                            obj[key] = obj[key].replace(replace_key, replace_val)
            else:
                macro_value_replace(value, old, new, replace_map)
    elif isinstance(obj, list):
        for index, item in enumerate(obj):
            if isinstance(item, str):
                if old is not None and new is not None:
                    if old in item:
                        obj[index] = obj[index].replace(old, new)
                elif replace_map is not None:
                    for replace_key, replace_val in replace_map.items():
                        if replace_key in item:
                            obj[index] = obj[index].replace(replace_key, replace_val)
            else:
                macro_value_replace(item, old, new, replace_map)

def macro_key_replace(obj, old=None, new=None):
    # This function only replaces keys in a JSON CloudFormation template, not values.
    # Updates only the part of they key that matches.
    # {"old123": ...} --> {"new123": ...}
    if isinstance(obj, dict):
        for key, value in obj.items():
            if old is not None and new is not None:
                if old in key:
                    new_key = key.replace(old, new)
                    obj[new_key] = obj[key]
                    del obj[key]
            macro_key_replace(value, old, new)
    elif isinstance(obj, list):
        for index, item in enumerate(obj):
            macro_key_replace(item, old, new)

def lambda_handler(event, context):
    print(event)
    print(os.environ)
    print(json.dumps(event, indent=2, default=str))

    fragment = event['fragment']

    macro_value_replace(fragment, old='PHX_MACRO_PROJECT_NAME', new=os.environ['PHX_MACRO_PROJECT_NAME'])
    macro_value_replace(fragment, old='PHX_MACRO_RANDOM_7', new=random_lowercase_string(7))
    macro_key_replace(fragment, old='PHX_MACRO_RANDOM_7', new=random_lowercase_string(7))

    print('New Fragment')
    print(fragment)

    return {
        "requestId": event['requestId'],
        "status": "success",
        "fragment": fragment
    }
