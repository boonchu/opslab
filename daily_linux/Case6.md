##### Setup LACP - Link Aggregation Control Protocol (using my switches from CCNA exam study)
* basically, I want to make two wired ethernet redundency in case of outage on either switch port.
* ideally, I need to make at least 2 switches to be redundency each other. I do not have time to test.
* testing with single cisco C3750 switch (treat as access layer switch, no Spanning-Tree)
* setup vlan 2 for this lab (blue cables from picture)
![bond0](https://github.com/boonchu/opslab/blob/master/daily_linux/bond0.png)
* setup vlan 99 for management purpose (yellow cables)
* configure switch port 47,48 for vlan 2
```
interface Port-channel2
 switchport trunk encapsulation dot1q
 switchport trunk native vlan 2
 switchport trunk allowed vlan 2-99
 switchport mode trunk
!
interface FastEthernet1/0/47
 description nic team 1
 switchport trunk encapsulation dot1q
 switchport trunk native vlan 2
 switchport trunk allowed vlan 2-99
 switchport mode trunk
 speed 100
 duplex full
 channel-protocol lacp
 channel-group 2 mode active
!
interface FastEthernet1/0/48
 description nic teaming 2
 switchport trunk encapsulation dot1q
 switchport trunk native vlan 2
 switchport trunk allowed vlan 2-99
 switchport mode trunk
 speed 100
 duplex full
 channel-protocol lacp
 channel-group 2 mode active
!
```
* status from ether-channel
```
s1#show etherchannel summary | include SU
2      Po2(SU)         LACP      Fa1/0/47(w) Fa1/0/48(w)

s1#show interfaces Port-channel 2 status

Port      Name               Status       Vlan       Duplex  Speed Type
Po2                          connected    trunk      a-full  a-100

s1#show interfaces Port-channel 2 etherchannel | include Fa|Protocol
Protocol            =   LACP
  0     00     Fa1/0/47 Active             0
  0     00     Fa1/0/48 Active             0
Time since last port bundled:    0d:00h:32m:01s    Fa1/0/48
Time since last port Un-bundled: 0d:00h:32m:39s    Fa1/0/48
```
* if trunk is failing and no connection, I need to check several things from network speed, 
duplex mode, allowed VLAN on trunk port. if STP involved, need to double check STP.
* testing with my Mac Pro. I have two thunderbolt ethernets. 
```
bigchoo@vm1 ~ % networksetup -listBonds
interface name: bond0
{
	user-defined-name: bond0
	devices: en13, en9
}
bigchoo@vm1 ~ % ifconfig en13
en13: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=10b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV>
	ether 68:5b:35:cc:a6:20
	media: autoselect (100baseTX <half-duplex>)
	status: active
bigchoo@vm1 ~ % ifconfig en9
en9: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=10b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV>
	ether 68:5b:35:cc:a6:20
	media: autoselect (100baseTX <half-duplex>)
	status: active
```
* my two nics still show half-duplex which is wrong. enabled it to full duplex mode.
```
$ sudo ifconfig en9 media 100baseTX mediaopt full-duplex
$ sudo ifconfig en13 media 100baseTX mediaopt full-duplex
$ sudo ifconfig en9 up
$ sudo ifconfig en13 up
```
* console shows two ports (47,48) active.
```
*Mar  1 00:28:40.906: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet1/0/47, changed state to up
*Mar  1 00:28:49.798: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet1/0/48, changed state to up
```
* checking bond0 (two ports nics teaming; en9 and en13)
```
% ifconfig bond0
bond0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=b<RXCSUM,TXCSUM,VLAN_HWTAGGING>
	ether 68:5b:35:cc:a6:20
	inet6 fe80::6a5b:35ff:fecc:a620%bond0 prefixlen 64 scopeid 0x13
	inet 10.16.0.33 netmask 0xffffff00 broadcast 10.16.0.255
	nd6 options=1<PERFORMNUD>
	media: autoselect (100baseTX <full-duplex>)
	status: active
	bond interfaces: en13 en9
```
* ping itself and gateway IP
```
% ping 10.16.0.1
PING 10.16.0.1 (10.16.0.1): 56 data bytes
Request timeout for icmp_seq 0
64 bytes from 10.16.0.1: icmp_seq=1 ttl=255 time=6.381 ms
64 bytes from 10.16.0.1: icmp_seq=2 ttl=255 time=1.467 ms
```
* pull one cable out and observe the ping result. switch complains about port down as usual.
```
s1#
*Mar  1 01:02:50.612: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet1/0/48, changed state to down
s1#
*Mar  1 01:02:51.610: %LINK-3-UPDOWN: Interface FastEthernet1/0/48, changed state to down
```
* no interruption on ping result. Looks good.
```
64 bytes from 10.16.0.1: icmp_seq=267 ttl=255 time=1.907 ms
64 bytes from 10.16.0.1: icmp_seq=268 ttl=255 time=1.337 ms
64 bytes from 10.16.0.1: icmp_seq=269 ttl=255 time=1.335 ms
64 bytes from 10.16.0.1: icmp_seq=270 ttl=255 time=1.759 ms
64 bytes from 10.16.0.1: icmp_seq=271 ttl=255 time=2.534 ms
```
* Nic Teaming works on Mac pro now. What else? 
  * Proceeding to experiment with Virtualbox and Cent OS 7.x
  * Going to use [iSCSI migration on MariaDB project](https://github.com/boonchu/opslab/blob/master/daily_linux/Case7.md) as example service for testing.
