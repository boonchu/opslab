###### Starting to deploy application
  * setup with [punter simple war app](https://github.com/tcotav/punter)
```
$ cd /tmp && git clone git@github.com:tcotav/punter.git
$ cp /tmp/punter/punter.war [chef cookbook folder]/files/default/
$ mkdir -p files/default/
$ mv punter.war files/default
```
  * append new custom deployment recipe in 'recipes/default.rb'
```
# https://docs.chef.io/resource_cookbook_file.html
cookbook_file "/var/lib/tomcat6/webapps/punter.war" do
  source "punter.war"
  mode 00744
  owner 'root'
  group 'root'
end
```
  * append new test to 'test/integration/default/bats/tomcat.bats'
```
@test "war is placed in proper location " {
  run [ -f /var/lib/tomcat6/webapps/punter.war ]
  [ "$status" -eq 0 ]
}

@test "war is unrolled" {
  run [ -d /var/lib/tomcat6/webapps/punter ]
  [ "$status" -eq 0 ]
}
```
  * run kitchen.
```
$ kitchen converge
$ kitchen verify
$ kitchen login (to check active running port)

- perfect, I can get the good result from curl. :-)
$ curl http://localhost:8080/punter/punt/
{'status':'ok'}
```

*  review again on [tomcat cookbook](https://supermarket.chef.io/cookbooks/tomcat) Con't later.
   - it listens to ipv6, not ipv4. Needs to find the way to tweak it.
   - updated [march 19th] from stackoverflow [solution](http://serverfault.com/questions/390840/how-does-one-get-tomcat-to-bind-to-ipv4-address)

```
problem:
java    17891 tomcat   35u  IPv6  69854      0t0  TCP *:webcache (LISTEN))
```
```
solution:
- change attribute setting, 'attributes/default.rb'
node.default['tomcat']['catalina_options'] = '-Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses'

- at convergence time, kicthen restarted tomcat6
         * execute[wait for tomcat6] action nothing (skipped due to action :nothing)
       Recipe: cheflab1::default
        (up to date)
         * service[tomcat6] action restart
           - restart service service[tomcat6]
```

* when I play with it, as system admin. I felt like the bare metal image need to be tweaking. Since it has no lsof, no system admin tools, firewall protected, etc. Firewall is the problem for me, since I need this guest instance to be exposure port 8080 to outside. A lot of work to be done. Stay tuned in next chapter after ServerSpec.
```
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
 257K  212M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
    7   420 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
    8   352 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22
   21   920 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited
```
###### Reference:
   * [learning kitchen from vagrant](https://github.com/test-kitchen/kitchen-vagrant)
   * [writing the kitchen test](http://kitchen.ci/docs/getting-started/writing-server-test)
