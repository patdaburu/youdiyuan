#
# Cookbook Name:: listserv
# Recipe:: apache2
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'apache2'

service 'apache2' do
  supports :status => true
  action [:enable, :start]
end
