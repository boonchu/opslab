###### Starting to deploy application
  * setup with simple war app
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
  * run kitchen. It fails from the test.
```
$ kitchen converge
$ kitchen verify

```
*  review again on [tomcat cookbook](https://supermarket.chef.io/cookbooks/tomcat)
   - it listens to ipv6, not ipv4. Needs to find the way to tweak it.
```
$ kitchen login (to check active running port)

java    17891 tomcat   35u  IPv6  69854      0t0  TCP *:webcache (LISTEN))

- perfect, I can get the good result from curl. :-)
$ curl http://localhost:8080/punter/punt/
{'status':'ok'}
```

###### Reference:
   * [learning kitchen from vagrant](https://github.com/test-kitchen/kitchen-vagrant)
