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

Puppet::Type.type(:plugin_zabbix_host).provide(:ruby,
                                        :parent => Puppet::Provider::Plugin_zabbix) do

  def get_group_ids
    groups = Array.new
    resource[:groups].each do |group|
      group_id = get_hostgroup(resource[:api], group)
      raise(Puppet::Error, "Group #{group} does not exist") unless not group_id.empty?
      groups.push({
        :groupid => group_id[0]["groupid"]
      })
    end
    groups
  end

  def get_host_data
    auth(resource[:api])
    result = get_host(resource[:api], resource[:name])
    result
  end

  def compare_groups
    new_groups = get_group_ids
    auth(resource[:api])
    result = get_host_data
    existing_groups = result[0]['groups']
    new_groups.map{|x| x[:groupid]}.sort == existing_groups.map{|x| x['groupid']}.sort
  end

  def exists?
    result = get_host_data
    if result.empty?
      false
    else
      compare_groups
    end
  end

  def create
    groups = get_group_ids
    host_data = get_host_data

    if host_data.empty?
      params = {:host => resource[:host],
                :status => resource[:status],
                :interfaces => [{:type => resource[:type] == nil ? "1" : resource[:type],
                                 :main =>1,
                                 :useip => resource[:ip] == nil ? 0 : 1,
                                 :usedns => resource[:ip] == nil ? 1 : 0,
                                 :dns => resource[:host],
                                 :ip => resource[:ip] == nil ? "" : resource[:ip],
                                 :port => resource[:port] == nil ? "10050" : resource[:port],}],
                :proxy_hostid => resource[:proxy_hostid] == nil ? 0 : resource[:proxy_hostid],
                :groups => groups}
      api_request(resource[:api], {:method => "host.create", :params => params})
    elsif not compare_groups
      hostid = get_host(resource[:api], resource[:name])[0]["hostid"]
      params = {:hostid => hostid, :groups => groups}
      api_request(resource[:api], {:method => "host.update", :params => params})
    end
  end

  def destroy
    hostid = get_host(resource[:api], resource[:name])[0]["hostid"]
    # deactivate before removing
    api_request(resource[:api],
                {:method => 'host.update',
                 :params => {:hostid => hostid,
                             :status => 1}})

    api_request(resource[:api],
                {:method => 'host.delete',
                 :params => [{:hostid => hostid}]})
  end
end
