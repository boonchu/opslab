* verify cert on master and node
```
- on master
# puppet config print certname
server1.cracker.org
# puppet config print dns_alt_names
server1,server1.cracker.org
- on node
# puppet config print --section agent server
server1.cracker.org
```
* when you have issue after running puppet agent -t
```
Error: /File[/var/opt/lib/pe-puppet/lib]: Failed to generate additional resources using 'eval_generate': SSL_connect returned=1 errno=0 state=unknown state: certificate verify failed: [unable to get local issuer certificate for /CN=server1.cracker.org]
```
clean up client cert on master, if any
```
$ puppet cert clean <client>
```
clean up client cert on client
```
$ find /etc/puppetlabs/puppet/ssl -name <client>.pem -delete
$ puppet agent -t
```
if cert clean up on client not helpful, use solution from below to clean up cert and regenerate on master
```
puppet cert clean server1.cracker.org
puppet cert generate server1.cracker.org
systemctl restart pe-httpd
```
* find place to keep puppet.conf 
```
# puppet config print confdir
/etc/puppetlabs/puppet
- restart after config change
# service pe-puppet restart
```
