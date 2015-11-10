==================
Functional testing
==================

Check Zabbix deployment
=======================

Test ID:
* test_zabbix_deployment
* test_zabbix_started

Expected Result: Zabbix Started

Steps:

* Check that package zabbix-server installed on controllers
* Check that zabbix-server is started via `crm status`

Check Zabbix API
================

Test IDs:

* test_authentication_valid_cred
* test_authentication_invalid_cred
* test_https
* test_ssl_certificate

Expected Result: All steps passed

Steps:

* Test authentication with valid credentials
* Test if authentication impossible with invalid credentials
* Check HTTPS request to dashboard
* Check SSL certificate (self signed)

Check dashboard configuration
=============================

Test ID: test_graph

Expected Result: Dashboard is preconfigured

Steps:

* Log in to zabbix web
* Get zabbix/screens.php
* Check preconfigured graphs:

  * screen 'OpenStack Cluster'
  * screen 'Ceph' if Ceph is deployed

Check zabbix triggers
=====================

Test ID: test_triggers

Expected Result: All preconfigured triggers are present and `green`

Steps:

* Log in to zabbix UI
* Check on dashboard there is no alert: everything must be `green`

Check API triggers
==================

Test ID: test_trigger_api

Expected Result: The API is detected as down

Steps:

* Log into on controller node
* Stop an API (for example neutron)::

  # stop neutron-server

* On dashboard verify these alerts are present:

  * High severity

    * Neutron Server process is not running on nodeX
    * Neutron Server service is down on nodeX
    * Neutron API test failed on nodeX

  * Average severity

    * Neutron service status offline test failed
    * nodeX backend of neutron proxy down
