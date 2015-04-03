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
Error: Could not request certificate: The certificate retrieved from the master does not match the agent's private key.
http://fatmin.com/2014/11/09/puppet-how-not-to-generate-a-certificate-with-your-correct-hostname/
```
clean up client cert on master, if any
```
$ puppet cert clean vmk3
or
$ find /etc/puppetlabs/puppet/ssl/ca/signed/ -name vmk3.pem -print -delete
/etc/puppetlabs/puppet/ssl/ca/signed/vmk3.pem
```
clean up client cert on client
```
$ service pe-puppet stop
$ find /etc/puppetlabs/puppet/ssl -name vmk3* -print -delete
/etc/puppetlabs/puppet/ssl/public_keys/vmk3.pem
/etc/puppetlabs/puppet/ssl/private_keys/vmk3.pem
/etc/puppetlabs/puppet/ssl/certs/vmk3.pem
$ service pe-puppet start
$ puppet agent -t
```
[never test - DON't use] if cert clean up on client not helpful, use solution from below to clean up cert and regenerate on master
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
###### Reference
   * [Troubleshooting](https://docs.puppetlabs.com/guides/troubleshooting.html)
