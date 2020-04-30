"""Generate a pwnboard config from the generic topology format

https://github.com/ritredteam/topology-generator
"""
import sys
import json

def get_hosts(data):
    hosts = []
    for network in data['networks']:
        netip = network['ip']
        for nethost in network['hosts']:
            host = nethost.copy()
            if nethost['ip'].lower() == "dhcp":
                host['ip'] = "dhcp"
            else:
                host['ip'] = ".".join((netip, nethost['ip']))
            hosts += [host]
    return hosts

def gen_board(data):
    board = []
    for host in get_hosts(data):
        row = {}
        row['name'] = host.get('name', host.get('ip'))
        row['hosts'] = []
        for team in data['teams']:
            row['hosts'].append({'ip': host['ip'].replace("x", str(team))})
        board.append(row)
    return board


def main():
    if len(sys.argv) < 3:
        print("USAGE: {} <infile> <outfile>".format(sys.argv[0]))
        quit(1)

    with open(sys.argv[1]) as fil:
        data = json.load(fil)

    board = {"teams": data['teams']}
    board['board'] = gen_board(data)
    with open(sys.argv[2], 'w') as fil:
        fil.write(json.dumps(board, indent=2))

if __name__ == "__main__":
    main()
