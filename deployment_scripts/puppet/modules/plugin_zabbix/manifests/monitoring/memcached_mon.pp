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
class plugin_zabbix::monitoring::memcached_mon {

  include plugin_zabbix::params

  if defined_in_state(Class['memcached']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App Memcache":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App Memcache',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix::agent::userparameter {
      'memcache':
        key     => 'memcache[*]',
        command => "/bin/echo -e \"stats\\nquit\" | nc ${plugin_zabbix::params::host_ip} 11211 | grep \"STAT \$1 \" | awk \'{print \$\$3}\'"
    }
  }
}
