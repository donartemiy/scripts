from netmiko import ConnectHandler

hostnames = ['hostname.ru']


def remote_command(host):
    device = {
        'device_type': 'mikrotik_routeros',
        'host': host,  # IP-адрес коммутатора
        'username': 'YYYYYY',  # Ваше имя пользователя
        'password': 'XXXXXX',  # Ваш пароль
    }
    ssh_connect = ConnectHandler(**device)
    output = ssh_connect.send_command('/system routerboard print')
    ssh_connect.disconnect()
    return (output)


if __name__ == "__main__":
    filename = 'results.txt'

    with open(filename, 'w+') as f:
        for host in hostnames:
            print(host)
            try:
                results = remote_command(host)
                f.write(f'\n\nhost: {host}\n{results}')
            except Exception:
                f.write(f'\n\nhost: {host}\nConnection error')
