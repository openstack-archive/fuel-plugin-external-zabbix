class plugin_zabbix::monitoring::openvswitch_mon {

  include plugin_zabbix::params

  # Open vSwitch

  plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Open vSwitch":
    host => $plugin_zabbix::params::host_name,
    template => 'Template App OpenStack Open vSwitch',
    api => $plugin_zabbix::monitoring::api_hash,
  }
}
