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
require 'puppet/util/filetype'
require 'digest/md5'

Puppet::Type.newtype(:plugin_zabbix_configuration_import) do
  desc <<-EOT
    Import Zabbix configuration from a file.
  EOT

  ensurable
  # do
  #   defaultvalues
  #   defaultto :present
  # end

  newparam(:name, :namevar => true) do
    desc 'Name of import.'
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

  newproperty(:xml_file) do
    desc 'xml file'
    isrequired

    validate do |value|
      unless Pathname.new(value).absolute?
        fail("Invalid xml_file path #{value}")
      end
    end

    def insync?(is)
      xml_file_content = Puppet::Util::FileType.filetype(:flat).new(value).read
      if is == Digest::MD5.hexdigest(xml_file_content)
        true
      else
        false
      end
    end

  end

  autorequire(:file) do
    [@parameters[:xml_file]]
  end

end
