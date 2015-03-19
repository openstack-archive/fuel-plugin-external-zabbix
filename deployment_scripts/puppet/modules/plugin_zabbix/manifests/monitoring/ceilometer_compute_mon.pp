class plugin_zabbix::monitoring::ceilometer_compute_mon {

  include plugin_zabbix::params

  #Ceilometer
  if defined_in_state(Class['Ceilometer::Agent::Compute']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Ceilometer Compute":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceilometer Compute',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
