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
* when you see message after running puppet agent -t
```
Exiting; no certificate found and waitforcert is disabled
```
solution:
```
# puppet agent --no-daemonize --onetime --verbose
Exiting; no certificate found and waitforcert is disabledv

# puppet config set certificate_revocation false

# puppet agent --no-daemonize --server server1.cracker.org --onetime --verbose
Exiting; no certificate found and waitforcert is disabled
```
* when you have issue after running puppet agent -t
```
Error: Could not request certificate: The certificate retrieved from the master does not match the agent's private key.
http://fatmin.com/2014/11/09/puppet-how-not-to-generate-a-certificate-with-your-correct-hostname/
```
solution:
clean up client cert on master, if any
```
$ puppet node deactivate vmk3
$ puppet cert clean vmk3
$ find /etc/puppetlabs/puppet/ssl/ca/signed/ -name vmk3.pem -print -delete
/etc/puppetlabs/puppet/ssl/ca/signed/vmk3.pem
```
clean up client cert on client
```
- centos6/ubuntu instruction
$ service pe-puppet stop
$ find /etc/puppetlabs/puppet/ssl -name vmk3* -print -delete
/etc/puppetlabs/puppet/ssl/public_keys/vmk3.pem
/etc/puppetlabs/puppet/ssl/private_keys/vmk3.pem
/etc/puppetlabs/puppet/ssl/certs/vmk3.pem
$ puppet config set server server1.cracker.org
- note: certname need to match with hostname
$ puppet config print certname (prior to running first time puppet agent -t)
vmk3
$ service pe-puppet start
$ puppet agent -t
```
[never test - DON't use] if cert clean up on client not helpful, use solution from below to clean up cert and regenerate on master
```
puppet cert clean server1.cracker.org
puppet cert generate server1.cracker.org
systemctl restart pe-httpd
```
* error from puppet agent -t
```
Error: /File[/var/lib/puppet/facts.d]: Could not evaluate: Could not retrieve file metadata for puppet://puppet/pluginfacts: getaddrinfo: Name or service not known
```
solution:
```
https://github.com/nathanielksmith/puppet-tilde/issues/17
```
* found weird issue from PE puppet since I previously installed standard puppet and overwrite with enterprise edition. When I run the puppet agent -t, it fails and thrown with CA error.
```
-- test run --
$ /opt/puppet/bin/puppet agent --onetime --no-daemonize \
  --color=false --show_diff --verbose --splay --splaylimit 120
-- move binary puppet --  
$  ln -s /opt/puppet/bin/puppet /bin/puppet
\> puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for server1.cracker.org
Info: Applying configuration version '1428163129'
Notice: Finished catalog run in 7.90 seconds
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
   * [Troubleshooting 2](https://docs.puppetlabs.com/pe/latest/trouble_comms.html)
   * [Puppet Enterprise Troubleshooting](http://www.slideshare.net/PuppetLabs/puppet-conf-slides-25547169)
