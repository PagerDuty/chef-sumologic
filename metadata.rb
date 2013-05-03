name             'sumologic'
maintainer       'PagerDuty, Inc.'
maintainer_email 'luke@pagerduty.com'
license          'Apache 2.0'
description      "Installs/configures Sumo Logic's sumocollector"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.4'

depends 'java'

recipe 'sumologic', 'Installs Sumo Logic collector'
