#!/bin/bash

PROTO=$1
NS=$2
PORT=$3
IP=$4

if test -z "$NS"; then
    echo 0
    exit 1
fi

if test -z "$PROTO" -o -z "$PORT"; then
    echo 0
    exit 1
fi

if [ -n "$IP" ]; then
  ADDRESS="$PROTO""@""$IP:$PORT"
else
  ADDRESS="$PROTO"":$PORT"
fi

num=$(/bin/ip netns exec "$NS" /usr/bin/lsof -i"$ADDRESS" 2>/dev/null|wc -l)

if [ "$num" -gt 0 ]; then
    echo 1
else
    echo 0
fi
exit 0
