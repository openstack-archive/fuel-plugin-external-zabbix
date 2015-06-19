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
    :defined_in_state,
    :type => :rvalue,
    :doc => 'Returns True when resource is defined in state.yaml file'
) do |args|

  yaml_file = '/var/lib/puppet/state/state.yaml'

  raise(Puppet::ParseError, "defined_in_state(): Wrong number of arguments " +
    "given (#{args.size} for 1)") if args.size != 1

  resource = args[0]

  begin
    yaml = YAML.load_file(yaml_file)
    if ! yaml["#{resource}"].nil?
      return true
    end
  rescue Exception => e
    Puppet.warning("#{e}")
  end

  return false
end
