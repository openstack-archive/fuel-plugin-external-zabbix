#!/bin/bash

echo "{"
echo -e "\t\"data\":[\n"

# we have to end each line with a comma except the last one (JSON SIC!)
# so we have to manage the line separator manually in awk :/
awk '
  BEGIN{ORS="";n=0}
  /md?/{
    if (n++) print ",\n";
    print "\t{ \"{#MDEVICE}\":\""$1"\" }"
  }
' /proc/mdstat

echo -e "\n\n\t]"
echo "}"
