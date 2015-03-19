###### After [Deployed war application](https://github.com/boonchu/opslab/blob/vagrant1/vagrant/cheflab1/DEPLOY_APP.md), it's time to think about how to use it.
* starting with firewall rules to allow guest instance to be useable from outside world.
* use [simple_iptables cookbook](https://supermarket.chef.io/cookbooks/simple_iptables) from supermarket
```
- add "include_receipe 'simple_iptables'" to 'recipes/default.rb' file
- add 'depends "simple_iptables"' to metadata.rb file
- run "berks install"
```
* add recipe firewall to default recipe.
```
# Allow SSH
simple_iptables_rule "ssh" do
  rule "--proto tcp --dport 22"
  jump "ACCEPT"
end

# Allow TOMCAT
simple_iptables_rule "tomcat" do
  rule [ "--proto tcp --dport 8080" ]
  jump "ACCEPT"
end
```
* kitchen converge and login
```
$ kitchen converge
$ kitchen login
$ sudo iptables -nvL
Chain ssh (1 references)
 pkts bytes target     prot opt in     out     source               destination
  106  9225 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:22 /* ssh */

Chain tomcat (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp dpt:8080 /* tomcat */
```
