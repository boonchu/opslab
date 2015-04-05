class test_file::s2 {

	class dns::params {
		$dnsserver    = '2.2.2.2'
  		$searchdomain = 'puppetlabs.s2'
	}

	class dns(
  		$dnsserver    = $dns::params::dnsserver,
  		$searchdomain = $dns::params::searchdomain
	) inherits dns::params {

  		file { '/etc/test_file2.conf':
    			content => "search ${searchdomain}\n nameserver ${dnsserver}\n",
  		}

	}

	include dns

}
