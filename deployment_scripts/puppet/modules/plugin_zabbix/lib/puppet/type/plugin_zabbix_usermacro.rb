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
Puppet::Type.newtype(:plugin_zabbix_usermacro) do
  desc <<-EOT
    Manage a macro in Zabbix.
  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'namevar'
    newvalues(/.+/)
  end

  newparam(:api) do
    desc 'Zabbix api info: endpoint, username, password.'
    isrequired

    validate do |value|
      fail("api is not a hash") unless value.kind_of?(Hash)
      fail("api hash does not contain username") unless value.has_key?("username")
      fail("username is not valid") unless value['username'] =~ /.+/
      fail("api hash does not contain password") unless value.has_key?("password")
      fail("password is not valid") unless value['password'] =~ /.+/
      fail("api hash does not contain endpoint") unless value.has_key?("endpoint")
      fail("endpoint is not valid") unless value['endpoint'] =~ /http(s)?:\/\/.+/
    end
  end

  newparam(:macro) do
    desc 'Macro name'
    isrequired
    newvalues(/.+/)
  end

  newproperty(:value) do
    desc 'Macro value'
    isrequired
    newvalues(/.+/)
  end

  newparam(:global) do
    desc <<-EOT
      Macro global flag. If true macro is global.
      If false macro belongs to host/template.
    EOT
    defaultto(:false)
    newvalues(:true, :false)
  end

  newparam(:host) do
    desc 'Host'
    newvalues(/.+/)
  end

  validate do
    fail('host should not be provided when global is true') if
    self[:global] == :true and not self[:host].nil?
    fail('host is required when global is false') if
    self[:global] == :false and self[:host].nil?
  end
end

