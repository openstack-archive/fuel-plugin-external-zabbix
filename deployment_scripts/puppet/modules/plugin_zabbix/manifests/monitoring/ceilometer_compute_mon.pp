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
class plugin_zabbix::monitoring::ceilometer_compute_mon {

  include plugin_zabbix::params

  #Ceilometer
  if defined_in_state(Class['Ceilometer::Agent::Compute']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceilometer Compute":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceilometer Compute',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }
}
