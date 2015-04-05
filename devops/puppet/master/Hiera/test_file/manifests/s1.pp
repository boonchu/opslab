class test_file::s1 {
       $dnsserver    = '1.1.1.1'
       $searchdomain = 'puppetlabs.s1'

       file { '/etc/test_file1.conf':
                ensure  => present,
                content => "search ${searchdomain}\n nameserver ${dnsserver}\n",
       }
}
