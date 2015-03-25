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
