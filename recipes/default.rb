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

require 'conjur/cli'
require 'conjur/config'
require 'conjur/authn'

Conjur::Config.load [ '/etc/conjur.conf' ]
Conjur::Config.apply

policy = node.conjur.policy

conjur = Conjur::Authn.connect nil, noask: true

directory "/etc/asgard"

template "/etc/asgard/Config.groovy" do
  source "Config.groovy.erb"
  variables aws_access_key_id: conjur.variable("#{policy}/aws/access_key_id").value,
    aws_secret_access_key: conjur.variable("#{policy}/aws/secret_access_key").value
end

