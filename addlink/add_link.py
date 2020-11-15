#!/usr/bin/env python3

import sys
import time
import os
import docker
from pyroute2 import NetNS, IPRoute
from pprint import pprint
from threading import Event
from igraph import *

MTU = 3000

project = sys.argv[1]
rows = int(sys.argv[2])
cols = int(sys.argv[3])

client = docker.from_env()
ipr = IPRoute()


start = time.perf_counter()


def create_netns(container):
    if not (os.path.exists("/var/run/netns/" + container)):
        # print("path doesn't exists")
        while True:
            try:
                co = client.containers.get(container)
                if co.attrs['State']['Running']:
                    break

            except:
                print("waiting for container {} ...".format(container))
                sys.stdout.flush()
                time.sleep(1)
                pass

        pid = co.attrs['State']['Pid']
        # print("{} has pid={}".format(container, pid))
        os.symlink("/proc/{}/ns/net".format(pid),
                   "/var/run/netns/" + container)


def newifname(container):
    ns = NetNS(container)
    i = 0
    for link in ns.get_links():
        ifname = link.get_attr('IFLA_IFNAME')
        if ifname.startswith('eth'):
            i += 1
    ns.close()
    return('eth{}'.format(i))


def setloopbackip(node, i):
    create_netns(node)
    ns = NetNS(node)
    idx = ns.link_lookup(ifname='lo')[0]
    ns.addr('add', index=idx, address='fd00::{}'.format(i), prefixlen=128)
    print("set {} lo addr fd00::{}/128".format(node, i))
    ns.close()

def addlink(c1, c2):
    create_netns(c1)
    ifname1 = newifname(c1)
    create_netns(c2)
    ifname2 = newifname(c2)

    ipr.link('add', ifname='veth1', kind='veth', peer='veth2')
    idx1 = ipr.link_lookup(ifname='veth1')[0]
    idx2 = ipr.link_lookup(ifname='veth2')[0]
    ipr.link('set', index=idx1, ifname=ifname1,
             net_ns_fd=c1, state='up', mtu=MTU)
    ipr.link('set', index=idx2, ifname=ifname2,
             net_ns_fd=c2, state='up', mtu=MTU)
    print("link {}:{} <---> {}:{} created".format(c1, ifname1, c2, ifname2))
    sys.stdout.flush()


# calculate container id, assuming a row has cols nodes
# and rows and cols start at 1
def nodeid(row, col):
    rv = (row - 1)*cols + col
    return(rv)


if (len(sys.argv) != 4):
    exit(1)

print("input parameters: rows=%d cols=%d" % (rows, cols))

linkcount = 0
nodecount = 0
g = Graph(directed=False)
g.add_vertices(rows * cols)

for row in range(1, rows + 1):
    for col in range(1, cols + 1):
        g.vs[nodecount]["id"]= nodecount + 1
        g.vs[nodecount]["label"]= str(nodecount + 1)
        nodecount += 1
        node='{}_node_{}'.format(project, nodeid(row, col))
        if col > 1:
            addlink(node, 
                    '{}_node_{}'.format(project, nodeid(row, col - 1)))
            g.add_edges([(nodeid(row, col) -1,nodeid(row, col -1) -1)])
            linkcount += 1

        if (row > 1) and ((row % 2) != (col % 2)):
            # odd row
            addlink(node,
                    '{}_node_{}'.format(project, nodeid(row - 1, col)))
            g.add_edges([(nodeid(row, col) -1,nodeid(row -1, col) -1)])
            linkcount += 1
        setloopbackip(node, nodeid(row, col))

end = time.perf_counter()
seconds = int(end - start)

print()
print("Completed {} links for {} ({}x{}) nodes in {} seconds".format(
    linkcount, rows * cols, rows, cols, seconds))

visual_style = {}
out_name = "honeycomb.png"
# Set bbox and margin
visual_style["bbox"] = (1000,1000)
visual_style["margin"] = 30
# Set vertex colours
visual_style["vertex_color"] = 'white'
# Set vertex size
visual_style["vertex_size"] = 30
# Set vertex lable size
visual_style["vertex_label_size"] = 12
# Don't curve the edges
visual_style["edge_curved"] = False
# Set the layout
my_layout = g.layout_grid(width=cols, height=0, dim=2)
visual_style["layout"] = my_layout
# Plot the graph
plot(g, out_name, **visual_style)

# wait forever to keep the container alive
sys.stdout.flush()
Event().wait()
