$LOAD_PATH.push(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/provider/plugin_zabbix'

Puppet::Type.type(:plugin_zabbix_hostgroup).provide(:ruby,
                                             :parent => Puppet::Provider::Plugin_zabbix) do

  def exists?
    auth(resource[:api])
    result = get_hostgroup(resource[:api], resource[:name])
    not result.empty?
  end

  def create
    api_request(resource[:api],
                {:method => "hostgroup.create",
                 :params => {:name => resource[:name]}})
  end

  def destroy
    groupid = get_hostgroup(resource[:api], resource[:name])[0]["groupid"]
    api_request(resource[:api],
                {:method => "hostgroup.delete",
                 :params => [groupid]})
  end
end
