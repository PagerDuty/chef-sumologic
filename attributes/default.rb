# 
# Author:: Ranjib Dey    (<ranjib@pagerduty.com>)
# Author:: Luke Kosewski (<luke@pagerduty.com>)
# Cookbook Name:: sumologic
# Attributes:: default
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

# default sumocollector attributes
default[:sumologic][:rootdir] = '/opt/sumologic'

# Sumologic control commands
default[:sumologic][:start_cmd] = '/etc/init.d/collector start'
default[:sumologic][:stop_cmd] = '/etc/init.d/collector stop'
default[:sumologic][:restart_cmd] = '/etc/init.d/collector restart'

# Set to true to disable the collector on this node
default[:sumologic][:disabled] = false

# The sumocollector version you're installing
sumover = '19.40-8'
default[:sumologic][:collector][:version] = sumover

# The sumocollector tarball you wish to install.  You probably don't want to
# change this; just grab and host the appropriate tarball corresponding to
# its name.  But be careful since Sumo Logic drops ".tar" on occasion for no
# reason, turning various releases into just ".gz."
tarball = "SumoCollector_unix_#{sumover.gsub('.', '_')}.gz"
default[:sumologic][:collector][:tarball] = tarball
# The checksum for that tarball
default[:sumologic][:collector][:checksum] = "37b4167160f64390af6a0f52d1cd38fe957464b8df36520e485e53103fe4a206"

# The URL where your tarball is stored
default[:sumologic][:collector][:url] = "https://collectors.sumologic.com/rest/download/tar"

# Admin credentials for Sumo Logic account
default[:sumologic][:admin][:email] = 'user@example.com'
default[:sumologic][:admin][:pass] = 'mysupersecretpass'

# Set to change the default category for log files if not specified.
default[:sumologic][:sources][:default_category] = 'log'
# Set to force logs that don't carry timezones in timestamps or where you want
# to ignore that data to this timezone (defaults to UTC).
default[:sumologic][:sources][:default_timezone] = 'UTC'
# Set to true to force timestamps parsed from logs into this timezone,
# regardless of whether they carry tz information or not.
default[:sumologic][:sources][:force_timezone] = false
