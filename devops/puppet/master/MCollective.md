###### MCollective

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

