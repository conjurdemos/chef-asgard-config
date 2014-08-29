#
# Cookbook Name:: asgard-config
# Recipe:: default
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

chef_gem 'rest-client'
chef_gem 'netrc'

require 'yaml'
require 'netrc'

conjur_conf = YAML.load(File.read('/etc/conjur.conf'))
appliance_url = conjur_conf['appliance_url']
OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.add_file conjur_conf['cert_file']

login, api_key = Netrc.read["#{appliance_url}/authn"]

require 'rest-client'
require 'json'
require 'base64'

ENV['RESTCLIENT_LOG'] = 'stderr'

policy = node['conjur']['policy']

token = JSON::parse(RestClient::Resource.new(appliance_url)["authn/users/#{CGI.escape login}/authenticate"].post api_key, content_type: 'text/plain')

http_options = { headers: { authorization: "Token token=\"#{Base64.strict_encode64 token.to_json}\"" }, }

aws_access_key_id = RestClient::Resource.new(appliance_url, http_options)[%Q{variables/#{CGI.escape "#{policy}/aws/access_key_id"}/value}].get
aws_secret_access_key = RestClient::Resource.new(appliance_url, http_options)[%Q{variables/#{CGI.escape "#{policy}/aws/secret_access_key"}/value}].get

directory "/etc/asgard"

template "/etc/asgard/Config.groovy" do
  source "Config.groovy.erb"
  variables aws_access_key_id: aws_access_key_id, 
    aws_secret_access_key: aws_secret_access_key
end

