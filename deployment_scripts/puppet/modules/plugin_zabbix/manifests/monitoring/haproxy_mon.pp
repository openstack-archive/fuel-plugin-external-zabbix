class plugin_zabbix::monitoring::haproxy_mon {

  include plugin_zabbix::params

  if defined_in_state(Class['haproxy']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App HAProxy":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App HAProxy',
      api => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix::agent::userparameter {
      'haproxy.be.discovery':
        key     => 'haproxy.be.discovery',
        command => '/etc/zabbix/scripts/haproxy.sh -b';
      'haproxy.be':
        key     => 'haproxy.be[*]',
        command => '/etc/zabbix/scripts/haproxy.sh -v $1';
      'haproxy.fe.discovery':
        key     => 'haproxy.fe.discovery',
        command => '/etc/zabbix/scripts/haproxy.sh -f';
      'haproxy.fe':
        key     => 'haproxy.fe[*]',
        command => '/etc/zabbix/scripts/haproxy.sh -v $1';
      'haproxy.sv.discovery':
        key     => 'haproxy.sv.discovery',
        command => '/etc/zabbix/scripts/haproxy.sh -s';
      'haproxy.sv':
        key     => 'haproxy.sv[*]',
        command => '/etc/zabbix/scripts/haproxy.sh -v $1';
    }
  }
}
