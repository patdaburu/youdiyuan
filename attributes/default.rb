# Apache2 Settings
node.default['apache']['servername'] = "dev-listserv-vm.geo-comm.local"

# Postfix Settings
node.default['postfix']['main']['myhostname'] = "dev-listserv-vm"
node.default['postfix']['main']['mydomain'] = nil
node.default['postfix']['main']['mydestination'] = "dev-listserv-vm.geo-comm.local, dev-listserv-vm, localhost.localdomain, localhost"
node.default['postfix']['main']['relayhost'] = "mail.geo-comm.com"
node.default['postfix']['main']['mynetworks'] = "127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
node.default['postfix']['main']['relay_domains'] = "geo-comm.com"
# This next one isn't a Postfix main.cf setting per se.  Instead, it's the name we write to /etc/mailname.
node.default['youdiyuan']['etc']['mailname'] = 'dev-listserv-vm.geo-comm.local'
