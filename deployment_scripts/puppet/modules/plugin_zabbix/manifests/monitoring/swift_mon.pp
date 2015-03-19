class plugin_zabbix::monitoring::swift_mon {

  include plugin_zabbix::params

  #Swift
  if defined_in_state(Class['openstack::swift::storage_node']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Swift Account":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Account',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Swift Container":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Container',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Swift Object":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Object',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if defined_in_state(Class['swift::proxy']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Swift Proxy":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Swift Proxy',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
