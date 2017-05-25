#
#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
class plugin_zabbix::ha::haproxy {

  include openstack::ha::haproxy_restart

  Haproxy::Service        { use_include => true }
  Haproxy::Balancermember { use_include => true }
  Haproxy::Listen         { use_include => true }

  $public_vip = hiera('public_vip')
  $ssl = hiera('public_ssl')
  $zabbix_vip = $plugin_zabbix::params::server_ip
  $mgmt_vip = $plugin_zabbix::params::mgmt_vip
  $network_metadata  = hiera_hash('network_metadata')
  $primary_controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-controller'])
  $controllers = get_nodes_hash_by_roles($network_metadata, ['primary-controller', 'controller'])
  $server_names = keys($controllers)
  $ipaddresses = values(get_node_to_ipaddr_map_by_network_role($controllers, 'management'))
  Plugin_zabbix::Ha::Haproxy_service {
    server_names        => $server_names,
    ipaddresses         => $ipaddresses,
    public_virtual_ip   => $public_vip,
    internal_virtual_ip => $zabbix_vip,
  }

  plugin_zabbix::ha::haproxy_service { 'zabbix-agent':
    order                  => '210',
    listen_port            => $plugin_zabbix::params::zabbix_ports['agent'],
    balancermember_port    => $plugin_zabbix::params::zabbix_ports['backend_agent'],
    haproxy_config_options => {
      'option'         => ['tcpka'],
      'timeout client' => '48h',
      'timeout server' => '48h',
      'balance'        => 'roundrobin',
      'mode'           => 'tcp'
    },
    balancermember_options => 'check inter 5000 rise 2 fall 3',
    notify                 => Exec['haproxy-restart'],
  }

  $horizon_is_here = defined_in_state(Class['openstack::ha::horizon'])

  # Always configure HTTPS if a certificate is available
  $use_ssl = $ssl[horizon] or $ssl[services]

  # Defaults for any haproxy_service within this class
  # This is used only when horizon is not deployed on controllers
  Openstack::Ha::Haproxy_service {
    internal_virtual_ip => $zabbix_vip,
    ipaddresses         => $ipaddresses,
    public_virtual_ip   => $public_vip,
    server_names        => $server_names,
    public              => true,
    internal            => true,
  }

  if $use_ssl {
    if $horizon_is_here {
      if $ssl[horizon] {
        # Update Horizon configuration to be able to use HTTPS port
        file_line { 'add binding to Zabbix VIP for horizon and zabbix via ssl':
          path   => '/etc/haproxy/conf.d/017-horizon-ssl.cfg',
          after  => 'listen horizon-ssl',
          line   => "  bind ${zabbix_vip}:443 ssl crt /var/lib/astute/haproxy/public_haproxy.pem",
          notify => Exec['haproxy-restart']
        }
        ->
        file_line { 'add binding to management VIP for horizon and zabbix via ssl':
          path   => '/etc/haproxy/conf.d/017-horizon-ssl.cfg',
          after  => 'listen horizon-ssl',
          line   => "  bind ${mgmt_vip}:443 ssl crt /var/lib/astute/haproxy/public_haproxy.pem",
          notify => Exec['haproxy-restart']
        }
      } else {
        # Update Horizon configuration to be able to use HTTP port
        file_line { 'add binding to Zabbix VIP for horizon and zabbix':
          path   => '/etc/haproxy/conf.d/015-horizon.cfg',
          after  => 'listen horizon',
          line   => "  bind ${zabbix_vip}:80",
          notify => Exec['haproxy-restart']
        }
        ->
        file_line { 'add binding to management VIP for horizon and zabbix':
          path   => '/etc/haproxy/conf.d/015-horizon.cfg',
          after  => 'listen horizon',
          line   => "  bind ${mgmt_vip}:80",
          notify => Exec['haproxy-restart']
        }
      }
    } else {
      openstack::ha::haproxy_service { 'zabbix-ui':
        order                  => '211',
        listen_port            => 80,
        server_names           => undef,
        ipaddresses            => undef,
        haproxy_config_options => {
          'redirect' => 'scheme https if !{ ssl_fc }'
        },
      }
      openstack::ha::haproxy_service { 'zabbix-ui-ssl':
        order                  => '212',
        listen_port            => 443,
        balancermember_port    => 80,
        public_ssl             => true,
        public_ssl_path        => '/var/lib/astute/haproxy/public_haproxy.pem',
        haproxy_config_options => {
          'option'      => ['forwardfor', 'httpchk', 'httpclose', 'httplog'],
          'stick-table' => 'type ip size 200k expire 30m',
          'stick'       => 'on src',
          'balance'     => 'source',
          'timeout'     => ['client 3h', 'server 3h'],
          'mode'        => 'http',
          'reqadd'      => 'X-Forwarded-Proto:\ https',
        },
        balancermember_options => 'weight 1 check',
        # The internal binding is configured below because the certificate
        # is not configured by this resource
        internal               => false,
      }
      ->
      file_line { 'add binding to Zabbix VIP for zabbix via ssl':
        path   => '/etc/haproxy/conf.d/212-zabbix-ui-ssl.cfg',
        after  => 'listen zabbix-ui-ssl',
        line   => "  bind ${zabbix_vip}:443 ssl crt /var/lib/astute/haproxy/public_haproxy.pem",
        notify => Exec['haproxy-restart'],
      }
      ->
      file_line { 'add binding to management VIP for zabbix via ssl':
        path   => '/etc/haproxy/conf.d/212-zabbix-ui-ssl.cfg',
        after  => 'listen zabbix-ui-ssl',
        line   => "  bind ${mgmt_vip}:443 ssl crt /var/lib/astute/haproxy/public_haproxy.pem",
        notify => Exec['haproxy-restart'],
      }
    }
  } else {
    if $horizon_is_here {
      # Update Horizon configuration to be able to use HTTP port
      file_line { 'add binding to Zabbix VIP for horizon and zabbix':
        path   => '/etc/haproxy/conf.d/015-horizon.cfg',
        after  => 'listen horizon',
        line   => "  bind ${zabbix_vip}:80",
        notify => Exec['haproxy-restart']
      }
    } else {
      openstack::ha::haproxy_service { 'zabbix-ui':
        order                  => '211',
        listen_port            => 80,
        define_cookies         => true,
        internal               => true,
        haproxy_config_options => {
          'option'  => ['forwardfor', 'httpchk', 'httpclose', 'httplog'],
          'rspidel' => '^Set-cookie:\ IP=',
          'balance' => 'source',
          'mode'    => 'http',
          'cookie'  => 'SERVERID insert indirect nocache',
          'capture' => 'cookie vgnvisitor= len 32',
          'timeout' => ['client 3h', 'server 3h'],
        },
        balancermember_options => 'check inter 2000 fall 3',
      }
    }
  }
}
