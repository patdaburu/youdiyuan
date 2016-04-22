#
# Cookbook Name:: listserv
# Recipe:: apache2
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


# TODO: Get the servername elsewhere.
node.default['apache']['servername'] = "dev-listserv-vm.geo-comm.local"


package 'apache2'


service 'apache2' do
  supports :status => true
  action [:enable, :start]
end


include_recipe "apache2"


# Use the Apache fdqn template file to set the Apache fqdn.
apache_conf "fqdn" do
  source 'apache2_fqdn.erb'
  enable true
end


apache_module "cgid"


