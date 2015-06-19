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
require 'puppet'
require 'spec_helper'
require 'puppet/provider/plugin_zabbix_host/ruby'

cls = Puppet::Type.type(:plugin_zabbix_host).provider(:ruby)
fake_api = {"username" => "username",
            "password" => "password",
            "endpoint" => "http://endpoint"}
resource = Puppet::Type.type(:plugin_zabbix_host).new(:name => 'test', :host => 'test', :groups => ['test'], :ip => '192.168.0.1', :api => fake_api)
provider = resource.provider

describe cls do

  it 'should fail to create a zabbix host if any of provided groups do not exist' do
    provider.expects(:get_hostgroup).returns([])
    expect {
      provider.create
    }.to raise_error(Puppet::Error, /Group.+?does not exist/)
  end

end
