###### Redis configuration
  - [Redis Puppet](https://github.com/echocat/puppet-redis)
  
###### Setup
* use setup from this code 
* create two group of redis {master and slave} on puppet console UI
* pass 'my_redis' class parameters in which 'master' or 'slave' selectively choose and input into either 'master' or 'slave' 
```
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

- check the log file
# cat /var/log/redis_slave.log
[8586] 07 Apr 12:06:24.983 * Max number of open files set to 10032
[8586] 07 Apr 12:06:24.983 # Creating Server TCP listening socket 0.0.0.0:6379: bind: Address already in use
[9096] 07 Apr 12:12:15.105 * Max number of open files set to 10032
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 2.8.4 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in stand alone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 9096
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

[9096] 07 Apr 12:12:15.106 # Server started, Redis version 2.8.4
[9096] 07 Apr 12:12:15.106 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
[9096] 07 Apr 12:12:15.106 * The server is now ready to accept connections on port 6379
[9096] 07 Apr 12:12:15.106 * Connecting to MASTER vmk3.cracker.org:6379
[9096] 07 Apr 12:12:15.123 * MASTER <-> SLAVE sync started
[9096] 07 Apr 12:13:16.601 # Timeout connecting to the MASTER...
[9096] 07 Apr 12:13:16.601 * Connecting to MASTER vmk3.cracker.org:6379
[9096] 07 Apr 12:13:16.605 * MASTER <-> SLAVE sync started

- if you notice, MASTER still block the 6379 port. firewall need to be modified for allowing service.
```
