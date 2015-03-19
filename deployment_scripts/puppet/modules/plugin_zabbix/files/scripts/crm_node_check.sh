#!/bin/bash
NODES=$(/usr/bin/sudo /usr/sbin/crm_resource --locate --quiet --resource $1)
HOSTNAME=$(/bin/hostname)

for NODE in $NODES
do
  if [ "$NODE" == "$HOSTNAME" ]; then
    echo 1
    exit
  fi
done
echo 0
