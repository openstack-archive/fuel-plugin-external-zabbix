class plugin_zabbix::ha::haproxy {

  Haproxy::Service        { use_include => true }
  Haproxy::Balancermember { use_include => true }

  Plugin_zabbix::Ha::Haproxy_service {
    server_names        => filter_hash($::controllers, 'name'),
    ipaddresses         => filter_hash($::controllers, 'internal_address'),
    public_virtual_ip   => $::fuel_settings['public_vip'],
    internal_virtual_ip => $::fuel_settings['management_vip'],
  }

  plugin_zabbix::ha::haproxy_service { 'zabbix-agent':
    order               => '210',
    listen_port         => $plugin_zabbix::ports['agent'],
    balancermember_port => $plugin_zabbix::ports['backend_agent'],

    haproxy_config_options => {
      'option'         => ['tcpka'],
      'timeout client' => '48h',
      'timeout server' => '48h',
      'balance'        => 'roundrobin',
      'mode'           => 'tcp'
    },

    balancermember_options => 'check inter 5000 rise 2 fall 3',
  }

  plugin_zabbix::ha::haproxy_service { 'zabbix-server':
    order               => '200',
    listen_port         => $plugin_zabbix::ports['server'],
    balancermember_port => $plugin_zabbix::ports['backend_server'],

    haproxy_config_options => {
      'option'         => ['tcpka'],
      'timeout client' => '48h',
      'timeout server' => '48h',
      'balance'        => 'roundrobin',
      'mode'           => 'tcp'
    },

    balancermember_options => 'check inter 5000 rise 2 fall 3',
  }

  firewall { '998 zabbix agent vip':
    proto     => 'tcp',
    action    => 'accept',
    port      => $plugin_zabbix::ports['agent'],
  }

  firewall { '998 zabbix server vip':
    proto     => 'tcp',
    action    => 'accept',
    port      => $plugin_zabbix::ports['server'],
  }
}
