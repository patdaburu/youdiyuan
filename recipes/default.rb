#
# Cookbook Name:: youdiyuan
# Recipe:: default
#
# Copyright (c) 2016 GeoComm, All Rights Reserved.

# Set up Apache.
include_recipe "youdiyuan::apache2"

# Set up Postfix.
include_recipe "youdiyuan::postfix"

# Install Mailman.
include_recipe "youdiyuan::mailman"

########################################################################
# Apache2 Integration                                                  #
########################################################################

# REMOVED: We originally copied the mailman.conf file directly from the
#          mailman install.  It is now written from a template.
## Copy mailman.conf from the mailman directory to Apache's sites-enabled
## directory.
#file '/etc/apache2/sites-enabled/mailman.conf' do
#  content IO.read('/etc/mailman/apache.conf')
#  action :create_if_missing
#end

# Copy mailman.conf from the templates directory to Apache's sites-enabled
# directory.
template '/etc/apache2/sites-enabled/mailman.conf' do
  source 'mailman/mailman.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
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
 
# Create the directory that will hold static HTML resources for the 
# admin pages.
directory '/usr/share/styles/mailman' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

# Copy static HTML resources from Chef templates.
#template '/var/www/html/public/mailman/mailman.css' do
template '/usr/share/styles/mailman/mailman.css' do # TODO: We're putting the CSS file in the images directory until we figure out a bettr location.  The answer is probably to create a new directory under /usr/share and create another directive for it.
  source 'mailman/mailman.css.erb'
  owner  'root'
  group  'root'
  mode   '0644'
end

# Create the /var/lib/mailman/templates/site/en directory to hold all
# of our modified templates.
directory '/var/lib/mailman/templates/site/en' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

# Put the modified mailman templates in place.
html_templates = [ 'archtoc.html', 'listinfo.html', 'options.html', 'roster.html', 'subscribe.html' ]
html_templates.each() do | template_file |
  template '/var/lib/mailman/templates/site/en/' + template_file do
    source 'mailman/' + template_file + '.erb'
    owner  'root'
    group  'root'
    mode   '0755'
  end
end


# Restart Apache so the changes can take effect.
service "apache2" do
  action :restart
end


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

# Run genaliases.
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

# Modify the postfix main.cf file to include the new aliases databases.
node.default['postfix']['main']['alias_maps'] = "hash:/etc/aliases,hash:/var/lib/mailman/data/aliases"
node.default['postfix']['main']['alias_database'] = "hash:/etc/aliases,hash:/var/lib/mailman/data/aliases"

# Re-run the postfix setup.
include_recipe "postfix"


########################################################################
# Post-Integration Steps                                               #
########################################################################

# Create the mailman list (if it doesn't exist already).
execute 'newlist mailman' do
  # TODO: The arguments to mailman should be defined elsewhere!!!
  command '/usr/sbin/newlist mailman listowner@geo-comm.com PASSWORD' # TODO: PASSWORD!!!
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
