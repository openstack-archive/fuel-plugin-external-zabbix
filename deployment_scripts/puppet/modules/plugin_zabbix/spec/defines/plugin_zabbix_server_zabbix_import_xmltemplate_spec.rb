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
require 'spec_helper'

describe 'plugin_zabbix::server::zabbix_import_xmltemplate', :type => :define  do

  let (:facts) do
    {
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu',
      :kernel          => 'Linux',
      :memoryfree_mb   => 1024,
    }
  end

  context 'with defaults' do
    let (:title) { 'zabbix_import_xmltemplate' }

    let (:default_params) do
      {
        :ensure => 'present',
      }
    end

    it { should compile }
    it 'should contain plugin_zabbix::server::zabbix_import_xmltemplate definition' do
      is_expected.to contain_plugin_zabbix__server__zabbix_import_xmltemplate(title).with(default_params)
    end
  end
end
