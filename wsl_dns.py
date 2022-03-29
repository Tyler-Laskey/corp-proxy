#!/usr/bin/env python3

# Disabling WSL DNS Management
# Add the following entry to /etc/wsl.conf:
#   [network]
#   generateResolvConf = false
#
# Change permissions on /etc/resolv.conf
#   sudo chown $USER:root /etc/resolv.conf

import os
import re
import datetime
import ipaddress
import socket
import subprocess
import json
import sys

PSCMD = '/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe'

def get_iface_networks(dev):
    # IPv6 is cool, but Nokia doesn't use it
    return re.search(re.compile(r'(?<=inet )(.*)(?=\ brd)', re.M), os.popen(f'ip addr show {dev}').read()).groups()


def get_first_network_address(net):
    # Expects IP/Netmask (172.16.20.164/28)
    return ipaddress.IPv4Interface(net).network[1]


def get_default_gateway():
    return re.search(re.compile(r'via ([0-9.]+)', re.M), os.popen(f'ip route list default').read()).groups()[0]


def get_cisco_vpn_dns_servers():
    p = subprocess.run([PSCMD, 'Get-NetAdapter| Where-Object InterfaceDescription -like \"Cisco AnyConnect*\" | Get-DnsClientServerAddress | Where-Object AddressFamily -eq 2 | ConvertTo-Json -Compress'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if not p.stdout:
        return None

    return json.loads(p.stdout.decode('utf-8'))['ServerAddresses']


def get_dns_search_list():
    p = subprocess.run([PSCMD, 'Get-DnsClientGlobalSetting | ConvertTo-Json -Compress'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if not p.stdout:
        return None

    return json.loads(p.stdout.decode('utf-8'))['SuffixSearchList']


def generate_resolv(servers, search_list):
    out = []
    out.append(f"# Generated by {sys.argv[0]} at {str(datetime.datetime.now())}")
    for x in servers:
        out.append(f"nameserver {x}")

    if search_list:
        search_str = ','.join(search_list)
        out.append(f"search {search_str}")

    out.append("options timeout:1 retries:1")
    return '\n'.join(out)


def write_resolv(data):
    with open('/etc/resolv.conf', 'w') as fd:
        fd.write(data)
        fd.write('\n')


def main():
    # Assumes we only have one IP configured on the Linux eth0 interface
    eth0_network = get_iface_networks('eth0')[0]
    eth0_gateway = str(get_first_network_address(eth0_network))
    default_gateway = get_default_gateway()

    # Sanity Checks
    if eth0_gateway != default_gateway:
        print("Warning: default gateway does not match guessed gateway of eth0")
        print("Warning: script makes assumptions that may not be true on your system!")

    # Calling powershell from Linux seems weird, so... yeah...
    vpn_dns_servers = get_cisco_vpn_dns_servers()
    dns_search = get_dns_search_list()

    # Always include the hyper-v resolver, as if the VPN disconnects, linux will try all resolvers (albit slower)
    if vpn_dns_servers:
        dns_servers = vpn_dns_servers + [eth0_gateway]
    else:
        dns_servers = [eth0_gateway]

    config = generate_resolv(dns_servers, dns_search)
    print("Generated resolv.conf")
    print(config)
    write_resolv(config)

main()
sys.exit()