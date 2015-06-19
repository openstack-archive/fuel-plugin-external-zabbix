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
require 'digest/md5'

Puppet::Type.type(:plugin_zabbix_template_link).provide(:ruby,
                                                 :parent => Puppet::Provider::Plugin_zabbix) do

  def get_ids_by_host(hostid)
    results = []
    api_request(resource[:api],
                {:method => "template.get",
                 :params => {:hostids => [hostid]}}).each do |template|
      results << template["templateid"]
    end
    results
  end

  def exists?
    auth(resource[:api])
    hostid = get_host(resource[:api], resource[:host])
    raise(Puppet::Error, "Host #{resource[:host]} does not exist") unless not hostid.empty?
    templateid = api_request(resource[:api],
                             {:method => "template.get",
                              :params => {:filter => {:host => [resource[:template]]}}})
    raise(Puppet::Error, "Template #{resource[:template]} does not exist") unless not templateid.empty?

    get_ids_by_host(hostid[0]["hostid"]).include?(templateid[0]["templateid"])
  end

  def create
    hostid = get_host(resource[:api], resource[:host])
    templateid = api_request(resource[:api],
                             {:method => "template.get",
                              :params => {:filter => {:host => [resource[:template]]}}})
    api_request(resource[:api],
                {:method => "template.massAdd",
                 :params => {:hosts => [{:hostid => hostid[0]["hostid"]}],
                             :templates => [{:templateid => templateid[0]["templateid"]}]}})
  end

  def destroy
    hostid = get_host(resource[:api], resource[:host])
    templateid = api_request(resource[:api],
                             {:method => "template.get",
                              :params => {:filter => {:host => [resource[:template]]}}})
    api_request(resource[:api],
                {:method => "template.massRemove",
                 :params => {:hostids => [hostid[0]["hostid"]],
                             :templateids => templateid[0]["templateid"]}})
  end
end
