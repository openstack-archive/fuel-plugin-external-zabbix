class plugin_zabbix::monitoring::glance_mon {

  include plugin_zabbix::params

  #Glance
  if defined_in_state(Class['glance::api']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Glance API":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Glance API',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Glance API check":
      host    => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Glance API check',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix::agent::userparameter {
      'glance.api.status':
        command => "/etc/zabbix/scripts/check_api.py glance http ${::internal_address} 9292";
    }
  }

  if defined_in_state(Class['glance::registry']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Glance Registry":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Glance Registry',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
