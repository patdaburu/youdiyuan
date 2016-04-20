#
# Cookbook Name:: listserv
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe "youdiyuan::apache2"

file '/tmp/listserv-default' do
  action :create
  content 'If you see this message in /tmp/listserv-default that is a good sign.'
end
