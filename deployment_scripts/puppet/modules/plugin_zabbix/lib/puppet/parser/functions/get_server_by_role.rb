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
Puppet::Parser::Functions::newfunction(
    :get_server_by_role,
    :type => :rvalue,
    :doc => 'Returns server node hash by role'
) do |args|
  fuel_nodes = args[0]
  requested_roles = args[1]
  server = ""
  fuel_nodes.each do |node|
    next unless requested_roles.include?(node['role'])
    server = node
  end
  server
end

