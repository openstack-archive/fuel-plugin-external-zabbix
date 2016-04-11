#!/bin/bash

# Example usage of this script:
#   mkdir zbx-244 && cd zbx-244
#   ar x repositories/ubuntu/zabbix-server-mysql_3.0.1-1+trusty_amd64.deb
#   xzcat data.tar.xz | tar xf -
#   cd ..
#   utils/gen_template.sh zbx-244/usr/share/zabbix-server-mysql/data.sql >orig.sql
#   sort deployment_scripts/puppet/modules/plugin_zabbix/templates/data_clean.erb | grep -v '^#' > generated.sql
#   diff orig.sql generated.sql

# Setup some global variables
CMD=`basename $0`
CMDDIR=`dirname $0`
CMDDIR=`(cd $CMDDIR ; pwd)`

# Usage function
function usage {
    echo "Usage: $CMD original-zabbix-data-file.sql" >>/dev/tty
    exit 1
}

# Check of input command line arguments
if [ ! -f $CMDDIR/sed-line-filters.txt ]; then
    echo "Missing file $CMDDIR/sed-line-filters.txt" >>/dev/tty
    exit 1
fi

if [ $# -lt 1 ] || [ -z "$1" ] || [ ! -f "$1" ]; then
    usage
    exit 1
fi

# Creation of temporary directory
mkdir -p $CMDDIR/tmp

# Keep track of ids of actions to be removed
egrep "^INSERT INTO \`actions\`.*'Report not supported |^INSERT INTO \`actions\`.*'Report unknown triggers'" $1 \
    | sed -e "s/.* [Vv][Aa][Ll][Uu][Ee][Ss] (\('[0-9][0-9]*'\),.*/\1/" \
    | awk '{
           printf "^INSERT INTO `conditions` .* VALUES \\(%c[0-9][0-9]*%c,%s,\n",39,39,$0;
           printf "^INSERT INTO `operations` .* VALUES \\(%c[0-9][0-9]*%c,%s,\n",39,39,$0;
           printf "^INSERT INTO `opmessage` .* VALUES \\(%s,%c[0-9][0-9]*%c,\n",$0,39,39;
      }' >$CMDDIR/tmp/extra-removals.txt

# Disabled group id
disid=`egrep "^INSERT INTO .usrgrp. .*'Disabled'" $1 | sed -e "s/.* [Vv][Aa][Ll][Uu][Ee][Ss] (//" -e "s/,.*//"`
# Guest user id
guestid=`egrep "^INSERT INTO .users. .* [Vv][Aa][Ll][Uu][Ee][Ss] \('[0-9][0-9]*','guest'," $1 | sed -e "s/.* [Vv][Aa][Ll][Uu][Ee][Ss] (//" -e "s/,.*//"`

# Processing the file
( sed -e 's/ values / VALUES /g' $1 \
    | egrep -v -f $CMDDIR/sed-line-filters.txt \
    | egrep -v -f $CMDDIR/tmp/extra-removals.txt \
    | sed -e "s/^\(INSERT INTO \`drules\` .*\)'192.168.0.1-254'\(.*\)/\1'192.168.1.1-254'\2/" \
    | sed -e "s?^\(INSERT INTO \`scripts\` .*,'\)/usr/bin/traceroute \(.*\)?\1/usr/sbin/traceroute \2?" \
    | sed -e "s/^\(INSERT INTO \`users\` .* [Vv][Aa][Ll][Uu][Ee][Ss] ('[0-9][0-9]*',\)'Admin'\(,'Zabbix','Administrator','\)[^']*\('.*\)/\1'<%= scope.lookupvar('plugin_zabbix::params::zabbix_admin_username') %>'\2<%= scope.lookupvar('plugin_zabbix::params::zabbix_admin_password_md5') %>\3/" \
    | sed -e "s/^\(INSERT INTO \`users\` .* [Vv][Aa][Ll][Uu][Ee][Ss] ('[0-9][0-9]*','guest',\)'',''\(,.*\)/\1'Default','User'\2/" \
    | sed -e "s/^\(INSERT INTO \`users_groups\` .* [Vv][Aa][Ll][Uu][Ee][Ss] ('2',\)'[0-9][0-9]*'\(,$guestid);\)/\1$disid\2/" \
    | sed -e "s/^\(INSERT INTO \`expressions\` .*\),'1');/\1,'0');/" ;
    cat $CMDDIR/additions.txt) \
	| sort

# Cleanup of temporary directory
rm -rf $CMDDIR/tmp
