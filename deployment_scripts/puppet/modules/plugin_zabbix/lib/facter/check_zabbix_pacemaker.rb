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

# check_zabbix_pacemaker.rb

Facter.add('check_zabbix_pacemaker') do
  setcode do
    crm_cmd = Facter::Util::Resolution.exec('/bin/which crm')
    if crm_cmd.nil? then
      ''
    else
      crm_res = Facter::Util::Resolution.exec(crm_cmd + ' status | grep zabbix' )
    end
  end
end
