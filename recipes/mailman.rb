#
# Cookbook Name:: listserv
# Recipe:: mailman
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

## Apache2 Configuration

include_recipe "youdiyuan::apache2"


package "mailman"

service "mailman" do
  action [:enable, :start]
end



########################################################################
# Apache2 Integration                                                  #
########################################################################

# Copy mailman.conf from the mailman directory to Apache's sites-enabled
# directory.
file '/etc/apache2/sites-enabled/mailman.conf' do
  content IO.read('/etc/mailman/apache.conf')
  action :create_if_missing
end

# Comment the ScriptAlias line in /etc/apache2/sites-enabled/mailman.conf
ruby_block "modify /etc/apache2/sites-enabled/mailman.conf" do
  block do
    # We're going to look for the uncommented version of the line and
    # replace it with a commented version.
    fe = Chef::Util::FileEdit.new("/etc/apache2/sites-enabled/mailman.conf")
    fe.search_file_replace_line(/^\s*ScriptAlias\s+\/cgi-bin\/mailman\/\s+\/usr\/lib\/cgi-bin\/mailman\/\s*$/,
                                "#ScriptAlias /cgi-bin/mailman/ /usr/lib/cgi-bin/mailman/")
    fe.write_file
  end
end

# Run through the standard Apache cookbook.
include_recipe "apache2"
# Make sure Apache knows about the new site.
apache_site "mailman.conf"




########################################################################
# Postfix Integration                                                  #
########################################################################

# Uncomment the MTA='Postfix' line in mm_cfg.py
ruby_block "modify mm_cfg.py" do
  block do
    # We're going to look for the commented version of the line and
    # replace it with an uncommented version.
    fe = Chef::Util::FileEdit.new("/usr/lib/mailman/Mailman/mm_cfg.py")
    fe.search_file_replace_line(/\#\s*MTA\s*=\s*\'Postfix\'/,
                                "MTA='Postfix'")
    fe.write_file
  end
end



execute 'execute_genaliases' do
  cwd '/var/lib/mailman'
  command '/usr/lib/mailman/bin/genaliases'
  #not_if "[ -e /var/lib/mailman/data/aliases ]"
  action :run
end

# Set permissions on the aliases databases.
execute 'chmod /var/lib/mailman/data/aliases*' do
  command 'chmod g+w /var/lib/mailman/data/aliases*'
  action :run
end


node.default['postfix']['main']['alias_maps'] = "hash:/etc/aliases,hash:/var/lib/mailman/data/aliases"
node.default['postfix']['main']['alias_database'] = "hash:/etc/aliases,hash:/var/lib/mailman/data/aliases"

include_recipe "postfix"


########################################################################
# Post Integration                                                     #
########################################################################

# Create the mailman list (if it doesn't exist already).
execute 'newlist mailman' do
  # TODO: The arguments to mailman should be defined elsewhere!!!
  command '/usr/sbin/newlist mailman listowner@geo-comm.com PASSWORD'
  # Don't create the new list if we can see it already exists.
  not_if "[ -e /var/lib/mailman/lists/mailman ]"
  action :run
end

# Set the "List Creator" password.
execute '/usr/sbin/mmsitepass' do
  # TODO: The arguments to mmsitepass should be defined elsewhere!!!
  command '/usr/sbin/mmsitepass -c PASSWORD' # TODO: PASSWORD!!!
  action :run
end


# Restart mailman.
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
