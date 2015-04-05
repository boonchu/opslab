# http://docs.puppetlabs.com/references/2.6.1/function.html#extlookup
class test_file::s3 {

	$extlookup_datadir    = "/etc/puppetlabs/puppet/modules/test_file/data"
	$extlookup_precedence = ["%{fqdn}", "domain_%{domain}", "common"] 

	include dns

	class dns {
  		$dnsserver    = extlookup('dnsserver')
  		$searchdomain = extlookup('searchdomain')

  		file { '/etc/test_file3.conf':
    			content => "search ${searchdomain}\n nameserver ${dnsserver}\n",
  		}
	}

}
