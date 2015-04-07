###### Virtual Resource Design Patterns
  * By default, any resource you describe in a client’s Puppet config will get sent to the client and be managed by that client. However, resources can be specified in a way that marks them as virtual, meaning that they will not be sent to the client by default. 
  * examples:
```
learning/modules/manifests (master)*$ rm -f /tmp/{fruit,berry}
learning/modules/manifests (master)*$ puppet apply ./basket.pp
Notice: Compiled catalog for server1.cracker.org in environment production in 0.35 seconds
Notice: /Stage[main]/Main/Basket[fruit]/File[/tmp/fruit]/ensure: created
Notice: /Stage[main]/Main/Basket[berry]/File[/tmp/berry]/ensure: created
Notice: Finished catalog run in 0.05 seconds
learning/modules/manifests (master)*$ cat /tmp/fruit
apple
learning/modules/manifests (master)*$ cat /tmp/berry
watermelon
```
