#
#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
class plugin_zabbix::monitoring::openstack_virtual_mon {

  include plugin_zabbix::params

  $fuel_version = 0 + hiera('fuel_version')

  if $fuel_version < 8.0 {
    $cur_node_roles = node_roles(hiera_array('nodes'), hiera('uid'))
    $is_controller  = member($cur_node_roles, 'controller') or
                      member($cur_node_roles, 'primary-controller')
  } else {
    $is_controller = roles_include(['controller', 'primary-controller'])
  }

  if $is_controller {
    plugin_zabbix::agent::userparameter {
      'db.token.count.query':
        command => '/etc/zabbix/scripts/query_db.py token_count';
      'db.instance.error.query':
        command => '/etc/zabbix/scripts/query_db.py instance_error';
      'db.services.offline.nova.query':
        command => '/etc/zabbix/scripts/query_db.py services_offline_nova';
      'db.services.offline.neutron.query':
        command => '/etc/zabbix/scripts/query_db.py services_offline_neutron';
      'db.instance.count.query':
        command => '/etc/zabbix/scripts/query_db.py instance_count';
      'db.cpu.total.query':
        command => '/etc/zabbix/scripts/query_db.py cpu_total';
      'db.cpu.used.query':
        command => '/etc/zabbix/scripts/query_db.py cpu_used';
      'db.ram.total.query':
        command => '/etc/zabbix/scripts/query_db.py ram_total';
      'db.ram.used.query':
        command => '/etc/zabbix/scripts/query_db.py ram_used';
      'db.services.offline.cinder.query':
        command => '/etc/zabbix/scripts/query_db.py services_offline_cinder';
      'vip.nova.api.status':
        command => "/etc/zabbix/scripts/check_api.py nova_os http ${::plugin_zabbix::params::openstack::nova_vip} 8774";
      'vip.glance.api.status':
        command => "/etc/zabbix/scripts/check_api.py glance http ${::plugin_zabbix::params::openstack::glance_vip} 9292";
      'vip.keystone.api.status':
        command => "/etc/zabbix/scripts/check_api.py keystone http ${::plugin_zabbix::params::openstack::keystone_vip} 5000";
      'vip.keystone.service.api.status':
        command => "/etc/zabbix/scripts/check_api.py keystone_service http ${::plugin_zabbix::params::openstack::keystone_vip} 5000";
      'vip.cinder.api.status':
        command => "/etc/zabbix/scripts/check_api.py cinder http ${::plugin_zabbix::params::openstack::cinder_vip} 8776";
    }
  }
}
