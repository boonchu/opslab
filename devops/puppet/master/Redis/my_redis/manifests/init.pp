class my_redis(
	$type = 'master',
	$master = 'dummy',
) {
	
	class { 'redis::install': 
    		redis_version  => '2:2.8.4-2',
    		redis_package  => true,
	}

	service { 'redis-server': 
		ensure => stopped,
		enable => false,
	}

	if $type == 'master' {
		redis::server { 'master':
      			redis_memory    => '1g',
      			redis_ip        => '0.0.0.0',
      			redis_port      => 6379,
      			running         => true,
      			enabled         => true,
      			requirepass     => 'redis',
  		}
	}

	if $type == 'slave' {
		redis::server { 'slave':
      			redis_memory    => '1g',
      			redis_ip        => '0.0.0.0',
      			redis_port      => 6379,
      			running         => true,
      			enabled         => true,
      			requirepass     => 'redis',
      			slaveof         => $master,
      			masterauth      => 'redis',
  		}	
	}

}
