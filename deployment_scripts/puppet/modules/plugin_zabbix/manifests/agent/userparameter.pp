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
define plugin_zabbix::agent::userparameter (
  $ensure   = present,
  $command  = undef,
  $key      = undef,
  $index    = undef,
  $file     = undef,
  $template = 'plugin_zabbix/zabbix_agent_userparam.conf.erb'
) {

  include plugin_zabbix::params

  $key_real = $key ? {
    undef   => $name,
    default => $key
  }

  $index_real = $index ? {
    undef => '',
    default => "${index}_",
  }

  $file_real = $file ? {
    undef   => "${::plugin_zabbix::params::agent_include}/${index_real}${name}.conf",
    default => $file,
  }

  file { $file_real:
    ensure  => $ensure,
    content => template($template),
    notify  => Service[$plugin_zabbix::params::agent_service]
  }
}
