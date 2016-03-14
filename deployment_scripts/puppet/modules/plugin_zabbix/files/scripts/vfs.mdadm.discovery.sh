#!/bin/bash
#
#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#Zabbix vfs.mdadm.discovery implementation

echo -e "{\n\t\"data\" : ["

# we have to end each line with a comma except the last one (JSON SIC!)
# so we have to manage the line separator manually in awk :/
awk -F: '
  BEGIN{ORS="";n=0}
  $1 ~ /^md.?/ {
    gsub(" *$","",$1);
    if (n++) print ",\n";
    print "\t{ \"{#MDEVICE}\" : \""$1"\" }"
  }
' /proc/mdstat

echo -e "\n\t]\n}"
