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
class plugin_zabbix::frontend {

  include plugin_zabbix::params

  service { $plugin_zabbix::params::frontend_service:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  package { $plugin_zabbix::params::frontend_pkg:
    ensure    => present,
  }

  file { $plugin_zabbix::params::frontend_config:
    ensure    => present,
    content   => template($plugin_zabbix::params::frontend_config_template),
    notify    => Service[$plugin_zabbix::params::frontend_service],
    require   => Package[$plugin_zabbix::params::frontend_pkg],
  }

  file_line { 'php timezone':
    path      => $plugin_zabbix::params::frontend_service_config,
    line      => '    php_value date.timezone UTC',
    match     => 'php_value date.timezone',
    notify    => Service[$plugin_zabbix::params::frontend_service],
    require   => Package[$plugin_zabbix::params::frontend_pkg],
  }

  file_line { 'set expose_php to off':
    path      => $plugin_zabbix::params::php_config,
    match     => 'expose_php =',
    line      => 'expose_php = Off',
    notify    => Service[$plugin_zabbix::params::frontend_service],
    require   => Package[$plugin_zabbix::params::frontend_pkg],
  }

  # disable worker MPM, use prefork MPM which is required by mod_php:
  case $::osfamily {
    'RedHat': {
      # default line: "HTTPD=/usr/sbin/httpd.worker"
      # target line:  "HTTPD=/usr/sbin/httpd"
      # we need to remove .worker suffix (to disable mpm_worker)
      # match parameter must match the common part of default and target lines
      file_line { 'httpd_mpm_prefork':
        path    => '/etc/sysconfig/httpd',
        line    => 'HTTPD=/usr/sbin/httpd',
        match   => '^HTTPD=/usr/sbin/httpd',
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }
    }
    'Debian': {
      file { '/etc/apache2/mods-enabled/worker.conf':
        ensure  => absent,
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }
      file { '/etc/apache2/mods-enabled/worker.load':
        ensure  => absent,
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }
    }
    default: {}
  }

  # postinst script in zabbix-frontend-php package creates an invalid symlink
  # hack: in debconf disable apache configuration and restarting
  #       and create the symlink manually then restart apache
  case $::osfamily {
    'Debian': {
      exec { 'configure zabbix-frontend-php package':
        command  => 'echo "zabbix-frontend-php zabbix-frontend-php/configure-apache boolean false\nzabbix-frontend-php zabbix-frontend-php/restart-webserver boolean false" | debconf-set-selections',
        provider => 'shell',
        before   => Package[$plugin_zabbix::params::frontend_pkg],
      }
      file { '/etc/apache2/conf.d/zabbix.conf':
        ensure   => link,
        target   => $plugin_zabbix::params::frontend_service_config,
        notify   => Service[$plugin_zabbix::params::frontend_service],
        require  => Package[$plugin_zabbix::params::frontend_pkg],
      }
    }
    default: {}
  }
}
