#
# Cookbook Name:: asgard-config
# Recipe:: host
#
# Copyright 2014, Kevin Gilpin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unless File.exists?("/root/.netrc")
  require 'net/https'
  require 'openssl'
  require 'cgi'
  require 'uri'
  require 'yaml'
  require 'json'

  conjur_conf = YAML.load(File.read('/etc/conjur.conf'))
  appliance_url = conjur_conf['appliance_url']
  OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.add_file conjur_conf['cert_file']

  policy  = node['conjur']['policy']
  token   = node['conjur']['host_factory_token']
  headers = {'Content-Type' =>'application/json', 'Authorization' => "Token token=\"#{token}\"" }
  host_id = "#{policy}/#{node.name}"
  uri = URI.parse [ appliance_url, "host_factories/hosts" ].join('/')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new uri.path, headers
  req.body = { id: host_id }.to_json
  res = http.request req
  raise "Failed to create host, status = #{res.code}, message = #{res.body}" if res.code.to_i >= 300
  host = JSON.parse res.body

  File.write('/root/.netrc', <<-BODY)
machine #{appliance_url}/authn
  login host/#{host['id']}
  password #{host['api_key']}
BODY
  File.chmod '/root/.netrc', '0600'
end

