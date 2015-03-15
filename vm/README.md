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
* KVM networking
  - by default, VM has only access through 192.168.122.0/24 network internally. You must create bridge on the hypervisor host. Follows these steps to do add bridge interfaces.
```
- checking default bridge from software installation.
# nmcli con show
NAME     UUID                                  TYPE            DEVICE
docker0  13b501c1-8667-4d4d-a0b8-a215c1b5f481  bridge          docker0
virbr0   9d4ede10-e707-4e80-9a8e-5e7d366b06ba  bridge          virbr0
enp0s3   2a60be4b-f64b-409f-8cc8-5ccf99c00eaf  802-3-ethernet  enp0s3

- check the current bridge 192.168.122.0/24
# nmcli con show virbr0 | grep IP4.ADDR
IP4.ADDRESS[1]:                         192.168.122.1/24

- use nmcli or nmtui from Network Manager to create new bridge. I need only 14 nodes that can talk from this bridge.
# nmcli con down vmbr0 && nmcli con up vmbr0

- new bridge should start with what subnet you needs.
# nmcli con show vmbr0 | grep IP4.ADDR
IP4.ADDRESS[1]:                         192.168.1.50/28
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
