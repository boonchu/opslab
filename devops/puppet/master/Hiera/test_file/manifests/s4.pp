class test_file::s4 {
	
	include dns

	class dns {
  		$dnsserver    = hiera('dnsserver')
  		$searchdomain = hiera('searchdomain')

		file { '/etc/test_file4.conf':
    			content => "search ${searchdomain}\n nameserver ${dnsserver}\n",
  		}
	}

}
