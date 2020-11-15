#!/bin/bash

project=honeycomb
numroutes=$(docker ps| grep $project | grep init|wc -l)

echo ""
echo -n "waiting for ISIS adjacencies to come up "
while true; do
  docker exec honeycomb_node_3 cli show isis adj 2>/dev/null | grep Up | wc -l | grep 3 && break
  echo -n "."
  sleep 1
done

echo ""
echo -n "waiting for all links to be created "
while true; do
  docker cp honeycomb_links_1:/honeycomb.png . >/dev/null 2>&1 && break
  echo -n "."
  sleep 1
done

echo -n "waiting for $numroutes routes learned "
while true; do
  [ $(docker exec  honeycomb_node_1 ip -6 r |grep -v / |wc -l) -ge $numroutes ] && break
  echo -n "."
  sleep 1
done

echo ""
echo "$(docker exec  honeycomb_node_1 ip -6 r |grep -v / |wc -l) routes learned"
docker logs honeycomb_links_1 |grep Completed

echo "validation completed in $SECONDS seconds"
echo ""
echo "System infos:"
lscpu | grep name
cat /proc/meminfo | grep MemTotal

echo ""
echo "network diagram saved in"
ls -l honeycomb.png
