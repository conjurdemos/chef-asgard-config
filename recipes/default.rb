#
# Cookbook Name:: asgard
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

if node['asgard']['aws_account_names'].kind_of?(Array)
  aws_account_names = Hash[*node['asgard']['aws_account_names']]
else
  aws_account_names = node['asgard']['aws_account_names']
end

directory "/etc/asgard"

template "/etc/asgard/Config.groovy" do
  source "Config.groovy.erb"
  variables aws_account_names: aws_account_names
  notifies :restart, resources(service: "tomcat")
end
