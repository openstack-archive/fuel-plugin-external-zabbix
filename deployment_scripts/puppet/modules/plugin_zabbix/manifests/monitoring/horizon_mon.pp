class plugin_zabbix::monitoring::horizon_mon {

  include plugin_zabbix::params

  #Horizon
  if defined_in_state(Class['horizon']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Horizon":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Horizon',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
