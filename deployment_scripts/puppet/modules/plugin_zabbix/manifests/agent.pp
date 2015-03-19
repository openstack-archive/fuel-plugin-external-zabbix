class plugin_zabbix::agent(
  $api_hash = undef,
) {

  include plugin_zabbix::params

  $zabbix_agent_port = $plugin_zabbix::monitoring::ports['backend_agent'] ? { unset=>$plugin_zabbix::monitoring::ports['agent'], default=>$plugin_zabbix::monitoring::ports['backend_agent'] }

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
    $groups = union($plugin_zabbix::params::host_groups_base, $plugin_zabbix::params::host_groups_controller)
  } elsif defined_in_state(Class['openstack::compute']) {
    $groups = union($plugin_zabbix::params::host_groups_base, $plugin_zabbix::params::host_groups_compute)
  } else {
    $groups = $plugin_zabbix::params::host_groups_base
  }

  plugin_zabbix_host { $plugin_zabbix::params::host_name:
    host   => $plugin_zabbix::params::host_name,
    ip     => $plugin_zabbix::params::host_ip,
    groups => $groups,
    api    => $api_hash
  }
}
