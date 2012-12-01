Description
===========

Installs the Sumo Logic collector the way we do it at PagerDuty.  Allows you to
configure the sources to send up; works on Linux x86 and x86-64.  Sets up a
fully unattended installation and gets all your sources pushed up without you
manually activating or pushing any buttons.

Requirements
============

Depends on the Opscode `java` cookbook which ensures you have a /usr/bin/java.
Really that's all you need, so feel free to break that dependency if you
have an alternative method of installing Java.

The cookbook grabs a Sumo Logic tarball from an http server.  Sumo Logic
provides you download links if you want to use those, but they're ephemeral, so
I suggest hosting it on a local asset server.

Platform
--------

* Tested on Ubuntu 10.04, both x86 and x86-64.
* Will need extra work to run in Windows, Solaris.
* Tested under Chef 0.10.8, Chef 10.12.0, and Chef 10.14.\*, in Ruby 1.8 & 1.9.

Attributes
==========

See `attributes/default.rb` for default values.

* `node[:sumologic][:rootdir]` - The directory you want to house Sumo Logic
  collector in.  It will sit in a subdirectory of the rootdir called
  'sumocollector'.
* `node[:sumologic][:disabled]` - Set this if you need to disable the collector
  on this node for some reason.
* `node[:sumologic][:collector][:url]` - The non-tarball part of the URL you're
  downloading the collector from (if the full url is http://path/to/s.tar.gz,
   this is the http://path/to part).
* `node[:sumologic][:collector][:version]` - The version of the collector you
  want to install.
* `node[:sumologic][:collector][:tarball]` - The name of the tarball you're
  downloading, so the s.tar.gz in the above example.
* `node[:sumologic][:collector][:checksum]` - The md5sum of the tarball.
* `node[:sumologic][:admin][:email]` - The email of an admin user that will
  be invoked to perform unattended installs of collectors.  See Sumo's article
  for more info:
    https://service.sumologic.com/ui/help/Unattended_Installation.htm
* `node[:sumologic][:admin][:pass]` - The password for the admin's email above.
* `node[:sumologic][:sources][:default_category]` - You can specify a category
  for any of your resources through the sumo\_source definition (see below), but
  this allows you to provide a catch-all that's more descriptive than 'log'.
* `node[:sumologic][:sources][:default_timezone]` - If you have timezone parsing
  disabled or if there are no timezones in your log timestamps, input the
  timezone you want to default to (must match Sumo's dropdown list *exactly*).
  Otherwise will default to UTC.
* `node[:sumologic][:sources][:force_timezone]` - Set to *true* to force any
  timestamps parsed out of log files to this timezone, regardless of any
  timezone information they may carry.

Usage
=====

Drop this cookbook with the default recipe onto your servers and you've got
a collector running.  Want some sources?  Use the sumo\_source definition
provided to create them.  Example:

    sumo_source 'syslog' do
        path '/var/log/syslog'
        category 'syslog'  # optional, defaults to 'log' or the category attr.
        default_timezone 'UTC'  # optional, defaults to UTC or timezone attr.
        force_timezone true # optional, defaults to false or the force attr.
    end

You may include this definition in any recipe; it will "do the right thing" and
configure all of your sources before restarting sumologic.  It will also
correctly set the '-o' sumocollector parameter for a sumo restart to force the
web interface to accept changes to your sources.

Changes
=======

## v0.0.2

* Broken off of PagerDuty's internal chef repo and released to the world with
  sane defaults.

## v0.0.3

* Fixed upgrades to a newer sumocollector version.

## v0.0.4

* Various cleanups re: string quoting.
* Workaround (-c) for Sumo Logic being incapable of reconfiguring sources
  correctly.  The workaround is only moderately less idiotic than that, as it
  requires a logrotate invocation to work properly.
* Fix for collector not restarting if you haven't modified sources in between
  the last time the collector was disabled and now.
* Stop forcing a particular URL to work; users can now use whatever URL they
  please to store their Sumo tarballs.

License and Author
==================

Author:: Luke Kosewski (<luke@pagerduty.com>)

Copyright:  2012, PagerDuty, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
