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

  $fuel_version = 0 + hiera('fuel_version')

  if $fuel_version < 8.0 {
    $cur_node_roles = node_roles(hiera_array('nodes'), hiera('uid'))
    $is_controller  = member($cur_node_roles, 'controller') or
                      member($cur_node_roles, 'primary-controller')
  } else {
    $is_controller = roles_include(['controller', 'primary-controller'])
  }

  $zabbix_agent_port = $plugin_zabbix::params::zabbix_ports['backend_agent'] ? {
    unset=>$plugin_zabbix::params::zabbix_ports['agent'],
    default=>$plugin_zabbix::params::zabbix_ports['backend_agent'],
  }

  firewall { '997 zabbix agent':
    port   => $zabbix_agent_port,
    proto  => 'tcp',
    action => 'accept'
  }

  package { $plugin_zabbix::params::agent_pkg:
    ensure => present
  } ->
  package { $plugin_zabbix::params::sender_pkg:
    ensure => present
  } ->
  package { $plugin_zabbix::params::get_pkg:
    ensure => present
  } ->
  file { $plugin_zabbix::params::agent_include:
    ensure => directory,
    mode   => '0500',
    owner  => 'zabbix',
    group  => 'zabbix'
  } ->
  file { $plugin_zabbix::params::agent_config:
    ensure  => present,
    content => template($plugin_zabbix::params::agent_config_template),
    notify  => Service[$plugin_zabbix::params::agent_service]
  } ->
  service { $plugin_zabbix::params::agent_service:
    ensure => running,
    enable => true,
  }

  if $is_controller {
    $groups = union($plugin_zabbix::params::host_groups_base, $plugin_zabbix::params::host_groups_controller)
  } elsif defined_in_state(Class['nova::compute']) {
    $groups = union($plugin_zabbix::params::host_groups_base, $plugin_zabbix::params::host_groups_compute)
  } else {
    $groups = $plugin_zabbix::params::host_groups_base
  }

  if defined_in_state(Class['ceph::osds']){
    $ceph_osd_group = $plugin_zabbix::params::host_groups_ceph_osd
    $ceph_osd_used = true
  } else {
    $ceph_osd_group = []
    $ceph_osd_used = false
  }

  if defined_in_state(Class['ceph::mon']){
    $ceph_mon_group = $plugin_zabbix::params::host_groups_ceph_mon
    $ceph_mon_used = true
  } else {
    $ceph_mon_group = []
    $ceph_mon_used = false
  }

  if $ceph_osd_used or $ceph_mon_used {
    $ceph_cluster_group = $plugin_zabbix::params::host_groups_ceph_cluster
  } else {
    $ceph_cluster_group = []
  }

  if ! empty($ceph_cluster_group){
    $all_groups = parseyaml(
      inline_template('<%= @groups.concat(@ceph_mon_group).concat(@ceph_osd_group).concat(@ceph_cluster_group).to_yaml %>')
    )
  } else {
    $all_groups = $groups
  }

  plugin_zabbix_host { $plugin_zabbix::params::host_name:
    host   => $plugin_zabbix::params::host_name,
    ip     => $plugin_zabbix::params::host_ip,
    groups => $all_groups,
    api    => $api_hash
  }
}
