#
# Author:: Luke Kosewski (<luke@pagerduty.com>)
# Cookbook Name:: sumologic
# Definition:: sumo_source
#
# Copyright 2012, PagerDuty, Inc.
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

define :sumo_source, :path => nil do
  p = ruby_block "sumologic: #{params[:name]}-enqueue" do
    block do
      if params[:name] !~ /^[a-z][A-Za-z0-9_]*$/
        raise Chef::Exceptions::ValidationFailed,
              "Sumo source #{params[:name]} doesn't match ^[a-z][A-Za-z0-9_]*$!"
      end
      if params[:path].nil?  # FIXME: This should validate SumoLogic path exps?
        raise Chef::Exceptions::ValidationFailed,
              'Sumo sources need a non-nil path (try defining it!)'
      end
      if !node.run_state.has_key?(:sumo_source)
        node.run_state[:sumo_source] = {}
      end
      toadd = params[:name].to_sym
      if node.run_state[:sumo_source].has_key?(toadd)
        raise Chef::Exceptions::ValidationFailed,
              "Sumo source #{params[:name]} is defined multiple times!"
      end

      # set default for category/tz/override here since you can't access
      # default attributes in the definition header (d'oh).
      cat = params[:category] ||
            node[:sumologic][:sources][:default_category] || 'log'
      tz = params[:default_timezone] ||
           node[:sumologic][:sources][:default_timezone] || 'UTC'
      tzoverride = params[:force_timezone] ||
                   node[:sumologic][:sources][:force_timezone] || false
      node.run_state[:sumo_source][toadd] =
        { :path => params[:path],
          :category => cat,
          :default_timezone => tz,
          :force_timezone => tzoverride
        }
    end
    action :nothing
  end

  # Yes we run this at compile-time, that way we can be sure that at run-time
  # when we restart the collector, we'll know about all the sources we're going
  # to be using ahead of time.
  p.run_action(:create)
end
