class plugin_zabbix::monitoring(
  $api_ip,
  $server_vip,
  $server_ips,
  $db_ip,
  $ports = { api => '80', agent => '10050', backend_agent => undef },
  $username = 'admin',
  $password = 'zabbix',
  $db_password = 'zabbix',
) {

  include plugin_zabbix::params

  $api_url = "http://${api_ip}:${ports['api']}${plugin_zabbix::params::frontend_base}/api_jsonrpc.php"
  $api_hash = { endpoint => $api_url,
                username => $username,
                password => $password }

  plugin_zabbix_usermacro { "$plugin_zabbix::params::host_name IP_PUBLIC":
    host  => $plugin_zabbix::params::host_name,
    macro => '{$IP_PUBLIC}',
    value => $::public_address,
    api   => $api_hash,
  }

  plugin_zabbix_usermacro { "$plugin_zabbix::params::host_name IP_MANAGEMENT":
    host  => $plugin_zabbix::params::host_name,
    macro => '{$IP_MANAGEMENT}',
    value => $::internal_address,
    api   => $api_hash,
  }

  plugin_zabbix_usermacro { "$plugin_zabbix::params::host_name IP_STORAGE":
    host  => $plugin_zabbix::params::host_name,
    macro => '{$IP_STORAGE}',
    value => $::swift_address,
    api   => $api_hash,
  }

  Anchor<| title == 'zabbix_agent_end' |> -> Anchor<| title == 'zabbix_agent_scripts_begin' |>

  class { 'plugin_zabbix::agent':
    api_hash => $api_hash,
  }
  anchor { 'zabbix_agent_begin': } -> Class['plugin_zabbix::agent'] -> anchor { 'zabbix_agent_end': }

  class { 'plugin_zabbix::agent::scripts': }
  anchor { 'zabbix_agent_scripts_begin': } -> Class['plugin_zabbix::agent::scripts'] -> anchor { 'zabbix_agent_scripts_end': }

  plugin_zabbix::agent::userparameter {
    'vfs.dev.discovery':
      ensure => 'present',
      command => '/etc/zabbix/scripts/vfs.dev.discovery.sh';
    'vfs.mdadm.discovery':
      ensure => 'present',
      command => '/etc/zabbix/scripts/vfs.mdadm.discovery.sh';
    'proc.vmstat':
      key => 'proc.vmstat[*]',
      command => 'grep \'$1\' /proc/vmstat | awk \'{print $$2}\'';
    'crm.node.check':
      key     => 'crm.node.check[*]',
      command => '/etc/zabbix/scripts/crm_node_check.sh $1';
  }

  #Linux
  plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template Fuel OS Linux":
    host => $plugin_zabbix::params::host_name,
    template => 'Template Fuel OS Linux',
    api => $api_hash,
  }

  #Zabbix Agent
  plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App Zabbix Agent":
    host => $plugin_zabbix::params::host_name,
    template => 'Template App Zabbix Agent',
    api => $api_hash,
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
}
