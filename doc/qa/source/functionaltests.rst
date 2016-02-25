====================
 Functional testing
====================

Check Zabbix deployment
=======================

=============== ====================================
Test Case ID    test_zabbix_deployment

                test_zabbix_started
=============== ====================================
Steps           #. Check that package
                   zabbix-server installed on
                   controllers
                #. Check that zabbix-server is
                   started via

		   ``crm status``
--------------- ------------------------------------
Expected Result Zabbix Started
=============== ====================================

Check Zabbix API
================

=============== ====================================
Test Case ID    test_get_ver_API

                test_authentication_valid_cred

                test_authentication_invalid_cred

                test_http

                test_https

                test_ssl_certificate
=============== ====================================
Steps           #. Get version API
                #. Test authentication with valid
                   credentials
                #. Test if authentication impossible
                   with invalid credentials
                #. Check HTTP request to dashboard
                #. Check HTTPS request to dashboard
                #. Check SSL certificate
--------------- ------------------------------------
Expected Result All steps passed
=============== ====================================

Check dashboard configuration
=============================

=============== ====================================
Test Case ID    test_graph
=============== ====================================
Steps           #. Log in to zabbix web
                #. Get zabbix/screens.php
                #. Check preconfigured graphs
--------------- ------------------------------------
Expected Result Dashboard is preconfigured
=============== ====================================

Check zabbix triggers
=====================

=============== ====================================
Test Case ID    test_triggers
=============== ====================================
Steps           #. Log in to zabbix web
                #. Check if preconfigured triggers
                   are present
--------------- ------------------------------------
Expected Result All preconfigured triggers are
                present
=============== ====================================

Check zabbix new triggers for RabbitMQ
======================================

=============== =====================================
Test Case ID    test_rabbitmq_triggers
=============== =====================================
Steps           #. Log in via ssh to Fuel master
                   node
                #. Run the following command:

                   ``for h in $(fuel nodes 2>/dev/null
                   | awk -F\| '$2 ~ / ready / && $9
                   ~ / True /{printf "node-%s\n",$1}');
                   do ssh -q $h 'grep log_level
                   /etc/zabbix/check_rabbit.conf 2>
                   /dev/null';
                   done | grep CRITICAL | wc -l``
                #. Log in to zabbix web
                #. Goto Configuration -> Templates
                   ->
                   Template_App_OpenStack_HA_RabbitMQ
                   -> Triggers
--------------- -------------------------------------
Expected Result Command in step 2 should return
                number of controllers and all
                preconfigured RabbitMQ triggers are
                present. 7 instead of 5 previously,
                2 new of Average Severity (nodes
                missing from cluster, queues are not
                mirrored)
=============== =====================================

Check fix for #1446257: Core openstack services without Zabbix triggers
=======================================================================

=============== ====================================
Test Case ID    test_1446257
=============== ====================================
Steps           #. Log in to zabbix web
                #. Goto Configuration -> Templates
                   -> Template_OpenStack_Cluster
                   -> Triggers
--------------- ------------------------------------
Expected Result All preconfigured OpenStack triggers
                are present. 8 instead of 5
                previously, 3 new of Average
                Severity (Cinder, Neutron & Nova
                services)
=============== ====================================

Check fix for #1468546: Zabbix does not monitor disk space
==========================================================

=============== ====================================
Test Case ID    test_1468546
=============== ====================================
Steps           #. Log in into one of controller
                   nodes
                #. Run the following set of commands

                   ``sz=`df /boot | tail -1 | awk
                   '{print $(NF-2)}'```

                   ``dd if=/dev/zero of=/boot/xx
                   bs=1k count=`expr $sz / 1000
                   \* 1000```
                #. Log in to zabbix web
                #. Goto Dashboard and wait at least
                   a minute
--------------- ------------------------------------
Expected Result One issue should raise as yellow
                warning 'Free disk space is less
                than 20% on volume /boot'
=============== ====================================

Check fix for #1525189: Zabbix wrong default path of fping on Debian based OSes
===============================================================================

=============== =======================================
Test Case ID    test_1525189
=============== =======================================
Steps           #. Log in via ssh to Fuel master
                   node
                #. Run the following command:

                   ``for h in $(fuel nodes 2>/dev/null
                   | awk -F\| '$2 ~ / ready / && $9
                   ~ / True /{printf "node-%s\n",$1}');
		   do ssh -q $h \\
                   'grep -qi Ubuntu /etc/\*release\*
                   ; if [ $? -eq 0 ]; then grep
                   Fping
                   /etc/zabbix/zabbix_server.conf
                   2>/dev/null; fi'; done | grep
                   /usr/bin | wc -l``
--------------- ---------------------------------------
Expected Result Value should be equal to 2 times
                number of Controllers
=============== =======================================

Check fix for #1419397: zabbix rabbitmq reports not running after clean deployment
==================================================================================

=============== ====================================
Test Case ID    test_1419397
=============== ====================================
Steps           #. Log in to zabbix web
                #. Goto monitoring -> Dashboard ->
                   Controllers -> click on any of
                   the node-X and select "latest
                   data"
                #. Goto RabbitMQ and click graph
                   link for the "RabbitMQ EPMD
                   process is running" entry
                #. Select "value" instead of
                   "graph".
                #. Select All as the Zoom value to
                   see all entries
--------------- ------------------------------------
Expected Result All values should be 1 (not 0)
=============== ====================================

Check fix for #1525713: Monitoring of HAProxy vips doesn't work when the backend name contains dots
===================================================================================================

=============== ====================================
Test Case ID    test_1525713
=============== ====================================
Steps           #. Log onto Fuel master
                #. Identify at least one controller
                   using command:

                   ``fuel nodes | grep controller``
                #. Identify which host is running
                   Zabbix server by launching the
                   following command on one of the
                   controller nodes identified in
                   step 2.

                   ``ssh node-2 crm resource status
                   p_zabbix-server``
                #. connect to the host returned in
                   step 3 and run the following:

                   ``ssh node-1``

                   ``ZBXIP=`ifconfig br-ex | grep
                   'inet addr:' | sed -e
                   's/[^:]\*://' -e 's/ .\*//'```

                   ``IP=`ifconfig br-mgmt \| grep
                   'inet addr:' \sed -e
                   's/[^:]\*://' -e 's/ .\*//'```

                   ``echo -e "listen test-vip\n\t
                   bind $ZBXIP:4444\n\t
                   option httpchk\n\t
                   option httplog\n\t
                   option httpclose\n\t
                   timeout server 600s\n\t
                   server $IP $IP:8774 check
                   inter 10s fastinter 2s
                   downinter 3s rise 3
                   fall 3"
                   >/etc/haproxy/conf.d/999-test-vip
                   .cfg``

                   ``crm resource restart
		   clone_p_haproxy``
                #. Log in to zabbix web
                #. Goto monitoring -> Dashboard ->
                   Controllers
                #. Wait a little for the new VIP to
                   be discovered
--------------- ------------------------------------
Expected Result One entry should appear with name
                'IP backend of test-vip proxy down'
                and with Status=OK [green] (not with
                Status=PROBLEM [red])
=============== ====================================

Check fix for #1478425: When stopping zabbix whole cluster goes down
====================================================================

=============== ====================================
Test Case ID    test_1478425
=============== ====================================
Steps           #. Log onto Fuel master
                #. Identify at least one controller
                   using command:

                   ``fuel nodes | grep controller``
                #. Identify which host is running
                   Zabbix server by launching the
                   following command on one of the
                   controller nodes identified in
                   step 2.

                   ``ssh node-2 crm resource status
                   p_zabbix-server``
                #. connect to the host returned in
                   step 3 and run the following:

                   ``ssh node-1
                   cibadmin --query | grep
                   vip_management | grep zabbix
                   | wc -l``
--------------- ------------------------------------
Expected Result Command should return 0 (previously
                was 1)
=============== ====================================

Check fix for #1513454: NTP Server service is down
==================================================

=============== ====================================
Test Case ID    test_1513454
=============== ====================================
Steps           #. Log onto Fuel master
                #. Identify at least one controller
                   using command:

                   ``fuel nodes | grep controller``
                #. On one of the controller nodes
                   identified in step 2, connect to
                   is and stop the ntp service

                   ``ssh node-2 crm resource stop
                   p_ntp``
                #. Log in to zabbix web
                #. Goto monitoring -> Dashboard
                #. Wait a little for the new alert
                   message ``NTP Server service is
                   down on node-2`` to arise
--------------- ------------------------------------
Expected Result There should be no alert in the
                first place, only after command in
                step 3 is launched, the alert should
                arise
=============== ====================================
