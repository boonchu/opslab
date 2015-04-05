###### Trick
* Validate syntax
```
$ puppet parser validate init.pp
or 
$ puppet parser dump pre.pp
--- pre.pp(class my_fw::pre (block
  (resource firewall
    ('000 accept all icmp'
      (proto => 'icmp')
      (action => 'accept')))
  (resource firewall
    ('001 accept all to lo interface'
      (proto => 'all')
      (iniface => 'lo')
      (action => 'accept')))
  (resource firewall
    ('002 accept related established rules'
      (proto => 'all')
      (state => ([] 'RELATED' 'ESTABLISHED'))
      (action => 'accept')))
  (resource firewall
    ('100 allow ssh access'
      (port => '22')
      (proto => tcp)
      (action => accept)))
))
```   
* find config location from puppet agent
```
# puppet config print --section agent config
/etc/puppetlabs/puppet/puppet.conf
```
* enable noop mode
```
[agent]
  noop = true
```
* run with noop mode
```
$ puppet agent -t --noop
$ puppet apply --noop /path/to/puppetcode.pp
```
