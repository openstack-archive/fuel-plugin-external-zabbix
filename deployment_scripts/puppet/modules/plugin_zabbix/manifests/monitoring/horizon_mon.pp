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
class plugin_zabbix::monitoring::horizon_mon {

  include plugin_zabbix::params
  include apache::params

  #Horizon
  if defined_in_state(Class['horizon']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Horizon":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Horizon',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_usermacro { 'Apache bin name':
        host  => $plugin_zabbix::params::host_name,
        macro => '{$APACHE_NAME}',
        value => $apache::params::apache_name,
        api   => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_usermacro { 'Apache user':
        host  => $plugin_zabbix::params::host_name,
        macro => '{$APACHE_USER}',
        value => $apache::params::user,
        api   => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
