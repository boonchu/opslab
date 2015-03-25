###### How to transform from bare metal network to bridge network

* identify network device

* add new bridge using network manager
```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.080027db949c       no              enp0s3
virbr0          8000.000000000000       yes

2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UP qlen 1000
    link/ether 08:00:27:db:94:9c brd ff:ff:ff:ff:ff:ff
3: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 08:00:27:db:94:9c brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.101/24 brd 192.168.1.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fedb:949c/64 scope link
       valid_lft forever preferred_lft forever
```

* bring the bridge up
```
- manual method
$ sudo /usr/sbin/brctl addbr br0
$ sudo /sbin/ip link set enp0s3 up
$ sudo /usr/sbin/brctl addif br0 enp0s3
$ bridge link show
2: enp0s3 state UP : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 100
$ sudo /sbin/ip addr add 192.168.1.101/24 dev br0
$ sudo /sbin/ip link set br0 up

- automated method
```

