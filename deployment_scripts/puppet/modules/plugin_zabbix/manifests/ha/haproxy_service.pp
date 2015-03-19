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
# Register a service with HAProxy
define plugin_zabbix::ha::haproxy_service (
  $order,
  $server_names,
  $ipaddresses,
  $listen_port,
  $public_virtual_ip,
  $internal_virtual_ip,

  $mode                   = undef,
  $haproxy_config_options = { 'option' => ['httplog'], 'balance' => 'roundrobin' },
  $balancermember_options = 'check',
  $balancermember_port    = $listen_port,
  $define_cookies         = false,

  # use active-passive failover, mark all backends except the first one
  # as backups
  $define_backups         = false,

  # by default, listen only on internal VIP
  $public                 = false,
  $internal               = true,

  # if defined, restart this service before registering it with HAProxy
  $require_service        = undef,

  # if true, configure this service before starting the haproxy service;
  # HAProxy will refuse to start with no listening services defined
  $before_start           = false,
) {

  if $public and $internal {
    $virtual_ips = [$public_virtual_ip, $internal_virtual_ip]
  } elsif $internal {
    $virtual_ips = [$internal_virtual_ip]
  } elsif $public {
    $virtual_ips = [$public_virtual_ip]
  }

  haproxy::listen { $name:
    order     => $order,
    ipaddress => $virtual_ips,
    ports     => $listen_port,
    options   => $haproxy_config_options,
    mode      => $mode,
  }

  haproxy::balancermember { $name:
    order             => $order,
    listening_service => $name,
    server_names      => $server_names,
    ipaddresses       => $ipaddresses,
    ports             => $balancermember_port,
    options           => $balancermember_options,
    define_cookies    => $define_cookies,
    define_backups    => $define_backups,
  }

  if $require_service {
    Service[$require_service] -> Haproxy::Listen[$name]
    Service[$require_service] -> Haproxy::Balancermember[$name]
  }
}
