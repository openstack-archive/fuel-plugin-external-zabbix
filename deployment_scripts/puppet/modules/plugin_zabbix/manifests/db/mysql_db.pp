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
define plugin_zabbix::db::mysql_db (
  $user,
  $password,
  $charset     = 'utf8',
  $host        = 'localhost',
  $grant       = 'all',
  $sql         = '',
  $enforce_sql = false
) {

  database { $name:
    ensure   => present,
    charset  => $charset,
    provider => 'mysql',
  }

  database_user { "${user}@${host}":
    ensure        => present,
    password_hash => mysql_password($password),
    provider      => 'mysql',
    require       => Database[$name],
  }

  database_grant { "${user}@${host}/${name}":
    privileges => $grant,
    provider   => 'mysql',
    require    => Database_user["${user}@${host}"],
  }

  $refresh = ! $enforce_sql

  if $sql {
    exec{ "${name}-import":
      command     => "/usr/bin/mysql ${name} < ${sql}",
      logoutput   => true,
      refreshonly => $refresh,
      require     => Database_grant["${user}@${host}/${name}"],
      subscribe   => Database[$name],
    }
  }

}

