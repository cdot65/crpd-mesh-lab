#!/bin/bash

MTU=3000

function addlink {
  c1=$1
  c2=$2
  until [ ! -z "$(docker ps -q -f name=$c1)" ]; do
     echo "waiting for container $c1 ..."
     sleep 1
     if [ $SECONDS -gt 5 ]; then
        echo "$c1 not running"
        exit 1
     fi
  done

  fc1=$(docker ps -q -f name=$c1)
  echo "$c1 $fc1"
  pid1=$(docker inspect -f "{{.State.Pid}}" $fc1)
  if [ -z "$pid1" ]; then
      echo "Can't find pid for container $c1"
      exit 1
  fi

  until [ ! -z "$(docker ps -q -f name=$c2)" ]; do
     echo "waiting for container $c2 ..."
     sleep 1
     if [ $SECONDS -gt 5 ]; then
        echo "$c1 not running"
        exit 1
     fi
  done

  fc2=$(docker ps -q -f name=$c2)
  echo "$c2 $fc2"
  pid2=$(docker inspect -f "{{.State.Pid}}" $fc2)
  if [ -z "$pid2" ]; then
      echo "Can't find pid for container $c2"
      exit 1
  fi

  echo "$c1 has pid $pid1"
  echo "$c2 has pid $pid2"

  if [ ! -e "/var/run/netns/$c1" ]; then
    ln -sf /proc/$pid1/ns/net /var/run/netns/$c1
  fi
  if [ ! -e "/var/run/netns/$c2" ]; then
    ln -sf /proc/$pid2/ns/net /var/run/netns/$c2
  fi

  ifcount1=$(ip netns exec $c1 ip link | grep ' eth' | wc -l)
  ifcount2=$(ip netns exec $c2 ip link | grep ' eth' | wc -l)
  echo "$c1 has $ifcount1 eth interfaces"
  echo "$c2 has $ifcount2 eth interfaces"
  vname1="a${ifcount1}"
  vname2="b${ifcount2}"
  ifname1="eth${ifcount1}"
  ifname2="eth${ifcount2}"

  ip link del dev $vname1 2>/dev/null || true
  ip link add $vname1 type veth peer name $vname2

  ifconfig $vname1
  ifconfig $vname2

  echo "setting mtu ..."
  ip link set dev $vname1 mtu $MTU
  ip link set dev $vname2 mtu $MTU

  echo "moving endpoints to netns ..."
  ip link set $vname1 name $ifname1 netns $c1
  ip link set $vname2 name $ifname2 netns $c2

  echo "bringing links up ..."
  ip netns exec $c1 ip link set up $ifname1
  ip netns exec $c2 ip link set up $ifname2

  echo "$c1:$ifname1 === $c2:$ifname2"
}

### main ###
project=$1
rows=$2
cols=$3

echo "project=$project rows=$rows cols=$cols"

if [ -z "$cols" ]; then
    echo "$0 <project> <rows> <cols>"
    exit 1
fi
set -e	# terminate on error

mkdir -p /var/run/netns

SECONDS=0

for row in $(seq 1 $rows); do
  for col in $(seq 1 $cols); do
    if [ $col -gt 1 ]; then
      let "left=col-1"
      echo "create link between ${project}_${row}_${left} and ${project}_${row}_${col} ..."
      addlink ${project}_${row}_${left} ${project}_${row}_${col}
    fi
    if [ $row -gt 1 ]; then
      let "down=row-1"
      if [ $(expr $row % 2) -eq 0 ]; then
        # even row 
        if [ $(expr $col % 2) -ne 0 ]; then
          echo "create link between ${project}_${row}_${col} and ${project}_${down}_${col} ..."
          addlink ${project}_${row}_${col} ${project}_${down}_${col}
        fi
      else
        # odd rows
        if [ $(expr $col % 2) -eq 0 ]; then
          echo "create link between ${project}_${row}_${col} and ${project}_${down}_${col} ..."
          addlink ${project}_${row}_${col} ${project}_${down}_${col}
        fi
      fi
    fi
  done
done

echo "done"

tail -f /dev/null
