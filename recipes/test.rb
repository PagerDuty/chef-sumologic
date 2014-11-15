include_recipe 'sumologic'

sumo_source 'syslog' do
  path '/var/log/syslog'
  category 'syslog'
end
