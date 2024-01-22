# Собираем уникальные ключи из локал контекста NB

import os
from pprint import pprint

import pynetbox
from dotenv import load_dotenv

load_dotenv()

NB_URL = os.getenv("NB_URL")
TOKEN = os.getenv("TOKEN")

nb = pynetbox.api(NB_URL, token=TOKEN)

keys_tenant = []
devices = nb.dcim.devices.filter(tenant='some_tenant')
for device in devices:
    if (device.local_context_data and
        'dts-' in device.name):
        print(device.name)
        for key in device.local_context_data.keys():
            if key not in keys_tenant:
                keys_tenant.append(key)

print(keys_tenant)
