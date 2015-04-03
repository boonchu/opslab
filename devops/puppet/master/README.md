###### How to install puppet master on CentOS 7

* [standard puppet master](https://docs.puppetlabs.com/guides/install_puppet/post_install.html)

* enable puppet yum repository
```
$ sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
$ sudo yum install puppet-server
$ puppet resource package puppet-server ensure=latest
package { 'puppet-server':
  ensure => '3.7.4-1.el7',
}
$ yum info puppet-server
$ puppet -V
3.7.4
```
* configure puppet master. Puppet use 8140 port service talking to Desktop.
```
- Create CA cert
$ sudo puppet master --verbose --no-daemonize
[sudo] password for bigchoo:
Info: Creating a new SSL key for ca
Info: Creating a new SSL certificate request for ca
Notice: server1.cracker.org has a waiting certificate request
Notice: Signed certificate request for server1.cracker.org
Notice: Removing file Puppet::SSL::CertificateRequest server1.cracker.org at '/var/lib/puppet/ssl/ca/requests/server1.cracker.org.pem'
Notice: Removing file Puppet::SSL::CertificateRequest server1.cracker.org at '/var/lib/puppet/ssl/certificate_requests/server1.cracker.org.pem'

- List all CA cert
$ puppet cert list -all
+ "server1.cracker.org" (SHA256) E4:E1:18:49:5F:3F:03:42:7B:62:38:34:58:55:D4:66:64:D3:0E:09:F6:81:4F:76:22:13:91:F8:78:23:DC:39 (alt names: "DNS:puppet", "DNS:puppet.cracker.org", "DNS:server1.cracker.org")
```

* [enterprise puppet master](https://docs.puppetlabs.com/pe/latest/install_basic.html#the-puppet-master)
```
- remove standard puppet master
# systemctl stop puppetmaster
# systemctl mask puppetmaster
- verify installer
wget -O - https://downloads.puppetlabs.com/puppetlabs-gpg-signing-key.pub | gpg --import
gpg --fingerprint 0x1054b7a24bd6ec30
gpg --verify puppet-enterprise-<version>-<platform>.tar.gz.asc
- install package
./puppet-enterprise-installer
Please go to https://server1.cracker.org:3000 in your browser to continue installation.

- enable firewalld to allow port 3000, 8184
- [verify] web UI listens to port https
# lsof -i :443
COMMAND    PID      USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
pe-httpd 17309      root    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17328 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17329 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17330 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17331 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17332 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17334 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17337 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 17338 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)
pe-httpd 21760 pe-apache    5u  IPv4 110658      0t0  TCP *:https (LISTEN)

$ systemctl status pe-httpd
pe-httpd.service - Puppet Enterprise Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/pe-httpd.service; enabled)
   Active: active (running) since Wed 2015-03-25 11:34:38 PDT; 17min ago
 Main PID: 17309 (pe-httpd)
   CGroup: /system.slice/pe-httpd.service
           ├─17309 /opt/puppet/sbin/pe-httpd -k start
           ├─17310 PassengerWatchdog
           ├─17313 PassengerHelperAgent
           ├─17319 PassengerLoggingAgent
           ├─17328 /opt/puppet/sbin/pe-httpd -k start
           ├─17329 /opt/puppet/sbin/pe-httpd -k start
           ├─17330 /opt/puppet/sbin/pe-httpd -k start
           ├─17331 /opt/puppet/sbin/pe-httpd -k start
           ├─17332 /opt/puppet/sbin/pe-httpd -k start
           ├─17334 /opt/puppet/sbin/pe-httpd -k start
           ├─17337 /opt/puppet/sbin/pe-httpd -k start
           ├─17338 /opt/puppet/sbin/pe-httpd -k start
           ├─21760 /opt/puppet/sbin/pe-httpd -k start
           └─21779 Passenger RackApp: /opt/puppet/share/puppet-dashboard

- [verify] puppet listens to port 8140
# lsof -i :8140
COMMAND   PID      USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    14773 pe-puppet  127u  IPv6  98982      0t0  TCP *:8140 (LISTEN)

pe-pupp+ 14773 11.8 19.0 4676832 1214268 ?     Ssl  11:32   2:08 /opt/puppet/bin/java -Xms2048m -Xmx2048m -XX:MaxPermSize=256m -XX:OnOutOfMemoryError=kill\ -9\ pe-puppetserver -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/pe-puppetserver -Djava.security.egd=/dev/urandom -cp /opt/puppet/share/puppetserver/puppet-server-release.jar clojure.main -m puppetlabs.trapperkeeper.main --config /etc/puppetlabs/puppetserver/conf.d -b /etc/puppetlabs/puppetserver/bootstrap.cfg

- all enabled services
packagekit-offline-update.service           enabled
pe-activemq.service                         enabled
pe-console-services.service                 enabled
pe-httpd.service                            enabled
pe-mcollective.service                      enabled
pe-memcached.service                        enabled
pe-postgresql.service                       enabled
pe-puppet-dashboard-workers.service         enabled
pe-puppet.service                           enabled
pe-puppetdb.service                         enabled
pe-puppetserver.service                     enabled

- access from UI, https://server1.cracker.org
```

* [install enterprise puppet agents](https://docs.puppetlabs.com/pe/latest/install_agents.html)
  - [ubuntu kickstart](https://github.com/boonchu/opslab/blob/master/devops/puppet/master/kickstart/ubuntu/ks.cfg)
```
** for instance, you want to add agent to ubuntu node **
method 1:
- Use console to add pe_repo::platform::ubuntu_1404_amd64
- Add class, search available classes and select "pe_repo::platform::ubuntu_1404_amd64" from list
- Add selected classes
- Navigate to node page for puppet master
- Edit and type "pe_repo::platform::ubuntu_1404_amd64" in class field
- Update
- From Live management, select control puppet
- Select only puppet master node
- Click runonce action and run to trigger a puppet run
- ssh to client to install agent
$ curl -k https://server1.cracker.org:8140/packages/current/install.bash | sudo bash

method 2:
- extract .deb package from https://puppetlabs.com/misc/pe-files/agent-downloads
- install .deb to web server
- setup /etc/apt/sources.list to point to web server
deb http://server1.cracker.org/cobbler/pub/ubuntu-14.04-amd64/ /
- import gpg key
wget -O - https://downloads.puppetlabs.com/puppetlabs-gpg-signing-key.pub | gpg --import
gpg -a --export 4BD6EC30 | apt-key add -
- run apt-get update -y
- install pe-puppet agent
# apt-get install pe-agent -y
```
- add node to PE puppet
```
- trigger from desktop
$ sudo /usr/local/bin/puppet agent -t
Exiting; no certificate found and waitforcert is disabled
- add from console and rerun 
or
- trigger by cert sign client node at master 
# puppet cert sign vmk3
$ sudo /usr/local/bin/puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for vmk3.cracker.org
Info: Applying configuration version '1427311187'
Notice: Finished catalog run in 0.52 seconds
```

* [add first ntp modules](https://docs.puppetlabs.com/pe/latest/quick_start_ntp.html)
```
$ sudo puppet config set modulepath /etc/puppetlabs/puppet/modules
$ sudo puppet config print modulepath
$ sudo puppet module install puppetlabs-ntp
$ sudo puppet module list
/etc/puppet/modules
├── puppetlabs-ntp (v3.3.0)
└── puppetlabs-stdlib (v4.5.1)
/usr/share/puppet/modules (no modules installed)
 \> tree /etc/puppet/modules/ntp -d
/etc/puppet/modules/ntp
├── lib
│   └── puppet
│       └── parser
│           └── functions
├── manifests
├── spec
│   ├── acceptance
│   │   └── nodesets
│   ├── classes
│   └── unit
│       └── puppet
│           ├── provider
│           └── type
├── templates
└── tests
- From the console, click Classification in the top navigation bar.
- classification selection
- From the Classification page, select the default group.
- Click the Classes tab.
- In the Class name field, begin typing ntp, and select it from the autocomplete list.
  - Tip: You only need to add the main ntp class; it contains the other classes from the module.
- Click Add class.
- Click Commit 1 change.
  - Note: The ntp class now appears in the list of classes for the default group, but it has not yet been configured on your nodes. For that to happen, you need to kick off a Puppet run.
- Navigate to the live management page, and select the Control Puppet tab.
- Click the runonce action and then Run. This will configure the nodes using the newly-assigned classes.

```
* use example [video](https://puppetlabs.com/webinars/how-manage-ntp) to setup NTP
* tune NTP 
```
- Add "System Group" to "default"
- Add "ntp" class 
  - service_enable = true
  - servers = [ "time.cracker.org" ]
- run puppet agent -t
```
![ntp](https://github.com/boonchu/opslab/blob/master/devops/puppet/master/ntp.png)
* tune [Firewall](https://docs.puppetlabs.com/pe/latest/quick_start_firewall.html)
```
- Install puppet firewall module

# puppet module install puppetlabs-firewall

- Add "my_fw" class
- Can see port 22 SSHD from firewall table

    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport ports 22 /* 100 allow ssh access */
    
- Test Idempotent operation. it all clear afer puppet agent -t

# iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8449 -j ACCEPT
# iptables -vnL
Chain INPUT (policy ACCEPT 1 packets, 334 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:8449
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:8449

# puppet agent -t

Notice: /Stage[main]/My_fw/Firewall[9001 9cdbf91f22d3f4dbc5790ea55bc05aba]/ensure: removed
Notice: /Stage[main]/My_fw/Firewall[9002 9cdbf91f22d3f4dbc5790ea55bc05aba]/ensure: removed

```
* tune TimeZone
```
$ sudo puppet module install saz-timezone
```
* tune [SUDO](https://docs.puppetlabs.com/pe/latest/quick_start_sudo.html)

* tune [DNS](https://docs.puppetlabs.com/pe/latest/quick_start_dns.html)

* tune [SSH](https://docs.puppetlabs.com/pe/latest/quick_start_ssh.html)

###### Reference
  * [Courseware-LMS](https://github.com/puppetlabs/courseware-lms-content/tree/master/courses)
  * [PCP Certified Exam](https://puppetlabs.com/services/certification/puppet-professional/2015)
  * [PE puppet installation](https://github.com/puppetlabs/puppet-docs/blob/master/source/pe/3.7/install_basic.markdown#platform-specific-install-script)
  * [PE puppet agent installation]()
