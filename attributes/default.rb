#
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

# Set to true to disable the collector on this node
default[:sumologic][:disabled] = false

# The base of the URL where your tarball is stored
default[:sumologic][:collector][:url] = 'http://path/to'
# The sumocollector tarball you wish to install
default[:sumologic][:collector][:tarball] = 'SumoCollector_unix_19_14-2.gz'
# The checksum for that tarball
default[:sumologic][:collector][:checksum] = '10658a38befc50a1ec2edc384b7348b6'

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
