===============
Troubleshooting
===============

Finding the active Zabbix server node
=====================================

.. highlight:: none

To find the node(s) where Zabbix server is active, run the following command on Fuel master node::

  # fuel nodes | grep controller | awk -F\| '{print $1,$NF}' | sort -n -k 2 | \
      uniq -s 1 | while read cnode lenv; do echo "=========== Environment $lenv" ; \
          ssh -q node-$cnode 'for r in p_zabbix-server vip__public; do \
	      crm resource status $r; \
          done' ; done
  =========== Environment 1
  resource p_zabbix-server is running on: node-4.test.domain.local
  resource vip__public is running on: node-3.test.domain.local

Finding the public VIP
======================

On the returned node from the command above for a given environment, you might also want to know what is the Zabbix VIP address, so run the following command on Fuel master node::

  # ssh -q node-3 ip netns exec haproxy ifconfig b_public | \
      grep 'inet addr:' | sed -e 's/[^:]\*://' -e 's/ .\*//'
  172.16.0.2

Finding the management VIP
==========================

On the returned node from the command above for a given environment, you might also want to know what is the Zabbix VIP address, so run the following command on Fuel master node::

  # ssh -q node-4 ip netns exec haproxy ifconfig b_zbx_vip_mgmt | \
      grep 'inet addr:' | sed -e 's/[^:]*://' -e 's/ .*//'
  192.168.0.3
  # ssh -q node-4 awk '/zbx_vip_mgmt/ {n=1} n==1 && /ipaddr/ {print;exit}' \
      /etc/astute.yaml | sed -e 's/.*: //'
  192.168.0.3

Connect to Zabbix Web GUI
=========================

Use the URI using the public VIP::

  http://172.16.0.2/zabbix

If you cannot access to the Zabbix UI, check that the HTTP  `Apache` server is
running on all controller nodes::

   # /etc/init.d/apache2 status
   * apache2 is running

Zabbix server
=============

If the Zabbix UI reports 'Zabbix server is not running', check the following:

#. Check if the zabbix-server process runs and where is located, in the following
   example the server runs on node-2::

     # crm status
       [snip]
     p_zabbix-server      (ocf::fuel:zabbix-server):    Started node-2.test.domain.local

#. Check logs in '/var/log/zabbix/zabbix_server.log' to see eventual error.

#. If the zabbix-server is down, start it by using the `pacemaker` command::

     # crm resource start p_zabbix-server

#. If the zabbix-server is still down, try the following::

     # crm resource stop p_zabbix-server
     # crm resource cleanup p_zabbix-server
     # crm resource start p_zabbix-server

#. If after the previous commands the zabbix-server is still down and you didn't
   find any explanation in the logs, try to increase the log level::

     # sed -i 's/DebugLevel=3/DebugLevel=4/' /etc/zabbix/zabbix_server.conf
     # crm resource restart p_zabbix-server

Zabbix agents
=============

If a Zabbix agent don't report data (this can be determined on the Zabbix UI
page: configuration > hosts).

#. Check if the corresponding agent is running::

     # /etc/init.d/zabbix-agent status

#. Restart the zabbix-agent if not running::

     # /etc/init.d/zabbix-agent restart

#. If the zabbix-agent is still down or doesn't report any data try the following
   command to validate the agent's configuration. This command should display all
   data that agent is configured to collect, if not the command should display
   an explicit error with regard to the configuration::

     # zabbix_agentd -p

Zabbix log files
================

On any of the cluster node, you might want to look into the Zabbix
agents and server log files under::

  /var/log/zabbix

