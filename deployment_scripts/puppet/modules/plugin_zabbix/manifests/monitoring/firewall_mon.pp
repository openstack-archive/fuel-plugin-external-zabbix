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
class plugin_zabbix::monitoring::firewall_mon {

  include plugin_zabbix::params

  #Iptables stats
  if defined_in_state(Class['firewall']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App Iptables Stats":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App Iptables Stats',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
    package { 'iptstate':
      ensure => present;
    }
    plugin_zabbix::agent::userparameter {
      'iptstate.tcp':
        command => 'sudo iptstate -1 | grep tcp | wc -l';
      'iptstate.tcp.syn':
        command => 'sudo iptstate -1 | grep SYN | wc -l';
      'iptstate.tcp.timewait':
        command => 'sudo iptstate -1 | grep TIME_WAIT | wc -l';
      'iptstate.tcp.established':
        command => 'sudo iptstate -1 | grep ESTABLISHED | wc -l';
      'iptstate.tcp.close':
        command => 'sudo iptstate -1 | grep CLOSE | wc -l';
      'iptstate.udp':
        command => 'sudo iptstate -1 | grep udp | wc -l';
      'iptstate.icmp':
        command => 'sudo iptstate -1 | grep icmp | wc -l';
      'iptstate.other':
        command => 'sudo iptstate -1 -t | head -2 |tail -1 | sed -e \'s/^.*Other: \(.*\) (.*/\1/\''
    }
  }
}
