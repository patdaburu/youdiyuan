#
# Cookbook Name:: youdiyuan
# Recipe:: postfix
#
# Copyright (c) 2016 GeoComm, All Rights Reserved.


# TODO: The next block of settings should probably reside elsewhere
#node.default['postfix']['main']['myhostname'] = "dev-listserv-vm"
#node.default['postfix']['main']['mydomain'] = nil
#node.default['postfix']['main']['mydestination'] = "dev-listserv-vm.geo-comm.local, dev-listserv-vm, localhost.localdomain, localhost"
#node.default['postfix']['main']['relayhost'] = "mail.geo-comm.com"
#node.default['postfix']['main']['mynetworks'] = "127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
#node.default['postfix']['main']['relay_domains'] = "geo-comm.com"

file '/etc/mailname' do
#  content 'dev-listserv-vm.geo-comm.local'
  content node.default['youdiyuan']['etc']['mailname']
end

## Settings below this line do not refer specifically to this server.


#node.default['postfix']['mail_type'] = "master"

node.default['postfix']['main']['smtpd_banner'] = "$myhostname ESMTP $mail_name (Ubuntu)"
node.default['postfix']['main']['biff'] = "no"

# Appending .domain is the MUA's job.
node.default['postfix']['main']['append_dot_mydomain'] = "no"

# Uncomment the next line to generate "delayed mail" warnings.
#node.default['postfix']['main']['delay_warning_time'] = "4h"

node.default['postfix']['main']['readme_directory'] = "no"

# TLS Parameters
node.default['postfix']['main']['smtpd_tls_cert_file'] = "/etc/sl/certs/ssl-cert-snakeoil.pem"
node.default['postfix']['main']['smtpd_use_tls'] = "yes"
node.default['postfix']['main']['smtpd_tls_session_cache_database'] = "btree:${data_directory}/smtpd_scache"
node.default['postfix']['main']['smtp_tls_session_cache_database'] = "btree:${data_directory}/smtp_scache"

node.default['postfix']['main']['smtpd_relay_restrictions'] = "permit_mynetworks permit_sasl_authenticated defer_unauth_destination"

node.default['postfix']['main']['alias_maps'] = "hash:/etc/aliases"
node.default['postfix']['main']['alias_database'] = "hash:/etc/aliases"

node.default['postfix']['main']['myorigin'] = "/etc/mailname"
node.default['postfix']['main']['mailbox_size_limit'] = 0
node.default['postfix']['main']['recipient_delimiter'] = "+"
node.default['postfix']['main']['inet_interfaces'] = "all"
node.default['postfix']['main']['inet_protocols'] = "all"

# Now that we've established some parameters, bring in the standard "postfix" recipe.
include_recipe "postfix"
