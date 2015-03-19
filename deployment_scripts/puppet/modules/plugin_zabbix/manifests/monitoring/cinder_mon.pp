class plugin_zabbix::monitoring::cinder_mon {

  include plugin_zabbix::params

  #Cinder
  if defined_in_state(Class['cinder::api']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Cinder API":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Cinder API',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Cinder API check":
      host    => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Cinder API check',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix::agent::userparameter {
      'cinder.api.status':
        command => "/etc/zabbix/scripts/check_api.py cinder http ${::internal_address} 8776";
    }
  }

  if defined_in_state(Class['cinder::scheduler']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Cinder Scheduler":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Cinder Scheduler',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if defined_in_state(Class['cinder::volume']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Cinder Volume":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Cinder Volume',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
