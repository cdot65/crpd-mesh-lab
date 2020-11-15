#!/bin/bash

project=honeycomb
numnodes=$(docker ps| grep $project | grep init|wc -l)

echo ""
echo "$numnodes nodes found"

echo ""
echo "show route summary on node 3:"
docker exec honeycomb_node_3 cli show route summary

echo "show first few routes on crpd node 3:"
docker exec honeycomb_node_3 cli show route | head -40
echo ""
echo "show first few routes on node 3:"
docker exec honeycomb_node_3 ip -6 r | head -20

echo ""
echo "show isis routes on node 1:"
docker exec honeycomb_node_1 cli show isis routes

echo ""
ip6=$(docker exec honeycomb_node_$numnodes ip a show dev lo |grep fd00|awk '{print $2}' | cut -d/ -f1)
echo "node_$numnodes loopback ipv6 is $ip6"

echo ""
echo "show route to node_$numnodes from node1:"
docker exec honeycomb_node_1 ip -6 route get $ip6

echo ""
echo "show isis spf log on node_1"
docker exec honeycomb_node_1 cli show isis spf log

echo ""
echo "traceroute to node_$numnodes from node1 with 16 simultaneous probes:"
docker exec honeycomb_node_1 traceroute -n -N 16 -q 6 $ip6

