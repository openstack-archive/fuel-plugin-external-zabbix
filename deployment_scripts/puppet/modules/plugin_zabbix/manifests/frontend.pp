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

  $cgi_activation_str = sprintf('%s\n%s\n%s\n%s\n%s%s\n%s\n',
    '<IfModule mod_fastcgi.c>',
    '  AddHandler fastcgi-php5-fpm .php php phar',
    '  Action fastcgi-php5-fpm /fastcgi-php5-fpm virtual',
    "  Alias /fastcgi-php5-fpm ${plugin_zabbix::params::zabbix_document_root}/fastcgi-php5-fpm",
    "  FastCgiExternalServer ${plugin_zabbix::params::zabbix_document_root}/fastcgi-php5-fpm",
    '  -host 127.0.0.1:9000 -idle-timeout 900 -pass-header Authorization -pass-header Range',
    '</IfModule>')

  $cgi_exec_str = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n',
    '  <IfModule authz_core_module>',
    '    # Only when redirected internally by FastCGI.',
    '    Require env REDIRECT_STATUS',
    '    Options +ExecCGI',
    '  </IfModule>',
    '  Require all granted')

  service { $plugin_zabbix::params::frontend_service:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  service { $plugin_zabbix::params::php_fpm_service:
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

  package { $plugin_zabbix::params::php_fpm_pkg:
    ensure  => present,
    require => Package[$plugin_zabbix::params::php_common_pkg],
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

      file_line { 'set php_fpm local listener':
        path    => $plugin_zabbix::params::php_fpm_config,
        match   => 'listen =',
        line    => 'listen = 127.0.0.1:9000',
        require => Package[$plugin_zabbix::params::php_fpm_pkg],
      }

      file_line { 'php timezone':
        ensure  => present,
        path    => $plugin_zabbix::params::php_fpm_config,
        line    => 'php_value[date.timezone] = UTC',
        require => File_line['set php_fpm local listener'],
      }

      file_line { 'php memory_limit':
        ensure  => present,
        path    => $plugin_zabbix::params::php_fpm_config,
        line    => 'php_value[memory_limit] = 256M',
        notify  => Service[$plugin_zabbix::params::php_fpm_service],
        require => File_line['php timezone'],
      }

      file_line { 'set expose_php to off':
        path    => $plugin_zabbix::params::php_config,
        match   => 'expose_php =',
        line    => 'expose_php = Off',
        notify  => Service[$plugin_zabbix::params::php_fpm_service],
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

      # Do not modify the file contained by the package
      # Make a copy to work on but do not put it right away in the
      # Apache configuration directory else it will produce errors
      file { $plugin_zabbix::params::frontend_service_tmp_cfg:
        ensure  => present,
        source  => $plugin_zabbix::params::frontend_service_template,
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }

      file_line { 'remove php_value lines':
        ensure            => absent,
        path              => $plugin_zabbix::params::frontend_service_tmp_cfg,
        line              => 'php_value',
        match             => 'php_value .*',
        replace           => false,
        match_for_absence => true,
        multiple          => true,
        require           => File[$plugin_zabbix::params::frontend_service_tmp_cfg],
      }

      # Need to escape slashes in path
      $p = regsubst($plugin_zabbix::params::zabbix_document_root, '/', '\\/', 'G')

      # Adding FastCGI directive before Zabbix Directory directive
      $cmd1 = "sed -i -e '/<Directory \"${p}\">/i\\${cgi_activation_str}'"
      exec { 'configure zabbix-UI-1':
        command  => "${cmd1} ${plugin_zabbix::params::frontend_service_tmp_cfg}",
        provider => 'shell',
        require  => File_line['remove php_value lines'],
      }

      # Adding PHP handling directive within Zabbix Directory directive
      $cmd2 = "sed -i -e '/<Directory \"${p}\">/a\\${cgi_exec_str}'"
      exec { 'configure zabbix-UI-2':
        command  => "${cmd2} ${plugin_zabbix::params::frontend_service_tmp_cfg}",
        provider => 'shell',
        require  => Exec['configure zabbix-UI-1'],
      }

      # Now that the file contents is correct, we can put this
      # configuration into Apache
      # Make a copy to work on but do not put it right away in the
      # Apache configuration directory else it will produce errors
      file { $plugin_zabbix::params::frontend_service_config:
        ensure  => present,
        source  => $plugin_zabbix::params::frontend_service_tmp_cfg,
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Exec['configure zabbix-UI-2'],
      }

      $cmd3 = sprintf('%s | %s | %s | %s >> %s',
        "grep php_value ${plugin_zabbix::params::frontend_service_template}",
        'sed -e "s/^\s*//"',
        'egrep -v "^#|memory_limit"',
        'awk \'{printf "%s[%s] = %s\n",$1,$2,$3}\'',
        $plugin_zabbix::params::php_fpm_config)
      exec { 'configure zabbix-UI-3':
        command  => $cmd3,
        provider => 'shell',
        notify   => Service[$plugin_zabbix::params::php_fpm_service],
      }
    }
    default: {}
  }
}
