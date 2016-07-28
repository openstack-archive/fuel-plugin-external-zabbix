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
class plugin_zabbix::monitoring::nova_mon {

  include plugin_zabbix::params

  $fuel_version = 0 + hiera('fuel_version')

  if $fuel_version < 8.0 {
    $cur_node_roles = node_roles(hiera_array('nodes'), hiera('uid'))
    $is_controller  = member($cur_node_roles, 'controller') or
                      member($cur_node_roles, 'primary-controller')
  } else {
    $is_controller = roles_include(['controller', 'primary-controller'])
  }

  # Nova (controller)
  if $is_controller {

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova API":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova API',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova API OSAPI":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova API OSAPI',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova API OSAPI check":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova API OSAPI check',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    # Removed in MOS 9.0
    if $fuel_version < 8.0 {
      plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova API EC2":
        host     => $plugin_zabbix::params::host_name,
        template => 'Template App OpenStack Nova API EC2',
        api      => $plugin_zabbix::monitoring::api_hash,
      }
    }

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova Cert":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova Cert',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix::agent::userparameter {
      'nova.api.status':
        command => "/etc/zabbix/scripts/check_api.py nova_os http ${::internal_address} 8774";
    }
  }

  #Nova (compute)
  if defined_in_state(Class['nova::compute']) {

    if ! hiera('quantum',false) {
      plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova API Metadata":
        host     => $plugin_zabbix::params::host_name,
        template => 'Template App OpenStack Nova API Metadata',
        api      => $plugin_zabbix::monitoring::api_hash,
      }
      plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova Network":
        host     => $plugin_zabbix::params::host_name,
        template => 'Template App OpenStack Nova Network',
        api      => $plugin_zabbix::monitoring::api_hash,
      }
    }
  }

  if defined_in_state(Class['nova::consoleauth']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova ConsoleAuth":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova ConsoleAuth',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if defined_in_state(Class['nova::scheduler']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova Scheduler":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova Scheduler',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if defined_in_state(Class['nova::conductor']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova Conductor":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova Conductor',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if defined_in_state(Class['nova::vncproxy']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova novncproxy":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova novncproxy',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  #Nova compute
  if defined_in_state(Class['nova::compute']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Nova Compute":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova Compute',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  #Libvirt
  if defined_in_state(Class['nova::compute::libvirt']) {
    plugin_zabbix_template_link { "${::fqdn} Template App OpenStack Libvirt":
      host     => $::fqdn,
      template => 'Template App OpenStack Libvirt',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
