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

```

###### Reference:
   * [learning kitchen from vagrant](https://github.com/test-kitchen/kitchen-vagrant)
   * [writing the kitchen test](http://kitchen.ci/docs/getting-started/writing-server-test)
