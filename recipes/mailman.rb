#
# Cookbook Name:: youdiyuan
# Recipe:: mailman
#
# Copyright (c) 2016 GeoComm, All Rights Reserved.

# Load the "mailman" package.
package "mailman"

# Enable it and start it up.
service "mailman" do
  action [:enable, :start]
end


########################################################################
# Mailman Backup                                                       #
########################################################################

# Create the backup script.
template '/usr/sbin/mailman-backup' do
  source 'mailman_backup.erb'
  owner  'root'
  group  'root'
  mode   '0755'
end

# Run the mailman backup script once per day.
cron 'backup mailman' do
  minute '1'
  hour '0'
  # TODO: We can send mail to a user.
  #mailto 'who@geo-comm.com'
  command '/usr/sbin/mailman-backup'
end
