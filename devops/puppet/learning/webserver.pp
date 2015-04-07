### https://docs.puppetlabs.com/puppet/latest/reference/lang_classes.html#inheritance
### classes type

class { 'webserver':
	packages => 'httpd',
	vhost_dir => '/tmp/web-centos',
}

class webserver(
	$packages = 'UNSET',
	$vhost_dir = 'UNSET', 
) {

     if $pacakges == 'UNSET' {
     	$real_packages = $operatingsystem ? {
       	  /(?i-mx:ubuntu|debian)/        => 'apache2',
       	  /(?i-mx:centos|fedora|redhat)/ => 'httpd',
     	}
     } else {
	$real_packages = $packages
     }

     if $vhost_dir == 'UNSET' { 
     	$real_vhost_dir = $operatingsystem ? {
       	  /(?i-mx:ubuntu|debian)/        => '/tmp/web-debian',
       	  /(?i-mx:centos|fedora|redhat)/ => '/tmp/web-centos',
     	}
     } else {
	$real_vhost_dir = $vhost_dir
     }

     package { "$real_packages": 
	ensure => present,
     }

     file { 'vhost_dir':
     	path   => $real_vhost_dir,
     	ensure => directory,
     	mode   => '0750',
     	owner  => 'bigchoo',
     	group  => 'bigchoo',
     }

}
