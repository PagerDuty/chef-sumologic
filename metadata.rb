name             'bc_sumologic'
maintainer       'PagerDuty, Inc.'
maintainer_email 'ranjib@pagerduty.com'
license          'Apache 2.0'
description      "Installs/configures Sumo Logic's sumocollector"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.3.0'

depends 'sumologic-collector', '= 1.3.0'

recipe 'bc_sumologic', 'Installs Sumo Logic collector, and provides resources for forwarding logs to sumologic'
