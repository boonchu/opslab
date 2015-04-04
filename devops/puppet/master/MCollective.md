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
$ mco ping -I vmk3.cracker.org
---- ping statistics ----
No responses received
see solution if mcollective daemon is not binding to network port
http://serverfault.com/questions/342653/mcollective-daemon-not-binding-a-network-socket
```
###### Reference
  - [Puppet Orchestration](https://docs.puppetlabs.com/pe/latest/orchestration_invoke_cli.html)
  - [Mcollective configuration](https://docs.puppetlabs.com/mcollective/configure/server.html)
  - [Getting started](https://docs.puppetlabs.com/mcollective/reference/basic/gettingstarted_redhat.html)
