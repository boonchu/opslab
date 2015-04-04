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
