###### Virtualzation KVM
* check your hardware if supports virtualization. You may need to enable VT from BIOS motherboard.
```
$ grep '^flags' /proc/cpuinfo | grep -E --color '(vmx|svm)'
```
* virtualization installation
```
$ sudo yum install @virt* libguestfs-tools policycoreutils-python
```
* check qemu connection
```
# virsh -c qemu:///system list
 Id    Name                           State
----------------------------------------------------
```
* SELINUX
  - if you need to relocate the image location, you need to relabel target on the folder.
```
- check target
# semanage fcontext -l | grep virt_image_t
/var/lib/imagefactory/images(/.*)?                 all files          system_u:object_r:virt_image_t:s0
/var/lib/libvirt/images(/.*)?                      all files          system_u:object_r:virt_image_t:s0

- allocate new storage location
# mkdir /images-loc

- make selinux to know new place
# semanage fcontext --add -t virt_image_t '/images-loc(/.*)?'
# restorecon -Rv '/images-loc'
# ls -ltZ /images-loc
```
* error during starting systemctl libvirtd 
```
- check journal log
# journalctl -b -u  libvirtd.service -n 2
-- Logs begin at Sat 2015-03-14 19:20:01 PDT, end at Sat 2015-03-14 21:20:52 PDT. --
Mar 14 21:17:43 server1.cracker.org libvirtd[7784]: End of file while reading data: Input/output error
Mar 14 21:17:45 server1.cracker.org libvirtd[7784]: internal error: could not get interface XML description: File operation failed - Failed to

- check net devices
# cd /sys/class/net; ls -ld * */operstate
lrwxrwxrwx. 1 root root    0 Mar 14 19:20 enp0s3 -> ../../devices/pci0000:00/0000:00:03.0/net/enp0s3
-r--r--r--. 1 root root 4096 Mar 14 19:20 enp0s3/operstate
lrwxrwxrwx. 1 root root    0 Mar 14 19:20 lo -> ../../devices/virtual/net/lo
-r--r--r--. 1 root root 4096 Mar 14 19:20 lo/operstate
lrwxrwxrwx. 1 root root    0 Mar 14 19:21 virbr0 -> ../../devices/virtual/net/virbr0
-r--r--r--. 1 root root 4096 Mar 14 21:19 virbr0/operstate

- check device link state
# virsh nodedev-dumpxml $(virsh nodedev-list | grep enp0s3 | sort | tail -)
<device>
  <name>net_enp0s3_08_00_27_db_94_9c</name>
  <path>/sys/devices/pci0000:00/0000:00:03.0/net/enp0s3</path>
  <parent>pci_0000_00_03_0</parent>
  <capability type='net'>
    <interface>enp0s3</interface>
    <address>08:00:27:db:94:9c</address>
    <link speed='1000' state='up'/>
    <capability type='80203'/>
  </capability>
</device>

- running diagnostic
virsh iface-list --all | tail -n +3 | cut -f2 -d' ' \
   | while read intf; do if [ "$intf" != "" ]; then \
   echo ++++ $intf ++++; virsh iface-dumpxml $intf; fi; done

++++ enp0s3:1 ++++
error: internal error: could not get interface XML description: File operation failed - Failed to read (null)

Solution: [bugzilla 1185850](https://bugzilla.redhat.com/show_bug.cgi?id=1185850)
This was the virtual if dev config that manually created in the past. It brake the startup libvirtd process.
```
* [KVM networking](http://wiki.libvirt.org/page/VirtualNetworking)
  - by default, VM has only access through 192.168.122.0/24 network internally. You must create L3 network bridge on the hypervisor host. Follows these steps to do add bridge interfaces.
```
- assume you have single interface and you must work in this case on console mode only.
- add L3 bridge interface for virtual network
# nmcli con add type bridge autoconnect yes con-name br0 ifname br0
# nmcli con modify bridge.stp no
# nmcli con modify br0 ipv4.address "192.168.1.101/24" ipv4.method manual
# nmcli con modify br0 ipv4.dns 192.168.1.99
# nmcli con modify br0 ipv4.gateway 192.168.1.250
# nmcli con modify br0 ipv4.dns-search CRACKER.ORG

- remove existing interface 
# nmcli con delete enp0s3

- reconfigure bridge slave with current interface
# nmcli con add type bridge-slave autoconnect yes con-name enp0s3 ifname enp0s3 master br0

- it requires to restart NetworkManager
# systemctl stop NetworkManager && systemctl start NetworkManager

- check and validate with ip command
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UP qlen 1000
    link/ether 08:00:27:db:94:9c brd ff:ff:ff:ff:ff:ff
4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN 
    link/ether c6:e0:e4:ce:e7:aa brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
25: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 08:00:27:db:94:9c brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.101/24 brd 192.168.1.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fedb:949c/64 scope link 
       valid_lft forever preferred_lft forever

- check the bridge info
# nmcli con show
NAME    UUID                                  TYPE            DEVICE 
virbr0  6ceafb72-7404-46a3-857e-5a571b61a338  bridge          virbr0 
enp0s3  9dd83a49-d910-41f5-8b8a-34bff9f19249  802-3-ethernet  enp0s3 
br0     649a6273-00f3-4751-8d80-8fa4352b81f4  bridge          br0
# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.080027db949c	no		enp0s3
virbr0		8000.000000000000	yes		

- disable netfilter on bridge device
# cat >> /etc/sysctl.conf <<EOF
 net.bridge.bridge-nf-call-ip6tables = 0
 net.bridge.bridge-nf-call-iptables = 0
 net.bridge.bridge-nf-call-arptables = 0
 EOF
 # sysctl -p /etc/sysctl.conf

```
* KVM storage pool. The storage pool will be useful when provision storage at the production scale.
```
- what is inside default?
# virsh pool-info default
Name:           default
UUID:           556e2d72-586d-4e7e-b822-d04677dfc583
State:          running
Persistent:     yes
Autostart:      yes
Capacity:       12.46 GiB
Allocation:     10.45 GiB
Available:      2.01 GiB

# virsh pool-dumpxml default
<pool type='dir'>
  <name>default</name>
  <uuid>556e2d72-586d-4e7e-b822-d04677dfc583</uuid>
  <capacity unit='bytes'>13377732608</capacity>
  <allocation unit='bytes'>11215470592</allocation>
  <available unit='bytes'>2162262016</available>
  <source>
  </source>
  <target>
    <path>/var/lib/libvirt/images</path>
    <permissions>
      <mode>0755</mode>
      <owner>-1</owner>
      <group>-1</group>
    </permissions>
  </target>
</pool>

# ls -ltZ /var/lib/libvirt/images
-rw-------. root root system_u:object_r:virt_image_t:s0 rhel7.0.qcow2
```
* KVM virtual disk provision (qcow2 format)
```
# mkdir /virtimages

# semanage fcontext --add -t virt_image_t '/virtimages(/.*)?'

# restorecon -Rv /virtimages/
restorecon reset /virtimages context unconfined_u:object_r:default_t:s0->unconfined_u:object_r:virt_image_t:s0

# ls -aZ /virtimages/
drwxr-xr-x. root root unconfined_u:object_r:virt_image_t:s0 .
dr-xr-xr-x. root root system_u:object_r:root_t:s0      ..

# semanage fcontext -l | grep virt_image_t
/var/lib/imagefactory/images(/.*)?                 all files          system_u:object_r:virt_image_t:s0
/var/lib/libvirt/images(/.*)?                      all files          system_u:object_r:virt_image_t:s0
/virtimages(/.*)?                                  all files          system_u:object_r:virt_image_t:s0

# qemu-img create -f qcow2 /virtimages/vm01.qcow2 3G
Formatting '/virtimages/vm01.qcow2', fmt=qcow2 size=3221225472 encryption=off cluster_size=65536 lazy_refcounts=off

# ls -aZ /virtimages/
drwxr-xr-x. root root unconfined_u:object_r:virt_image_t:s0 .
dr-xr-xr-x. root root system_u:object_r:root_t:s0      ..
-rw-r--r--. root root unconfined_u:object_r:virt_image_t:s0 vm01.qcow2
```
* KVM new instance creation [Method One: virt-install]
```
- add DHCP MAC/DNS resolution name
# host 192.168.1.51
51.1.168.192.in-addr.arpa domain name pointer v1.cracker.org.

dhcpd.conf
host v1 {
        hardware ethernet 08:00:27:00:00:AA;
        fixed-address 192.168.1.51;
        option host-name "v1";
        filename "pxelinux.0";
        next-server 192.168.1.101;
}

- use kickstart validator utility to check syntax 
# ksvalidator /tmp/v1.cfg

- run script
# cat v1.sh
#! /usr/bin/env bash

ks_location="/tmp/v1.cfg"
os_location="http://ks.cracker.org/Kickstart/RHEL7/rhel7.1-beta-core/"

virt-install --connect=qemu:///system \
    --network bridge=br0 \
    --initrd-inject="${ks_location}" \
    --extra-args="ks=file://${ks_location} console=tty0 console=ttyS0,115200" \
    --name=v1.cracker.org \
    --disk /virtimages/vm01.qcow2,size=3 \
    --ram=1200 \
    --vcpus=3 \
    --check-cpu \
    --accelerate \
    --hvm \
    --location="${os_location}" \
    --graphics none \
    --mac="08:00:27:00:00:AA"

- if you want to destroy the current instance, use the steps.
# virsh destroy v1.cracker.org 
Domain v1.cracker.org destroyed
# virsh undefine v1.cracker.org
```
* KVM new instance creation [Method TWO: pxe]
```
#! /usr/bin/env bash

virt-install --hvm --connect qemu:///system \
--network=bridge:br0 --pxe --graphics vnc \
--name v1.cracker.org --ram=1200 --vcpus=2 \
--os-type=linux --os-variant=rhel7 \
--disk path=/virtimages/vm01.qcow2,size=3 \
--mac="08:00:27:00:00:AA"
```
* KVM for DevOps 
```
- create a new instance 
 # virsh -c qemu:///system list --all
 Id    Name                           State
----------------------------------------------------
 -     vm01.cracker.org               shut off
 
- retire old instance
# virsh stop vm01.cracker.org 
# virsh undefine vm01.cracker.org
Domain vm01.cracker.org has been undefined

```
* references
  - [troubleshooting](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Virtualization_Deployment_and_Administration_Guide/sect-Troubleshooting-Common_libvirt_errors_and_troubleshooting.html)
  - [patches](https://rhn.redhat.com/errata/RHBA-2015-0427.html#Red%20Hat%20Enterprise%20Linux%20Server%20%28v.%207%29)
  - [veewee kvm provisioning tool](https://github.com/jedi4ever/veewee/blob/master/doc/kvm.md)
