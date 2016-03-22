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

  include phpfpm
  include plugin_zabbix::params

  service { $plugin_zabbix::params::frontend_service:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  package { $plugin_zabbix::params::frontend_pkg:
    ensure  => present,
    require => [
      File['/etc/dbconfig-common/zabbix-server-mysql.conf'],
      Package[$plugin_zabbix::params::php_fpm_pkg],
      Package[$plugin_zabbix::params::php_mysql_pkg],
      Package[$plugin_zabbix::params::apache_fcgi_pkg]
    ],
  }

  package { $plugin_zabbix::params::php_common_pkg:
    ensure => present
  }

  package { $plugin_zabbix::params::apache_fcgi_pkg:
    ensure => present
  }

  package { $plugin_zabbix::params::php_mysql_pkg:
    ensure => present
  }

  file { $plugin_zabbix::params::frontend_config:
    ensure  => present,
    content => template($plugin_zabbix::params::frontend_config_template),
    notify  => Service[$plugin_zabbix::params::frontend_service],
    require => Package[$plugin_zabbix::params::frontend_pkg],
  }

  # do not use prefork as it is incompatible with MOS 8.0 / Liberty
  # So need to enable a few more Apache modules to work with PHP-FPM
  # and mod worker
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
      # Activate all modules required by $frontend_service_template
      exec { 'enable-apache-actions':
        command => 'a2enmod actions',
        path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }

      exec { 'enable-apache-rewrite':
        command => 'a2enmod rewrite',
        path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }

      exec { 'enable-apache-expires':
        command => 'a2enmod expires',
        path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }

      exec { 'enable-apache-fastcgi':
        command => 'a2enmod fastcgi',
        path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }

      # Cleanup existing default pools
      phpfpm::pool { 'www':
        ensure => 'absent',
      }

      # Create Zabbix TCP pool using 127.0.0.1, port 9000, upstream defaults
      phpfpm::pool { 'zabbix':
        listen    => '127.0.0.1:9000',
        require   => Package[$plugin_zabbix::params::php_fpm_pkg],
        notify    => Service[$plugin_zabbix::params::php_fpm_service],
        php_value => {
          'date.timezone'       => 'UTC',
          'memory_limit'        => '256M',
          'max_execution_time'  => '300',
          'post_max_size'       => '16M',
          'upload_max_filesize' => '2M',
          'max_input_time'      => '300',
        },
      }

      file_line { 'set expose_php to off':
        path    => $plugin_zabbix::params::php_config,
        match   => 'expose_php =',
        line    => 'expose_php = Off',
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

      # Apache configuration from template
      file { $plugin_zabbix::params::frontend_service_config:
        ensure  => present,
        content => template($plugin_zabbix::params::frontend_service_template),
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }
    }
    default: {}
  }
}
