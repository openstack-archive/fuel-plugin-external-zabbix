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
include plugin_zabbix::params

$zabbix_hash = hiera('zabbix_monitoring')
$api_ip = hiera('management_vip')
$api_url = "http://${api_ip}:${plugin_zabbix::params::zabbix_ports['api']}${plugin_zabbix::params::frontend_base}/api_jsonrpc.php"
$api_hash = {
  endpoint => $api_url,
  username => $zabbix_hash['username'],
  password => $zabbix_hash['password'],
}

class { 'plugin_zabbix::server::config':
  api_hash => $api_hash,
}
