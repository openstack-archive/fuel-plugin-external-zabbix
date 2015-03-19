class plugin_zabbix::monitoring::memcached_mon {

  include plugin_zabbix::params

  if defined_in_state(Class['memcached']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App Memcache":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App Memcache',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix::agent::userparameter {
      'memcache':
        key     => 'memcache[*]',
        command => "/bin/echo -e \"stats\\nquit\" | nc ${plugin_zabbix::params::host_ip} 11211 | grep \"STAT \$1 \" | awk \'{print \$\$3}\'"
    }
  }
}
