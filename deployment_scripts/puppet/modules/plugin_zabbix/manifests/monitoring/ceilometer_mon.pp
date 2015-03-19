class plugin_zabbix::monitoring::ceilometer_mon {

  include plugin_zabbix::params

  #Ceilometer
  if defined_in_state(Class['Ceilometer']) and defined_in_state(Class['Openstack::Controller']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Ceilometer":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceilometer',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
