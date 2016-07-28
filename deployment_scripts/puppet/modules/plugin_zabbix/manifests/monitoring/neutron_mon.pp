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
class plugin_zabbix::monitoring::neutron_mon {

  include plugin_zabbix::params

  # Neutron server
  if defined_in_state(Class['::neutron']) and !defined_in_state(Class['nova::compute']) {

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron Server":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron Server',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron API check":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron API check',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix::agent::userparameter {
      'neutron.api.status':
        command => "/etc/zabbix/scripts/check_api.py neutron http ${::internal_address} 9696";
    }
  }

  # Neutron OVS agent
  if defined_in_state(Class[Neutron::Agents::Ml2::Ovs]) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron OVS Agent":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron OVS Agent',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  # Neutron Metadata agent
  if defined_in_state(Class['::neutron::agents::metadata']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron Metadata Agent":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron Metadata Agent',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  # Neutron L3 agent
  if defined_in_state(Class['::neutron::agents::l3']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron L3 Agent":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron L3 Agent',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  # Neutron DHCP agent
  if defined_in_state(Class['::neutron::agents::dhcp']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron DHCP Agent":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron DHCP Agent',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
