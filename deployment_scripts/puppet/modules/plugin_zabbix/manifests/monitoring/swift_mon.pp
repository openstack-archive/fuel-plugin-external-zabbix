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
class plugin_zabbix::monitoring::swift_mon {

  include plugin_zabbix::params

  $fuel_version = 0 + hiera('fuel_version')

  if $fuel_version < 8.0 {
    $swift_class_name = 'openstack::swift::storage_node'
  } else {
    $swift_class_name = 'openstack_tasks::swift::parts::storage_node'
  }

  #Swift
  if defined_in_state(Class[$swift_class_name]) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Swift Account":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Account',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Swift Container":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Container',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Swift Object":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Object',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if defined_in_state(Class['swift::proxy']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Swift Proxy":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Proxy',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
