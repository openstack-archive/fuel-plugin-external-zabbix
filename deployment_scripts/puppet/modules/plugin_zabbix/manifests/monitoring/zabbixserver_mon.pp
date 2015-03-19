class plugin_zabbix::monitoring::zabbixserver_mon {

  if defined_in_state(Class['plugin_zabbix::server']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App Zabbix Server":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App Zabbix Server',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

}
