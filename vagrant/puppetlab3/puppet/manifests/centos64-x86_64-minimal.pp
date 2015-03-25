# cd /vagrant/puppet/manifests/
# puppet apply -v centos64-x86_64-minimal.pp --modulepath=/vagrant/puppet/modules/ --noop
# puppet apply -v centos64-x86_64-minimal.pp --modulepath=/vagrant/puppet/modules/

# .../puppet/manifests/site.pp

user { 'dave':
  ensure => absent,
}

user { 'katie':
  ensure => 'present',
  home   => '/home/katie',
  shell  => '/bin/bash'
}

package { 'firewalld':
    ensure => absent,
}

package { 'iptables-services':
    ensure => installed,
}

service { 'iptables':
    ensure  => running,
    enable  => true,
    require => Package['iptables-services'],
}

# iptables purge
resources { "firewall":
    purge   => true,
    require => [
                  Service['iptables'],
                  Package['firewalld']
		],
}

Firewall {
    before  => Class['fw::post'],
    require => Class['fw::pre'],
}

class { ['fw::pre', 'fw::post']: }

# selinux enforcing
class { 'selinux': mode => 'enforcing', }

include motd
include openssh
include httpd
include ntp
