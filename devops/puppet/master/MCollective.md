###### [MCollective](https://github.com/puppetlabs/mcollective-puppet-agent)

* Check mco live?
```
bigchoo@server1 1009 \> sudo -i -u peadmin
peadmin@server1:~$ mco ping
server1.cracker.org                      time=73.07 ms


---- ping statistics ----
1 replies max: 73.07 min: 73.07 avg: 73.07
```
* Count in puppet
```
$ mco puppet count
Total Puppet nodes: 1

          Nodes currently enabled: 1
         Nodes currently disabled: 0

Nodes currently doing puppet runs: 0
          Nodes currently stopped: 1

       Nodes with daemons started: 1
    Nodes without daemons started: 0
       Daemons started but idling: 1
```
* Show last run summary
```
$ mco rpc puppet last_run_summary
Summary of Config Retrieval Time:

   Average: 3.02

Summary of Total Resources:

   Average: 378

Summary of Total Time:

   Average: 33.22
```
* Summary report
```
$ mco puppet summary
Summary statistics for 1 nodes:

                  Total resources: ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 378.0  max: 378.0
            Out Of Sync resources: ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 2.0    max: 2.0
                 Failed resources: ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 1.0    max: 1.0
                Changed resources: ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 1.0    max: 1.0
  Config Retrieval time (seconds): ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 3.0    max: 3.0
         Total run-time (seconds): ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 33.2   max: 33.2
    Time since last run (seconds): ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  min: 536.0  max: 536.0
```
* runonce with splay
```
$ mco puppet runonce --splay --splaylimit 12

 * [ ============================================================> ] 1 / 1
```
* find which nodes has delay when pulling config
```
$ mco find -S "resource().config_retrieval_time > 1"
server1.cracker.org
```
* find status from node
```
$ mco service httpd status

 * [ ============================================================> ] 1 / 1

   server1.cracker.org: running

Summary of Service Status:

   running = 1
```
* test remote port (61613) on vmk3
```
$ mco ping -I vmk3
---- ping statistics ----
No responses received

see solution if mcollective daemon is not binding to network port
http://serverfault.com/questions/342653/mcollective-daemon-not-binding-a-network-socket

==> /var/log/pe-mcollective/mcollective.log <==
I, [2015-04-04T16:25:21.340242 #18639]  INFO -- : activemq.rb:138:in `on_ssl_connecting' Establishing SSL session with stomp+ssl://mcollective@server1.cracker.org:61613
E, [2015-04-04T16:25:21.342266 #18639] ERROR -- : activemq.rb:148:in `on_ssl_connectfail' SSL session creation with stomp+ssl://mcollective@server1.cracker.org:61613 failed: No route to host - connect(2)
I, [2015-04-04T16:25:21.342346 #18639]  INFO -- : activemq.rb:128:in `on_connectfail' TCP Connection to stomp+ssl://mcollective@server1.cracker.org:61613 failed on attempt 1587

$ sudo cat /var/run/pe-mcollective.pid
18639
$ ps -u -p 18639
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     18639  0.0  1.9 224924 20108 ?        Sl   03:16   0:22 /opt/puppet/bin/ruby /opt/puppet/sbin/mcollectived --pid /var/run/pe-mcollective.pid

- allow the port 61613 on puppet master
$ firewall-cmd --permanent --add-port=61613/tcp
success
$ firewall-cmd --reload
success

$ mco ping -I vmk3
vmk3                                     time=49.64 ms
---- ping statistics ----
1 replies max: 49.64 min: 49.64 avg: 49.64
```
* puppet runonce
```
$ mco puppet runonce -I vmk3
 * [ ============================================================> ] 1 / 1
Finished processing 1 / 1 hosts in 647.33 ms
```
###### Reference
  - [Puppet Orchestration](https://docs.puppetlabs.com/pe/latest/orchestration_invoke_cli.html)
  - [Mcollective configuration](https://docs.puppetlabs.com/mcollective/configure/server.html)
  - [Getting started](https://docs.puppetlabs.com/mcollective/reference/basic/gettingstarted_redhat.html)
