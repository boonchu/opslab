###### After [Deployed war application](https://github.com/boonchu/opslab/blob/vagrant1/vagrant/cheflab1/DEPLOY_APP.md), it's time to think about how to use it.
* starting with firewall rules to allow guest instance to be useable from outside world.
* use [iptables cookbook](https://supermarket.chef.io/cookbooks/iptables) from supermarket
```
- add "include_receipe 'iptables'" to 'recipes/default.rb' file
- add 'depends "iptables"' to metadata.rb file
- run "berks install"

- I no longer can 'kitchen login' after kitchen converge because new iptables cookbook apply default setting.

```
