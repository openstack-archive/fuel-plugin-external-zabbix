class plugin_zabbix::monitoring::firewall_mon {

  include plugin_zabbix::params

  #Iptables stats
  if defined_in_state(Class['firewall']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App Iptables Stats":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App Iptables Stats',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    package { 'iptstate':
      ensure => present;
    }
    plugin_zabbix::agent::userparameter {
      'iptstate.tcp':
        command => 'sudo iptstate -1 | grep tcp | wc -l';
      'iptstate.tcp.syn':
        command => 'sudo iptstate -1 | grep SYN | wc -l';
      'iptstate.tcp.timewait':
        command => 'sudo iptstate -1 | grep TIME_WAIT | wc -l';
      'iptstate.tcp.established':
        command => 'sudo iptstate -1 | grep ESTABLISHED | wc -l';
      'iptstate.tcp.close':
        command => 'sudo iptstate -1 | grep CLOSE | wc -l';
      'iptstate.udp':
        command => 'sudo iptstate -1 | grep udp | wc -l';
      'iptstate.icmp':
        command => 'sudo iptstate -1 | grep icmp | wc -l';
      'iptstate.other':
        command => 'sudo iptstate -1 -t | head -2 |tail -1 | sed -e \'s/^.*Other: \(.*\) (.*/\1/\''
    }
  }
}
