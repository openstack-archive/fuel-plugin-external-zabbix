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
require 'json'
require 'net/http'
class Puppet::Provider::Plugin_zabbix < Puppet::Provider

  @@auth_hash = ""

  def self.message_json(body)
    if body[:method] == "user.login"
      message = {
        :method => body[:method],
        :params => body[:params],
        :id => rand(9000),
        :jsonrpc => '2.0'
      }
    else
      message = {
        :method => body[:method],
        :params => body[:params],
        :auth => auth_hash,
        :id => rand(9000),
        :jsonrpc => '2.0'
      }
    end
    JSON.generate(message)
  end

  def self.make_request(api, body)
    uri = URI.parse(api["endpoint"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.add_field("Content-Type", "application/json-rpc")
    request.body = message_json(body)
    response = http.request(request)
    Puppet::debug("request = #{request.body}")
    Puppet::debug("response = #{response.body}")
    response.value
    result = JSON.parse(response.body)
    result
  end

  def self.api_request(api, body, retries=10)
    cooldown = 1
    Puppet.info("Trying to make a request to zabbix server, will try #{retries} times with #{cooldown} seconds between tries")
    retries.times do |r|
      begin
        Puppet.info("Retry ##{r}/#{retries}:")
        result = make_request(api, body)

        if result.has_key? "error"
          raise(Puppet::Error, "Zabbix API returned error code #{result["error"]["code"]}: #{result["error"]["message"]}, #{result["error"]["data"]}")
        end

        return result["result"]

      rescue => e
          if r == retries - 1
            Puppet.warning("Out of retries to make a request to zabbix server (#{retries})")
            raise e
          else
            Puppet.warning("Could not make request to zabbix: #{e}, sleeping #{cooldown*r} (retry (##{r}/#{retries}))")
            sleep(cooldown*r)
          end
      end
    end
  end

  def self.auth(api)
    body = {:method => "user.login",
            :params => {:user => api["username"],
                        :password => api["password"]}}
    @@auth_hash = api_request(api, body)
  end

  def auth(api)
    self.class.auth(api)
  end

  def api_request(api, body)
    self.class.api_request(api, body)
  end

  def self.auth_hash
    @@auth_hash
  end

  def auth_hash
    self.class.auth_hash
  end

  def self.get_host(api, name)
    Puppet::debug("gethost #{name}")
    api_request(api,
                {:method => "host.get",
                 :params => {:filter => {:name => [name]}}})
  end

  def self.get_hostgroup(api, name)
    Puppet::debug("gethostgroup #{name}")
    api_request(api,
                {:method => "hostgroup.get",
                 :params => {:filter => {:name => [name]}}})
  end

  def get_host(api, name)
    self.class.get_host(api, name)
  end

  def get_hostgroup(api, name)
    self.class.get_hostgroup(api, name)
  end

end
