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

Puppet::Type.newtype(:plugin_zabbix_host) do
  desc <<-EOT
    Manage a host in Zabbix
  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:host, :namevar => true) do
    desc 'Technical name of the host.'
    newvalues(/.+/)
  end

  newparam(:ip) do
    desc <<-EOT
      IP of the host.

      Set this for the default interface to be
      ip based. Use zabbix_host_interface to add
      additional interfaces if you want dns on
      the main agent and an ip for others.
    EOT
    isrequired
    newvalues(/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/)
  end

  newparam(:type) do
    desc <<-EOT
      Zabbix host type.
      1 - ip interface
      2 - snmp interface
      ...
    EOT
  end

  newparam(:port) do
    desc <<-EOT
      Port of the host.

    EOT
    newvalues(/^[0-9]{1,5}$/)
  end

  newparam(:groups) do
    desc 'Host groups to add the host to.'
    isrequired

    validate do |value|
      fail("groups is not an array") unless value.kind_of?(Array) or value.kind_of?(String)
      if value.kind_of?(String) then
        value = [value]
      end
      # Puppet stdlib concat() function append empty array by empty string
      value.reject!{|i| i.empty?}
      fail("groups array is empty") if value.empty?
      value.each do |item|
        fail("group name is not a string") unless item.kind_of?(String)
        fail("group name is empty") unless item =~ /.+/
      end
    end
  end

  newparam(:hostname) do
    desc 'Visible name of the host.'

    validate do |value|
        raise(Puppet::Error, 'Invalid value') unless value.kind_of?(String)
    end
    newvalues(/.+/)
  end

  newparam(:proxy_hostid) do
    desc 'ID of the proxy that is used to monitor the host.'

    validate do |value|
      fail("proxy_hostid is not an integer or integer string") unless value.kind_of?(Integer) or value =~ /[0-9]+/
    end
  end

  newparam(:status) do
    desc <<-EOT
      Status and function of the host.

      Possible values are:
      * 0 - (default) monitored host;
      * 1 - unmonitored host.
    EOT
    newvalues(0, 1)
    defaultto 0
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

end
