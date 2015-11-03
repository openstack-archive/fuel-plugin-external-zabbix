======================
Non-functional testing
======================


Zabbix service network failover (destructive)
=============================================

Test ID: test_network_failover

Expected Result: No failover

Steps:

* Find node with active zabbix-server via `crm status`
* Send script file to zabbix node with:
    ::

      #!/bin/sh
      /sbin/iptables -I INPUT -j DROP
      sleep 20
      /sbin/iptables -D INPUT -j DROP

* Run script file on zabbix node
* Check that zabbix is active on other node via `crm status`
* Check response from zabbix via HTTP request


Zabbix service host failover (destructive)
==========================================

Test ID: test_triggers

Expected Result: All preconfigured triggers are present

Steps:

* Find node with active zabbix-server via `crm status`
* Shutdown the node
* Check that zabbix is active on other node via `crm status`
* Check response from zabbix via HTTP request

