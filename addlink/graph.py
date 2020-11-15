#!/usr/bin/env python3

import sys
import time
import os
from pprint import pprint
from igraph import *


def nodeid(row, col):
    rv = (row - 1)*cols + col
    return(rv)


project = sys.argv[1]
rows = int(sys.argv[2])
cols = int(sys.argv[3])

if (len(sys.argv) != 4):
    exit(1)

print("input parameters: rows=%d cols=%d" % (rows, cols))

linkcount = 0
nodecount = 0
g = Graph(directed=False)
g.add_vertices(rows * cols)

for row in range(1, rows + 1):
    for col in range(1, cols + 1):
        g.vs[nodecount]["id"] = nodecount + 1
        g.vs[nodecount]["label"] = str(nodecount + 1)
        nodecount += 1
        if col > 1:
            g.add_edges([(nodeid(row, col) - 1, nodeid(row, col - 1) - 1)])
            linkcount += 1

        if (row > 1) and ((row % 2) != (col % 2)):
            # odd row
            g.add_edges([(nodeid(row, col) - 1, nodeid(row - 1, col) - 1)])
            linkcount += 1

visual_style = {}
out_name = "honeycomb.png"
# Set bbox and margin
visual_style["bbox"] = (1000, 1000)
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
pprint(g.layout())
# Plot the graph
plot(g, out_name, **visual_style)
