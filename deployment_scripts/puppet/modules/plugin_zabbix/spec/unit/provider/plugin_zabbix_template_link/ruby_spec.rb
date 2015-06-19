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
require 'puppet/provider/plugin_zabbix_template_link/ruby'

cls = Puppet::Type.type(:plugin_zabbix_template_link).provider(:ruby)
fake_api = {"username" => "username",
            "password" => "password",
            "endpoint" => "http://endpoint"}
resource = Puppet::Type.type(:plugin_zabbix_template_link).new(:name => 'test link', :host => 'test', :template => 'test', :api => fake_api)
provider = resource.provider

describe cls do

  it 'should fail if provided host does not exist' do
    provider.expects(:auth).with(fake_api).returns("auth_hash")
    provider.expects(:get_host).returns([])
    expect {
      provider.exists?
    }.to raise_error(Puppet::Error, /Host.+?does not exist/)
  end

  it 'should fail if provided template does not exist' do
    provider.expects(:auth).with(fake_api).returns("auth_hash")
    provider.expects(:get_host).returns(['0'])
    provider.expects(:api_request).with(fake_api,
                                        {:method => "template.get",
                                         :params => {:filter => {:host => [resource[:template]]}}}).returns([])
    expect {
      provider.exists?
    }.to raise_error(Puppet::Error, /Template.+?does not exist/)
  end

end
