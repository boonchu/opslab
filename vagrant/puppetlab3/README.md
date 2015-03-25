###### Starting with puppet lab 3 SELinux and ntp
* this main reason that I am examining this because of RHCSA/RHCE certification exam.

* start with vagrant box add 
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
```

* update with simple ntp class module, 'puppet/modules/ntp/manifests/init.pp'
```
class ntp {

      package { 'ntp':
        ensure => installed,
      }

      file { 'ntp.conf':
        path    => '/etc/ntp.conf',
        ensure  => file,
        require => Package['ntp'],
        source  => "puppet:///modules/ntp/ntp.conf",
      }

      service { 'ntpd':
        name      => $service_name,
        ensure    => running,
        enable    => true,
        subscribe => File['ntp.conf'],
      }

}

$ vagrant provision
$ vagrant ssh
$ ntpq -p
```

* reference:
  - [community puppet](forge.puppetlabs.com)
