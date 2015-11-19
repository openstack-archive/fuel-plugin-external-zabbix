======================
Dependant plugin tests
======================

Check Zabbix dependant plugins
==============================

Test ID: test_dependant_plugins

Expected Result:

   Cluster deployed, Hosts for EMC and Extreme network are present
   and Traps are handled by Zabbix

Steps:

* Upload and install Zabbix plugins

  * `SNMP Trap Daemon for Zabbix <https://github.com/openstack/fuel-plugin-zabbix-snmptrapd>`_ available in `Fuel Plugins Catalog <https://software.mirantis.com/fuel-plugins>`_
  * `Extreme Networks monitoring extension for Zabbix plugin <https://github.com/openstack/fuel-plugin-zabbix-monitoring-extreme-networks>`_
  * `EMC hardware monitoring extension for Zabbix plugin <https://github.com/openstack/fuel-plugin-zabbix-monitoring-emc>`_

* Configure EMC plugin with a fake Name/IP pair:

  * `MyEMCHost:10.109.0.100` (the IP must be in your network range)

* Configure Extreme Networks plugin with a fake Name/IP pair:

  * `MyXNHost:10.109.0.101` (the IP must be in your network range)

* Deploy and run test as desribed in :ref:`deploy_zabbix_ha`
* Verify that these 2 hosts are created in Zabbix (`Configuration > Hosts`)

  * MyEMCHost
  * MyXNHost

In order to test SNMP traps without hardware you need to generate them manually
with `snmptrap` command, you can install it by issuing this command on Ubuntu::

  apt-get install snmp


1. Send EMC traps::


    # EMC Critical
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1981' '<EMC Host IP>' 6 6 '10' .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "a37"

    # EMC error
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1981' '<EMC Host IP>' 6 5 '10' .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "966"

    # EMC warning
     snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1981' '<EMC Host IP>' 6 4 '10' .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "7220"

    # EMC information
     snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1981' '<EMC Host IP>' 6 3 '10' .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "null" .1.3.6.1.4.1.1981 s "2004"

    # Where <EMC Host IP> is 10.109.0.100 in our example


2. Send Extreme Networks traps::

    # PS down
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1916' '<XN Host IP>' 6 10 '10' .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "2"

    # PS UP
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1916' '<XN Host IP>' 6 11 '10' .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "2"

    # Port down
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.6.3.1.1' '<XN Host IP>' 2 10 '10' .1.3.6.1.6.3.1.1 s "eth1"

    # Port up
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.6.3.1.1' '<XN Host IP>' 3 10 '10' .1.3.6.1.6.3.1.1 s "eth1"

    # Fan down
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1916' '<XN Host IP>' 6 7 '10' .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "5"

    # Fan up
    snmptrap -v 1 -c public <Zabbix VIP> '.1.3.6.1.4.1.1916' '<XN Host IP>' 6 8 '10' .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "null" .1.3.6.1.4.1.1916 s "5"

    # Where <XN Host IP> is 10.109.0.101 in our example

3. Verify these traps have been received by Zabbix.

   * On `Monitoring > Latest data` page filter by hosts `MyEMCHost` and `MyXNHost`
   * verify that all items have `Last value`

    .. image:: ../images/zabbix_snmp_traps.png
       :width: 100%
