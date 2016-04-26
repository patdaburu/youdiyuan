#
# Cookbook Name:: youdiyuan
# Recipe:: apache2
#
# Copyright (c) 2016 GeoComm, All Rights Reserved.


# TODO: Get the servername elsewhere.
#node.default['apache']['servername'] = "dev-listserv-vm.geo-comm.local"

# Install the Apache2 package.
package 'apache2'

# Enable Apache2 and start it up.
service 'apache2' do
  supports :status => true
  action [:enable, :start]
end

# Bring in the Apache2 recipe.
include_recipe "apache2"

# Use the Apache fdqn template file to set the Apache fqdn.
apache_conf "fqdn" do
  source 'apache2_fqdn.erb'
  enable true
end

# We want to enable the CGI gateway.
apache_module "cgid"
