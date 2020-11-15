#!/bin/bash     

set -e

export > /etc/envvars
export ID=$(echo $HOSTNAME | sed 's/.\{4\}/&./g')
export ID2=$(echo $HOSTNAME | sed 's/.\{4\}/:&/g')

if [ -s /network-init.sh ]; then
  envsubst < /network-init.sh >> /config/network-init.sh
  /bin/bash /config/network-init.sh > /root/network-init.log 2>&1 & disown
fi

if [ -f /juniper.conf ]; then
  envsubst < /juniper.conf >> /config/juniper.conf
fi

echo "launching iperf3 server ..."
/usr/bin/iperf3 --server --daemon

exec /sbin/runit-init 0
