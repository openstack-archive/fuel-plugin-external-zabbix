class plugin_zabbix::monitoring::keystone_mon {

  include plugin_zabbix::params

  #Keystone
  if defined_in_state(Class['keystone']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Keystone":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Keystone',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Keystone API check":
      host    => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Keystone API check',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix::agent::userparameter {
      'keystone.api.status':
        command => "/etc/zabbix/scripts/check_api.py keystone http ${::internal_address} 5000";
      'keystone.service.api.status':
        command => "/etc/zabbix/scripts/check_api.py keystone_service http ${::internal_address} 35357";
    }
  }
}
