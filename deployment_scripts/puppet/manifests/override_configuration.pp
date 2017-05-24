notice('zabbix_monitoring/override_configuration')

file { '/etc/hiera/plugins/zabbix_monitoring.yaml':
  ensure  => present,
  content => template('plugin_zabbix/config_override.erb'),
  owner   => root,
  group   => root,
  mode    => '0644',
}

