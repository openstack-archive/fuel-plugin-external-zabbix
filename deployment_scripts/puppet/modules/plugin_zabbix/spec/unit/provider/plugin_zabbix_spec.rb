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
require 'puppet/provider/plugin_zabbix'

cls = Puppet::Provider::Plugin_zabbix

describe Puppet::Provider::Plugin_zabbix do

  describe 'when making an API request' do

    it 'should fail if Zabbix returns error' do
      mock = {'error' => {'code' => 0,
                          'message' => 'test error',
                          'data' => 'not a real error'}}
      Puppet::Provider::Plugin_zabbix.expects(:make_request).at_least(2).returns(mock)
      fake_api = {'endpoint' => 'http://localhost',
                  'username' => 'Admin',
                  'password' => 'zabbix'}
      expect {
        cls.api_request(fake_api, {}, 2)
      }.to raise_error(Puppet::Error, /Zabbix API returned/)
    end

    it 'should return "result" sub-hash from json returned by API' do
      mock = {'result' => {'code' => 0,
                          'message' => 'test result',
                          'data' => 'just a test'}}
      Puppet::Provider::Plugin_zabbix.expects(:make_request).returns(mock)
      fake_api = {'endpoint' => 'http://localhost',
                  'username' => 'Admin',
                  'password' => 'zabbix'}
      cls.api_request(fake_api, {}) == {'code' => 0,
                                        'message' => 'test result',
                                        'data' => 'just a test'}
    end

  end

end
