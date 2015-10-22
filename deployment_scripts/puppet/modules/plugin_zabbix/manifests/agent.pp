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
class plugin_zabbix::agent(
  $api_hash = undef,
) {

  include plugin_zabbix::params
  $roles     = hiera(roles)
  $settings = hiera(storage)
  $use_ceph = $settings['volumes_ceph']

  $zabbix_agent_port = $plugin_zabbix::params::zabbix_ports['backend_agent'] ? { unset=>$plugin_zabbix::params::zabbix_ports['agent'], default=>$plugin_zabbix::params::zabbix_ports['backend_agent'] }

  firewall { '997 zabbix agent':
    port   => $zabbix_agent_port,
    proto  => 'tcp',
    action => 'accept'
  }

  package { $plugin_zabbix::params::agent_pkg:
    ensure => present
  }
  ->
  file { $plugin_zabbix::params::agent_include:
    ensure => directory,
    mode   => '0500',
    owner  => 'zabbix',
    group  => 'zabbix'
  }
  ->
  file { $plugin_zabbix::params::agent_config:
    ensure  => present,
    content => template($plugin_zabbix::params::agent_config_template),
    notify  => Service[$plugin_zabbix::params::agent_service]
  }
  ->
  service { $plugin_zabbix::params::agent_service:
    ensure => running,
    enable => true,
  }

  if defined_in_state(Class['openstack::controller']){
    $ctrl_g = $plugin_zabbix::params::host_groups_ceph_controller
    if $use_ceph == true {
      $ctrl_ceph_g = $host_groups_ceph_controller
    }else{
      $ctrl_ceph_g = []
    }
  }else{
    $ctrl_g = []
    $ctrl_ceph_g = []
  }

  if defined_in_state(Class['openstack::compute']) {
    $compute_g = $plugin_zabbix::params::host_groups_compute
  }else{
    $compute_g = []
  }

  if member($roles, 'ceph-osd') {
    $osd_g = $plugin_zabbix::params::host_groups_ceph_osd
  }else{
    $osd_g = []
  }

  if $use_ceph == true and (member($roles, 'ceph-osd') or defined_in_state(Class['openstack::compute'])){
    $ceph_g = $plugin_zabbix::params::host_groups_ceph
  }else{
    $ceph_g = []
  }
  $groups = concat(concat(concat(concat(concat($plugin_zabbix::params::host_groups_base, $ctrl_g), $compute_g), $ctrl_ceph_g), $osd_g), $ceph_g)

  plugin_zabbix_host { $plugin_zabbix::params::host_name:
    host   => $plugin_zabbix::params::host_name,
    ip     => $plugin_zabbix::params::host_ip,
    groups => $groups,
    api    => $api_hash
  }
}
