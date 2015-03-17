###### Starting with puppet lab 2

* start with centos box image and bring up the instance
```
$ vagrant box add centos64-x86_64-minimal centos64-x86_64-minimal.box
$ vagrant up
```

* download puppet-firewall modules from community

* here is tree directory structure
```
bash-3.2$ tree -d
.
├── fw
│   └── manifests
├── httpd
│   ├── files
│   └── manifests
├── motd
│   ├── files
│   └── manifests
├── openssh
│   ├── files
│   └── manifests
├── puppetlabs-firewall
│   ├── lib
│   │   ├── facter
│   │   └── puppet
│   │       ├── provider
│   │       │   ├── firewall
│   │       │   └── firewallchain
│   │       ├── type
│   │       └── util
│   ├── manifests
│   │   └── linux
│   └── spec
│       ├── acceptance
│       │   └── nodesets
│       └── unit
│           ├── classes
│           ├── facter
│           └── puppet
│               ├── provider
│               ├── type
│               └── util
└── selinux
    ├── files
    └── manifests
```
* bring up vagrant
```
$ vagrant up
$ vagrant ssh

- login to vagrant
$ vagrant ssh
Last login: Tue Mar 17 15:03:53 2015 from 10.0.2.2
d8888b. db    db d8888b. d8888b. d88888b d888888b
88  `8D 88    88 88  `8D 88  `8D 88'     `~~88~~'
88oodD' 88    88 88oodD' 88oodD' 88ooooo    88
88~~~   88    88 88~~~   88~~~   88~~~~~    88
88      88b  d88 88      88      88.        88
88      ~Y8888P' 88      88      Y88888P    YP


db       .d8b.  d8888b. .d888b.
88      d8' `8b 88  `8D VP  `8D
88      88ooo88 88oooY'    odD'
88      88~~~88 88~~~b.  .88'
88booo. 88   88 88   8D j88.
Y88888P YP   YP Y8888P' 888888D

- allow port 22
[vagrant@localhost ~]$ sudo iptables -n -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           /* 000 accept all icmp */
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           /* 001 accept all to lo interface */
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           /* 003 accept related established rules */ state RELATED,ESTABLISHED
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           multiport dports 22 /* 100 allow openssh */ state NEW
LOG        all  --  0.0.0.0/0            0.0.0.0/0           /* 900 log dropped input chain */ LOG flags 0 level 6 prefix `[IPTABLES INPUT] dropped '
DROP       all  --  0.0.0.0/0            0.0.0.0/0           /* 910 deny all other input requests */
```

* change server manifest to start httpd and allow port 80
```
- edit file 'puppet/manifests/centos64-x86_64-minimal.pp' to include httpd
include selinux
include motd
include openssh
include httpd

- notice when manifest change, puppet provisioned httpd service.
$ vagrant provision && vagrant ssh
==> default: Running provisioner: puppet...
==> default: Running Puppet with centos64-x86_64-minimal.pp...
==> default: Notice: /Firewall[100 allow httpd]/ensure: created
==> default: Notice: Finished catalog run in 0.82 seconds
Last login: Tue Mar 17 15:06:00 2015 from 10.0.2.2

- include port 22 on iptables
$ sudo iptables -n -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           /* 000 accept all icmp */
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           /* 001 accept all to lo interface */
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           /* 003 accept related established rules */ state RELATED,ESTABLISHED
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           multiport dports 80 /* 100 allow httpd */ state NEW
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           multiport dports 22 /* 100 allow openssh */ state NEW
LOG        all  --  0.0.0.0/0            0.0.0.0/0           /* 900 log dropped input chain */ LOG flags 0 level 6 prefix `[IPTABLES INPUT] dropped '
DROP       all  --  0.0.0.0/0            0.0.0.0/0           /* 910 deny all other input requests */
```

* reference:
  - [video puppet crash course](https://sysadmincasts.com/episodes/8-learning-puppet-with-vagrant)
  - search github for any new puppet modules
  - [community puppet](forge.puppetlabs.com)
