#!/bin/bash

echo "setting loopback ip addresses ..."
ip -6 addr add fd00:${ID2}/128 dev lo
