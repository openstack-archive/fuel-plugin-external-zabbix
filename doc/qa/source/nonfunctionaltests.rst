======================
Non-functional testing
======================

Check fix for #1532199: wrong version number in the Requirements section
========================================================================

=============== ====================================
Test Case ID    test_1532199
=============== ====================================
Steps           #. Open the Zabbix Plugin Guide
                #. Goto Requirement section
--------------- ------------------------------------
Expected Result MOS value should be 6.1 only
=============== ====================================

Zabbix service network failover (destructive)
=============================================

=============== ====================================
Test Case ID    test_network_failover
=============== ====================================
Steps           #. Find node with active
                   zabbix-server via

		   ``crm status``
                #. Send script file to zabbix node
                   with

                   ``#!/bin/sh``

                   ``/sbin/iptables -I INPUT -j DROP``

                   ``sleep 20``

                   ``/sbin/iptables -D INPUT -j DROP``
                #. Run script file on zabbix node
                #. Check that zabbix is active on
                   other node via

		   ``crm status``
                #. Check response from zabbix via
                   HTTP request
--------------- ------------------------------------
Expected Result No failover
=============== ====================================

Zabbix service host failover (destructive)
==========================================

=============== ====================================
Test Case ID    test_host_failover
=============== ====================================
Steps           #. Find node with active
                   zabbix-server via

		   ``crm status``
                #. Introduce erroneous zabbix
                   configuration
                #. Kill process zabbix_server on
                   zabbix node
                #. Check that zabbix is active on
                   other node via

		   ``crm status``
                #. Check response from zabbix via
                   HTTP request
--------------- ------------------------------------
Expected Result No failover
=============== ====================================

