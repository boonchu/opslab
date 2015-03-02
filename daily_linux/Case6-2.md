##### Part Two - Nic Teaming RHCE 7 exam
* list ethernet devices prior adding to Virtualbox
* configure two Nics to Virtualbox, bridge for each adapter. Note to ensure that links are up after virtual machine is active.
```
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:64:1f:17 brd ff:ff:ff:ff:ff:ff
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:d8:50:ac brd ff:ff:ff:ff:ff:ff
```
* adding LACP team device
```
[root@vmk3 ~]# nmcli con add type team con-name team0 ifname team0 config '{ "runner": {"name": "lacp"}}'
Connection 'team0' (4eaad9b0-80e6-432d-8fb8-63080f21e766) successfully added.
[root@vmk3 ~]# nmcli c sh
NAME           UUID                                  TYPE            DEVICE
team0          4eaad9b0-80e6-432d-8fb8-63080f21e766  team            team0
System enp0s3  984f6028-e6fa-491e-a0fd-63135a19eb40  802-3-ethernet  enp0s3
```
* adding two slaves
```
[root@vmk3 ~]# nmcli con mod team0 ipv4.address '10.16.0.33/24'
[root@vmk3 ~]# nmcli con mod team0 ipv4.method manual
[root@vmk3 ~]# nmcli con add type team-slave con-name team0-p1 ifname enp0s8 master team0
[root@vmk3 ~]# nmcli con add type team-slave con-name team0-p2 ifname enp0s9 master team0
```
* ensure to check full duplex mode on real ethernet card on hypervisor side
```
bigchoo@vm1 ~ % sudo ifconfig en9 media 100baseTX mediaopt full-duplex
bigchoo@vm1 ~ % sudo ifconfig en13 media 100baseTX mediaopt full-duplex
bigchoo@vm1 ~ % sudo ifconfig en9 up
bigchoo@vm1 ~ % sudo ifconfig en13 up
```
* sample output when two switch ports are up. For my case, I use port 47,48
```
*Mar  1 01:01:47.814: %LINK-3-UPDOWN: Interface FastEthernet1/0/48, changed state to up
*Mar  1 01:01:54.819: %LINK-3-UPDOWN: Interface FastEthernet1/0/47, changed state to up
```
* check teamd status
```
[root@vmk3 ~]# teamdctl team0 state
setup:
  runner: lacp
ports:
  enp0s9
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
    runner:
      aggregator ID: 4, Selected
      selected: yes
      state: current
  enp0s8
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
    runner:
      aggregator ID: 4, Selected
      selected: yes
      state: current
runner:
  active: yes
  fast rate: no
```
* ports status on switch side shows as disconnected. pretty odd.
```
s1#show interfaces Port-channel 2 status
Port      Name               Status       Vlan       Duplex  Speed Type
Po2                          notconnect   1            auto   auto

s1#show etherchannel summary | include SD
2      Po2(SD)         LACP      Fa1/0/47(w) Fa1/0/48(w)
```
* use nmtui to reconfigure the teamd json file. use this [reference](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/sec-Configure_a_Network_Team_Using-the_Command_Line.html)
![nmtui-team0](https://github.com/boonchu/opslab/blob/master/daily_linux/nmtui-team0.png)
* look like switch shows as fall back mode.
```
s1#show interfaces Port-channel 2 etherchannel | include Fa|Protocol
Protocol            =   LACP
  0     00     Fa1/0/47 Active             0
Time since last port bundled:    0d:00h:30m:31s    Fa1/0/47
Time since last port Un-bundled: 0d:00h:35m:14s    Fa1/0/48
```
* gateway looks fine too.
```
[bigchoo@vmk3 ~]$ ping -I team0 10.16.0.1
PING 10.16.0.1 (10.16.0.1) from 10.16.0.33 team0: 56(84) bytes of data.
64 bytes from 10.16.0.1: icmp_seq=1 ttl=255 time=0.831 ms
64 bytes from 10.16.0.1: icmp_seq=2 ttl=255 time=4.27 ms
^C
--- 10.16.0.1 ping statistics ---
```
