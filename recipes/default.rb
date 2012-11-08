#
# Author:: Luke Kosewski (<luke@pagerduty.com>)
# Cookbook Name:: sumologic
# Recipe:: default
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

directory node[:sumologic][:rootdir] do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
end

c = "#{node[:sumologic][:rootdir]}/#{node[:sumologic][:collector][:tarball]}"
remote_file c do
  backup false
  owner 'root'
  group 'root'
  mode 0644
  checksum node[:sumologic][:collector][:checksum]
  source "#{node[:sumologic][:collector][:url]}/" +
           node[:sumologic][:collector][:tarball]
  notifies :run, 'bash[extract_sumologic]', :immediately
end

bash 'extract_sumologic' do
  def wrapperdir
    if node[:os] == 'linux'
      case node[:kernel][:machine]
      when 'i386', 'i586', 'i686'
        'linux32'
      when 'x86_64'
        'linux64'
      else
        raise Chef::Exceptions::UnsupportedAction,
          'I don\'t know how to install SumoLogic on your Linux arch yet.'
      end
    else
      raise Chef::Exceptions::UnsupportedAction,
        'I don\'t know how to install SumoLogic on your OS yet.'
    end
  end

  user 'root'
  cwd node[:sumologic][:rootdir]
  code <<-EOH
    tar zxf #{node[:sumologic][:collector][:tarball]}
    chmod 755 sumocollector/collector
    cp sumocollector/tanuki/#{wrapperdir}/wrapper sumocollector
  EOH
  # The last file to be created.  If it's there, then we default to action
  # :nothing (though the remote_file above can override this).  If it isn't
  # there, then we need to untar.
  if !File.exists?("#{node[:sumologic][:rootdir]}/sumocollector/wrapper")
    action :run
  else
    action :nothing
  end
end

bash 'install collector into /etc/*.d' do
  user 'root'
  code "#{node[:sumologic][:rootdir]}/sumocollector/collector install"
  not_if { File.exists?('/etc/init.d/collector') }
end

# Note:  we could do everything this resource does inside the .erb file, but
# erb syntax is way gross.  This depends on the fact that all the setters of
# sumo_source ran at compile time, because you ran the definition, didn't you?
ruby_block 'compile_sumo_sources' do
  block do
    node.run_state[:sumo_output] =
      # Stupid hacky .to_s because Ruby 1.8 can't <=> symbols.
      node.run_state[:sumo_source].sort_by{ |k,v| k.to_s }.map do |k, v|
        # Forgive the weird indentation - it makes for a much more readable
        # config file, I assure you.
        x = <<-EOS.rstrip
    {
      "type" : "localWildCard",
      "name" : "#{k}",
      "timeZone" : "#{v[:default_timezone]}",
      "forceTimeZone" : #{v[:force_timezone]},
      "pathExpression" : "#{v[:path]}",
      "category" : "#{v[:category]}"
    }
        EOS
      end
  end
end

selectedjson =
  "#{node[:sumologic][:rootdir]}/sumocollector/installerSources/selected.json"
p = template selectedjson do
  source 'selected.json.erb'
  mode 0644
  backup false
  if node[:sumologic][:disabled]
    action :nothing  # Don't go writing this template if no collector.
  else
    notifies :restart, 'service[collector]'
  end
end

# Had to steal this from inside the tar file because it's awful to modify.
# Converted to template.
template "#{node[:sumologic][:rootdir]}/sumocollector/config/wrapper.conf" do
  source "wrapper.conf.erb"
  backup false
  mode 0664
  variables(
    :java_location => '/usr/bin/java',
    :sumo_email => node[:sumologic][:admin][:email],
    :sumo_pass => node[:sumologic][:admin][:pass],
    :selectedjson => p
  )
  notifies :restart, 'service[collector]' if !node[:sumologic][:disabled]
end

service 'collector' do
  action node[:sumologic][:disabled] ? :stop : :nothing
  supports [:start, :stop, :status, :restart, :install, :remove, :dump,
            :console, :condrestart]
end
