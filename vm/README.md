###### Virtualzation KVM
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
* references
  - [troubleshooting](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Virtualization_Deployment_and_Administration_Guide/sect-Troubleshooting-Common_libvirt_errors_and_troubleshooting.html)
  - [patches](https://rhn.redhat.com/errata/RHBA-2015-0427.html#Red%20Hat%20Enterprise%20Linux%20Server%20%28v.%207%29)
