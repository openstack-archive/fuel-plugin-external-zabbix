class plugin_zabbix::ha::haproxy {

  Haproxy::Service        { use_include => true }
  Haproxy::Balancermember { use_include => true }

  $public_vip = hiera('public_vip')
  $management_vip = hiera('management_vip')

  Plugin_zabbix::Ha::Haproxy_service {
    server_names        => filter_hash($::controllers, 'name'),
    ipaddresses         => filter_hash($::controllers, 'internal_address'),
    public_virtual_ip   => $public_vip,
    internal_virtual_ip => $management_vip,
  }

  plugin_zabbix::ha::haproxy_service { 'zabbix-agent':
    order                  => '210',
    listen_port            => $plugin_zabbix::ports['agent'],
    balancermember_port    => $plugin_zabbix::ports['backend_agent'],

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
    order                  => '200',
    listen_port            => $plugin_zabbix::ports['server'],
    balancermember_port    => $plugin_zabbix::ports['backend_server'],

    haproxy_config_options => {
      'option'         => ['tcpka'],
      'timeout client' => '48h',
      'timeout server' => '48h',
      'balance'        => 'roundrobin',
      'mode'           => 'tcp'
    },

    balancermember_options => 'check inter 5000 rise 2 fall 3',
  }

  file_line { 'add binding to management VIP for horizon and zabbix':
    path   => '/etc/haproxy/conf.d/015-horizon.cfg',
    after  => 'listen horizon',
    line   => "  bind ${management_vip}:80",
    before => Exec['haproxy reload'],
  }

  exec { 'haproxy reload':
    command   => 'export OCF_ROOT="/usr/lib/ocf"; (ip netns list | grep haproxy) && ip netns exec haproxy /usr/lib/ocf/resource.d/fuel/ns_haproxy reload',
    path      => '/usr/bin:/usr/sbin:/bin:/sbin',
    logoutput => true,
    provider  => 'shell',
    tries     => 10,
    try_sleep => 10,
    returns   => [0, ''],
  }

  Haproxy::Listen <||> -> Exec['haproxy reload']
  Haproxy::Balancermember <||> -> Exec['haproxy reload']

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
