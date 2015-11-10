
Troubleshooting
===============

Zabbix UI
---------

If you cannot access to the Zabbix UI, check that the HTTP  `Apache` server is
running on all controller nodes::

  # /etc/init.d/apache2 status
   * apache2 is running

Zabbix server
-------------

If the Zabbix UI reports 'Zabbix server is not running', check the following:

#. Check if the zabbix-server process runs and where is located, in the following
   example the server runs on node-2::

    # crm status

       [snip]

     p_zabbix-server        (ocf::fuel:zabbix-server):      Started node-2.test.domain.local

#. Check logs in '/var/log/zabbix/zabbix_server.log' to see eventual error.

#. If the zabbix-server is down, start it by using the `pacemaker` command::

   # crm resource start p_zabbix-server

# If the zabbix-server is still down, try the following::

   # crm resource stop p_zabbix-server
   # crm resource cleanup p_zabbix-server
   # crm resource start p_zabbix-server

# If after the previous commands the zabbix-server is still down and you didn't
  find any explanation in the logs, try to increase the log level::

  # sed -i 's/DebugLevel=3/DebugLevel=4/' /etc/zabbix/zabbix_server.conf
  # crm resource restart p_zabbix-server

Zabbix agents
-------------

If an Zabbix agent don't report data (this can be determined on the Zabbix UI
page: configuration > hosts).

#. Check if the corresponding agent is running::

   # /etc/init.d/zabbix-agent status

#. Restart the zabbix-agent if not running::

   # /etc/init.d/zabbix-agent restart

# If the zabbix-agent is still down or doesn't report any data try the following
  command to validate the agent's configuration. This command should display all
  data that agent is configured to collect, if not the command should display
  an explicit error with regard to the configuration::

  # zabbix_agentd -p
