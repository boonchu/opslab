class my_motd {

	class { 'motd':
  		motd_local_enabled => false,
  		add_puppet_warning => true,
	}
	motd::fragment { 'extra motd':
  		content => "This will be addded to /etc/motd\n",
	}
	motd::fragment { 'extra motd from template':
  		content => template('my_motd/motd.erb'),
	}

}
