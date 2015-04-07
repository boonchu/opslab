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
* adding firewall port 6379
```
        # Allow Redis
        firewall { '100 allow redis access':
                port   => '6379',
                proto  => tcp,
                action => accept,
        }
        
# iptables -vnL
Chain INPUT (policy ACCEPT 14 packets, 1599 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            /* 000 accept all icmp */
    0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0            /* 001 accept all to lo interface */
 6953 3604K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* 002 accept related established rules */ state RELATED,ESTABLISHED
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport ports 6379 /* 100 allow redis access */
    3   192 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport ports 22 /* 100 allow ssh access */
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* 999 drop all other requests */
```
* log looks sync after firewall allows port
```
[9096] 07 Apr 12:35:09.112 * MASTER <-> SLAVE sync: receiving 18 bytes from master
[9096] 07 Apr 12:35:09.112 * MASTER <-> SLAVE sync: Flushing old data
[9096] 07 Apr 12:35:09.113 * MASTER <-> SLAVE sync: Loading DB in memory
[9096] 07 Apr 12:35:09.113 * MASTER <-> SLAVE sync: Finished with success
```
###### Testing Redis cluster
```
- pushing from master
[bigchoo@vmk2 ~]$ redis-cli -h vmk3.cracker.org
- you need basic authentication before setting key-value
vmk3.cracker.org:6379> set a "hello"
(error) NOAUTH Authentication required.
vmk3.cracker.org:6379> auth redis
OK
vmk3.cracker.org:6379> set a "hello"
OK
vmk3.cracker.org:6379> get a
"hello"
vmk3.cracker.org:6379>quit

- retrieving from slave
[bigchoo@vmk2 ~]$ redis-cli -h vmk4.cracker.org
vmk4.cracker.org:6379> auth redis
OK
vmk4.cracker.org:6379> get a
"hello"

- mode set NOT to write on slave
vmk4.cracker.org:6379> SET users:GeorgeWashington "job: President, born:1732, dislikes: cherry trees"
(error) READONLY You can't write against a read only slave.

- transaction mode
[bigchoo@vmk2 ~]$ redis-cli -h vmk3.cracker.org
vmk3.cracker.org:6379> auth redis
OK
vmk3.cracker.org:6379> MULTI
OK
vmk3.cracker.org:6379> SET population 6
QUEUED
vmk3.cracker.org:6379> INCRBY population 10
QUEUED
vmk3.cracker.org:6379> INCR population
QUEUED
vmk3.cracker.org:6379> EXEC
1) OK
2) (integer) 16
3) (integer) 17

- sorting
vmk3.cracker.org:6379> zadd countries 9 thailand
(integer) 1
vmk3.cracker.org:6379> zadd countries 10 USA
(integer) 1
vmk3.cracker.org:6379> zadd countries 0.8 japan
(integer) 1
vmk3.cracker.org:6379> zadd countries 0.5 korea
(integer) 1
vmk3.cracker.org:6379> zadd countries 100 maxico
(integer) 1
vmk3.cracker.org:6379> zrange countries 0 -1
1) "korea"
2) "japan"
3) "thailand"
4) "USA"
5) "maxico"

- hashing
vmk3.cracker.org:6379> hmset userinfo:1 username boonchu password redis email bigchoo@gmail.com
OK
vmk4.cracker.org:6379> hgetall userinfo:1
1) "username"
2) "boonchu"
3) "password"
4) "redis"
5) "email"
6) "bigchoo@gmail.com"
vmk4.cracker.org:6379> hmget userinfo:1 username email
1) "boonchu"
2) "bigchoo@gmail.com"
```
* This is good slide to explain how [Redis cluster](http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&ved=0CCUQFjAB&url=http%3A%2F%2Fredis.io%2Fpresentation%2FRedis_Cluster.pdf&ei=TDkkVbajH8OrogTpl4CACQ&usg=AFQjCNFgKv0Vvqs1wRFGz_Egx1wIotzMTg&sig2=Za00HII1Dw0xh9dUJxpVPg&bvm=bv.90237346,d.cGU) works
* This is other two projects that I want to test with this redis cluster. Since my host is running out memory, I have to stop right here. I perhaps consider ec2 for server deployment, not using local centos/ubuntu kickstart host.
  - [docker-twemproxy](https://github.com/jgoodall/docker-twemproxy)
  
