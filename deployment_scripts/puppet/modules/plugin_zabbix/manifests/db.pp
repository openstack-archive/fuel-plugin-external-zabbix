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
class plugin_zabbix::db(
  $db_ip       = undef,
  $db_password = 'zabbix',
  $sync_db     = false
) {
  #stub for multiple possible db backends
  class { 'plugin_zabbix::db::mysql':
    db_ip       => $db_ip,
    db_password => $db_password,
    sync_db     => $sync_db,
  }
  anchor { 'zabbix_mysql_start': } -> Class['plugin_zabbix::db::mysql'] -> anchor { 'zabbix_mysql_end': }
}
