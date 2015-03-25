###### Starting with puppet lab 3 SELinux and ntp
* this main reason that I am examining this because of attending RHCSA/RHCE 7 certification exam.

* I prepared own centos 7 image with Packer. Start with vagrant box add;
```
$ vagrant box add centos-7-0-x64-virtualbox http://ks.cracker.org/Kickstart/centos7/centos-7-0-x64-virtualbox.box
```

* download [jfryman-selinux modules](https://forge.puppetlabs.com/jfryman/selinux) from community

* add manifest to 'puppet/manifests/centos64-x86_64-minimal.pp'
```
# selinux enforcing
class { 'selinux': mode => 'enforcing', }
```

* bring up vagrant
```
$ vagrant up
- should see this message
==> default: Notice: /Stage[main]/Selinux::Config/File_line[set-selinux-config-to-enforcing]/ensure: created
```

- check enforcing mode
```
$ vagrant reload --provision
$ vagrant ssh
$ cat /etc/selinux/config | grep SELINUX
# SELINUX= can take one of these three values:
SELINUX=enforcing
$ getenforce
Enforcing
```

* Managing SELinux File Context. This will be a long version from RHCSA exam simulation.

* learning template features from Network Time Service
```
- detect the 'fact' of OS info
$ facter operatingsystem
CentOS

- create ntp template file, 'puppet/modules/ntp/templates/ntp.conf.el.erb'
- insert template syntax 

<% @_servers.each do |this_server| -%>
server <%= this_server %> iburst
<% end -%>

- create the ntp class, 'puppet/modules/ntp/manifests/init.pp'
class ntp {

      case $operatingsystem {
        CentOS: {
                $service_name    = 'ntpd'
                $conf_file   = 'ntp.conf.el'
                $default_servers = [ "0.centos.pool.ntp.org", "1.centos.pool.ntp.org", "2.centos.pool.ntp.org", ]
        }
      }

      $_servers = $default_servers

      package { 'ntp':
        ensure => installed,
      }

      # switch from source to content template
      # http://docs.puppetlabs.com/learning/templates.html#begin
      file { 'ntp.conf':
        path    => '/etc/ntp.conf',
        ensure  => file,
        require => Package['ntp'],
        # source  => "puppet:///modules/ntp/ntp.conf",
        content => template("ntp/${conf_file}.erb"),
      }

      service { 'ntpd':
        name      => $service_name,
        ensure    => running,
        enable    => true,
        subscribe => File['ntp.conf'],
      }
}

$ tree puppet/modules/ntp/
puppet/modules/ntp/
├── files
│   └── ntp.conf
├── manifests
│   └── init.pp
└── templates
    └── ntp.conf.el.erb

$ vagrant provision
$ vagrant ssh
$ ntpq -p
```

* reference:
  - [community puppet](forge.puppetlabs.com)
