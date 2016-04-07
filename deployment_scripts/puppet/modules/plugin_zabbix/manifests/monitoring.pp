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
class plugin_zabbix::monitoring(
  $server_ips  = undef,
  $roles_nb = 1,
  $has_role_baseos = false,
  $has_role_virt   = false,
  $has_role_controller = false,
) {

  # This should evaluate to false on base-os or virt only nodes
  # and therefore Zabbix should not be installed neither configured in this case
  $zabbix_agent_not_supported = ($has_role_baseos or $has_role_virt) and ($roles_nb == 1)

  if $zabbix_agent_not_supported {
    notice('Skipping Zabbix configuration for base-os or virt only host')
  } else {
    include plugin_zabbix::params

    $api_hash = $plugin_zabbix::params::api_hash

    if !defined(Package['snmp-mibs-downloader']) {
      package { 'snmp-mibs-downloader':
        ensure => 'present',
      }
    }

    if is_ip_address($::public_address) {
      plugin_zabbix_usermacro { "${plugin_zabbix::params::host_name} IP_PUBLIC":
        host  => $plugin_zabbix::params::host_name,
        macro => '{$IP_PUBLIC}',
        value => $::public_address,
        api   => $api_hash,
      }
    }

    if is_ip_address($::internal_address) {
      plugin_zabbix_usermacro { "${plugin_zabbix::params::host_name} IP_MANAGEMENT":
        host  => $plugin_zabbix::params::host_name,
        macro => '{$IP_MANAGEMENT}',
        value => $::internal_address,
        api   => $api_hash,
      }
    }

    if is_ip_address($::swift_address) {
      plugin_zabbix_usermacro { "${plugin_zabbix::params::host_name} IP_STORAGE":
        host  => $plugin_zabbix::params::host_name,
        macro => '{$IP_STORAGE}',
        value => $::swift_address,
        api   => $api_hash,
      }
    }

    class { 'plugin_zabbix::agent':
      api_hash => $api_hash,
      before   => Class['plugin_zabbix::agent::scripts'],
    }

    class { 'plugin_zabbix::agent::scripts': }

    plugin_zabbix::agent::userparameter {
      'vfs.dev.discovery':
        ensure  => 'present',
        command => '/etc/zabbix/scripts/vfs.dev.discovery.sh';
      'vfs.mdadm.discovery':
        ensure  => 'present',
        command => '/etc/zabbix/scripts/vfs.mdadm.discovery.sh';
      'proc.vmstat':
        key     => 'proc.vmstat[*]',
        command => 'grep \'$1\' /proc/vmstat | awk \'{print $$2}\'';
      'crm.node.check':
        key     => 'crm.node.check[*]',
        command => '/etc/zabbix/scripts/crm_node_check.sh $1';
      'netns.udp.listen':
        key     => 'netns.udp.listen[*]',
        command => '/usr/bin/sudo /etc/zabbix/scripts/netns.listen.sh UDP $1 $2 $3';
    }

    #Linux
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template Fuel OS Linux":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template Fuel OS Linux',
      api      => $api_hash,
    }

    if ! $has_role_controller {
      # default way to check NTP binding
      plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template NTP binding":
        host     => $plugin_zabbix::params::host_name,
        template => 'Template NTP binding',
        api      => $api_hash,
      }
    } else {
      plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template OS Controller":
        host     => $plugin_zabbix::params::host_name,
        template => 'Template OS Controller',
        api      => $api_hash,
      }
    }

    #Zabbix Agent
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App Zabbix Agent":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App Zabbix Agent',
      api      => $api_hash,
    }

    Plugin_zabbix_usermacro { require => Class['plugin_zabbix::agent'] }
    Plugin_zabbix_template_link { require => Class['plugin_zabbix::agent'] }

    # Auto-registration
    include plugin_zabbix::monitoring::nova_mon
    include plugin_zabbix::monitoring::keystone_mon
    include plugin_zabbix::monitoring::glance_mon
    include plugin_zabbix::monitoring::cinder_mon
    include plugin_zabbix::monitoring::swift_mon
    include plugin_zabbix::monitoring::rabbitmq_mon
    include plugin_zabbix::monitoring::horizon_mon
    include plugin_zabbix::monitoring::mysql_mon
    include plugin_zabbix::monitoring::memcached_mon
    include plugin_zabbix::monitoring::haproxy_mon
    include plugin_zabbix::monitoring::zabbixserver_mon
    include plugin_zabbix::monitoring::openstack_virtual_mon
    include plugin_zabbix::monitoring::neutron_mon
    include plugin_zabbix::monitoring::openvswitch_mon
    include plugin_zabbix::monitoring::ceilometer_mon
    include plugin_zabbix::monitoring::ceilometer_compute_mon
    include plugin_zabbix::monitoring::ceph_mon
    include plugin_zabbix::monitoring::firewall_mon
  }
}
