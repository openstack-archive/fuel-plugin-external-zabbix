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

define plugin_zabbix::server::zabbix_import_xmltemplate (
  $base_dir = undef,
  $api = undef,
  $ensure = 'present'
) {

  include plugin_zabbix::params

  if $base_dir {
    $_base_dir = $base_dir
  } else {
    $_base_dir = $plugin_zabbix::params::zabbix_import_dir
  }
  if $api {
    $_api = $api
  } else {
    $_api = $plugin_zabbix::params::api_hash
  }
  validate_string($title)
  validate_string($_base_dir)
  validate_string($ensure)
  validate_hash($_api)
  validate_absolute_path($_base_dir)

  plugin_zabbix_configuration_import { "${title}.xml Import":
    ensure   => $ensure,
    xml_file => "${_base_dir}/${title}.xml",
    api      => $_api,
  }
}
