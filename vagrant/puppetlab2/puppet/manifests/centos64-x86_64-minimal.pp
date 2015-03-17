# cd /vagrant/puppet/manifests/
# puppet apply -v centos64-x86_64-minimal.pp --modulepath=/vagrant/puppet/modules/ --noop
# puppet apply -v centos64-x86_64-minimal.pp --modulepath=/vagrant/puppet/modules/

# .../puppet/manifests/site.pp

# iptables purge
resources { "firewall":
    purge   => true
}

Firewall {
    before  => Class['fw::post'],
    require => Class['fw::pre'],
}

class { ['fw::pre', 'fw::post']: }

include selinux
include motd
include openssh
include httpd
