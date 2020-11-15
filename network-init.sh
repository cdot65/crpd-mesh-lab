#!/bin/bash

# issue network initialization commands here before crpd takes over

#echo "setting loopback ip addresses (now set by add_link.py in links) ..."
#ip -6 addr add fd00:${ID2}/128 dev lo

echo "launching iperf3 server ..."
/usr/bin/iperf3 --server --daemon
