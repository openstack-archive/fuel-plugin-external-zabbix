====================
Troubleshooting tips
====================

Finding the active Zabbix server node
=====================================

To find the node(s) where Zabbix server is active, run the following command on Fuel master node::

  # fuel nodes | grep controller | awk -F\| '{print $1,$NF}' | sort -n -k 2 | uniq -s 1 | \
  while read cnode lenv; do echo "=========== Environment $lenv" ; ssh -q node-$cnode \
  'for r in p_zabbix-server vip__public; do crm resource status $r; done' ; done
  =========== Environment 1
  resource p_zabbix-server is running on: node-4.test.domain.local
  resource vip__public is running on: node-3.test.domain.local

Finding the public VIP
======================

On the returned node from the command above for a given environment, you might also want to know what is the Zabbix VIP address, so run the following command on Fuel master node::

  # ssh -q node-3 ip netns exec haproxy ifconfig b_public | grep 'inet addr:' | sed -e 's/[^:]\*://' -e 's/ .\*//'
  172.16.0.2

Finding the management VIP
==========================

On the returned node from the command above for a given environment, you might also want to know what is the Zabbix VIP address, so run the following command on Fuel master node::

  # ssh -q node-4 ip netns exec haproxy ifconfig b_zbx_vip_mgmt | grep 'inet addr:' | sed -e 's/[^:]*://' -e 's/ .*//'
  192.168.0.3
  # ssh -q node-4 awk '/zbx_vip_mgmt/ {n=1} n==1 && /ipaddr/ {print;exit}' /etc/astute.yaml| sed -e 's/.*: //'
  192.168.0.3

Connect to Zabbix Web GUI
=========================

Use the URI using the public VIP::

  http://172.16.0.2/zabbix

Zabbix log files
================

On any of the cluster node, you might want to look into the Zabbix
agents and server log files under::

  /var/log/zabbix

