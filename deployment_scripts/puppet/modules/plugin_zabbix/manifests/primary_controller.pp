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
class plugin_zabbix::primary_controller {

  include plugin_zabbix::controller

  $fuel_version = 0 + hiera('fuel_version')

  keystone_user { $plugin_zabbix::params::openstack::access_user:
    ensure   => 'present',
    enabled  => true,
    password => $plugin_zabbix::params::openstack::access_password,
    email    => "${plugin_zabbix::params::openstack::access_user}@localhost",
  } ->
  keystone_user_role {"${plugin_zabbix::params::openstack::access_user}@${plugin_zabbix::params::openstack::access_tenant}":
    ensure => present,
    roles  => '_member_',
  }

  if $fuel_version < 9.0 {
    $next_service = Cs_resource["p_${plugin_zabbix::params::server_service}"]
  } else {
    $next_service = Pacemaker::Service["p_${plugin_zabbix::params::server_service}"]
  }

  class { 'plugin_zabbix::db::mysql':
    db_ip       => $plugin_zabbix::params::db_ip,
    db_password => $plugin_zabbix::params::db_password,
    require     => Package[$plugin_zabbix::params::server_pkg],
    before      => [ Class['plugin_zabbix::frontend'], $next_service ],
    }

  $operations = {
    'monitor' => {'interval' => '5s', 'timeout' => '30s' },
    'start'   => {'interval' => '0', 'timeout' => '30s' }
  }

  if $fuel_version < 9.0 {
    cs_resource { "p_${plugin_zabbix::params::server_service}":
      before          => Cs_rsc_colocation['vip-with-zabbix'],
      primitive_class => 'ocf',
      provided_by     => $plugin_zabbix::params::ocf_scripts_provider,
      primitive_type  => $plugin_zabbix::params::server_service,
      operations      => $operations,
      metadata        => {
        'migration-threshold' => '3',
        'failure-timeout'     => '120',
      },
    }

    cs_rsc_colocation { 'vip-with-zabbix':
      ensure     => present,
      score      => 'INFINITY',
      primitives => ["vip__${plugin_zabbix::params::vip_name}", "p_${plugin_zabbix::params::server_service}"],
    }

    File[$plugin_zabbix::params::server_config] -> File['zabbix-server-ocf'] -> Cs_resource["p_${plugin_zabbix::params::server_service}"]
    if $plugin_zabbix::controller::zabbix_pcmk_managed == '' {
      Service["${plugin_zabbix::params::server_service}-init-stopped"] -> Cs_resource["p_${plugin_zabbix::params::server_service}"]
    }
    Cs_rsc_colocation['vip-with-zabbix'] -> Service["${plugin_zabbix::params::server_service}-started"]
  } else {
    pacemaker::service { "p_${plugin_zabbix::params::server_service}":
      before             => Pcmk_colocation['vip-with-zabbix'],
      primitive_class    => 'ocf',
      primitive_provider => $plugin_zabbix::params::ocf_scripts_provider,
      primitive_type     => $plugin_zabbix::params::server_service,
      operations         => $operations,
      metadata           => {
        'migration-threshold' => '3',
        'failure-timeout'     => '120',
      },
      prefix             => false,
      use_handler        => false,
    }

    pcmk_colocation { 'vip-with-zabbix':
      ensure  => present,
      score   => 'INFINITY',
      second  => "vip__${plugin_zabbix::params::vip_name}",
      first   => "p_${plugin_zabbix::params::server_service}",
      require => Pacemaker::Service["p_${plugin_zabbix::params::server_service}"],
    }

    File[$plugin_zabbix::params::server_config] -> File['zabbix-server-ocf'] -> Pcmk_colocation['vip-with-zabbix']
    if $plugin_zabbix::controller::zabbix_pcmk_managed == '' {
      Service["${plugin_zabbix::params::server_service}-init-stopped"] -> Pcmk_colocation['vip-with-zabbix']
    }
    Pcmk_colocation['vip-with-zabbix'] -> Service["${plugin_zabbix::params::server_service}-started"]
  }
}
