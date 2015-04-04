class resolver (
   $nameservers,
   $domain_name,
   $search_domain
 ) {

   file { '/etc/resolv.conf':
     ensure  => file,
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
     content => template('resolver/resolv.conf.erb'),
   }
 }
