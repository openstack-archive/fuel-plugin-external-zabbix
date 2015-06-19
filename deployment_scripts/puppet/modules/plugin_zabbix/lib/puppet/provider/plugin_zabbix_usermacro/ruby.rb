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
$LOAD_PATH.push(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/provider/plugin_zabbix'

Puppet::Type.type(:plugin_zabbix_usermacro).provide(:ruby,
                                        :parent => Puppet::Provider::Plugin_zabbix) do

  def exists?
    auth(resource[:api])
    macroid = nil
    if resource[:global] == :true
      result = api_request(resource[:api],
                           {:method => "usermacro.get",
                            :params => {:globalmacro => true,
                                        :output     => "extend"}})
      result.each { |macro| macroid = macro["globalmacroid"] if macro['macro'] == resource[:macro] }
    else
      hostid = get_host(resource[:api], resource[:host])
      raise(Puppet::Error, "Host #{resource[:host]} does not exist") unless not hostid.empty?
      result = api_request(resource[:api],
                           {:method => 'usermacro.get',
                            :params => {"hostids" => hostid[0]["hostid"],
                            :output => "extend"}})
      macroid = nil
      result.each { |macro| macroid = macro['hostmacroid'] if macro['macro'] == resource[:macro] }
    end
    not macroid.nil?
  end

  def create
    if resource[:global] == :true
      api_request(resource[:api],
                  {:method => 'usermacro.createglobal',
                   :params => {:macro  => resource[:macro],
                               :value  => resource[:value]}})
    else
      hostid = get_host(resource[:api], resource[:host])
      api_request(resource[:api],
                  {:method => 'usermacro.create',
                   :params => {:macro => resource[:macro],
                               :value => resource[:value],
                               :hostid => hostid[0]["hostid"]}})
    end
  end

  def destroy
    macroid = nil
    if resource[:global] == :true
      result = api_request(resource[:api],
                           {:method => 'usermacro.get',
                            :params => {:globalmacro => true,
                                        :output      => "extend"}})
      result.each { |macro| macroid = macro['globalmacroid'] if macro['macro'] == resource[:macro] }
      api_request(resource[:api],
                  {:method => 'usermacro.deleteglobal',
                   :params => [macroid]})
    else
      hostid = get_host(resource[:api], resource[:host])
      result = api_request(resource[:api],
                           {:method => 'usermacro.get',
                            :params => {:hostids => hostid[0]["hostid"],
                                       :output  => "extend"}})
      result.each { |macro| macroid = macro['hostmacroid'] if macro['macro'] == resource[:macro] }
      api_request(resource[:api],
                  {:method => 'usermacro.delete',
                   :params => [macroid]})
    end
  end

  def value
    #get value
    macrovalue = nil
    if resource[:global] == :true
      result = api_request(resource[:api],
                           {:method => 'usermacro.get',
                            :params => {:globalmacro => true,
                                        :output => "extend"}})
      result.each { |macro| macrovalue = macro['value'] if macro['macro'] == resource[:macro] }
    else
      hostid = get_host(resource[:api], resource[:host])
      result = api_request(resource[:api],
                           {:method => 'usermacro.get',
                            :params => {:hostids => hostid[0]["hostid"],
                                        :output  => "extend"}})
      result.each { |macro| macrovalue = macro['value'] if macro['macro'] == resource[:macro] }
    end
    macrovalue
  end

  def value=(v)
    #set value
    macroid = nil
    if resource[:global] == :true
      result = api_request(resource[:api],
                           {:method => 'usermacro.get',
                            :params => {:globalmacro => true,
                                        :output      => "extend"}})
      result.each { |macro| macroid = macro['globalmacroid'].to_i if macro['macro'] == resource[:macro] }
      api_request(resource[:api],
                  {:method => 'usermacro.updateglobal',
                   :params => {:globalmacroid => macroid,
                               :value         => resource[:value]}})
    else
      hostid = get_host(resource[:api], resource[:host])
      result = api_request(resource[:api],
                           {:method => 'usermacro.get',
                            :params => {:hostids => hostid[0]["hostid"],
                                        :output  => "extend"}})
      result.each { |macro| macroid = macro['hostmacroid'].to_i if macro['macro'] == resource[:macro] }
      api_request(resource[:api],
                  {:method => 'usermacro.update',
                   :params => {:hostmacroid => macroid,
                               :value       => resource[:value]}})
    end
  end

end
