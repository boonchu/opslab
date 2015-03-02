###### iSCSI

* limitation:
  * Budget concern use Ethernet 1G bps [compares to Fiber Channel or Infiniband](http://en.wikipedia.org/wiki/List_of_device_bit_rates)
  * use iSCSI over 10G or Infiniband (very expensive)

* security over wire?
  * IPSec encapulate over ethernet packets.
  * using CHAP for authenication on lun security.  
  
* Hardwares
  * Ethernet based adapter or iSCSI 1GE adapter.
  
* Basics
  * target (lun/storage provider) and initiator (server)
  * based on IQN

* examples 
  * output from initator side,
   * single lun (/dev/sdb) presents and become part of lvm vgweb01 and exports as logical group lvol1

* [target] iSCSI target setup
```
# yum install targetcli
# systemctl enable target
# systemctl start target
```
* [target] firewalld enabled?
```
# systemctl status firewalld
# firewall-cmd --permanent --add-port=3260/tcp && firewall-cmd --reload
```
* [target] create 1GB lvol1 for storage web application
```
# vgs vgweb01
  VG      #PV #LV #SN Attr   VSize    VFree
  vgweb01   1   0   0 wz--n- 1020.00m 1020.00m
# lvs vgweb01
  LV    VG      Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvol1 vgweb01 -wi-a----- 1020.00m
```
* [target] run targetcli to provision new iscsi target lun
```
# targetcli
/backstores/block/ [enter]
/backstores/block> create vmk3_cracker_org.vgweb01_lvol1 /dev/vgweb01/lvol1 [enter]
/backstores/block> cd /iscsi/ [enter]
>>> create IQN device
/iscsi> create iqn.2015-03.com.cracker:vmk3 [enter]
>>> create ACLs
/iscsi> cd /iscsi/iqn.2015-03.com.cracker:vmk3/ [enter]
/iscsi/iqn.20....cracker:vmk3> cd tpg1/acls/ [enter]
/iscsi/iqn.20...mk3/tpg1/acls> create iqn.2015-03.com.cracker:vmk1 [enter]
/iscsi/iqn.20...mk3/tpg1/acls> create iqn.2015-03.com.cracker:vmk2 [enter]
>>> create LUNs
/iscsi/iqn.20...mk3/tpg1/acls> cd /iscsi/iqn.2015-03.com.cracker:vmk3/tpg1/luns/ [enter]
/iscsi/iqn.20...mk3/tpg1/luns> create /backstores/block/vmk3_cracker_org.vgweb01_lvol1 [enter]
>>> run on port 3260
/iscsi/iqn.20.../tpg1/portals> cd /iscsi/iqn.2015-03.com.cracker:vmk3/tpg1/portals/ [enter]
/iscsi/iqn.20.../tpg1/portals> delete 0.0.0.0 3260
/iscsi/iqn.20.../tpg1/portals> create 192.168.1.163 3260
```
* [target] show config
```
/iscsi/iqn.20.../tpg1/portals> cd /
/> ls
o- / ......................................................................................................................... [...]
  o- backstores .............................................................................................................. [...]
  | o- block .................................................................................................. [Storage Objects: 1]
  | | o- vmk3_cracker_org.vgweb01_lvol1 ...................................... [/dev/vgweb01/lvol1 (1020.0MiB) write-thru activated]
  | o- fileio ................................................................................................. [Storage Objects: 0]
  | o- pscsi .................................................................................................. [Storage Objects: 0]
  | o- ramdisk ................................................................................................ [Storage Objects: 0]
  o- iscsi ............................................................................................................ [Targets: 1]
  | o- iqn.2015-03.com.cracker:vmk3 ...................................................................................... [TPGs: 1]
  |   o- tpg1 ............................................................................................... [no-gen-acls, no-auth]
  |     o- acls .......................................................................................................... [ACLs: 2]
  |     | o- iqn.2015-03.com.cracker:vmk1 ......................................................................... [Mapped LUNs: 1]
  |     | | o- mapped_lun0 ........................................................ [lun0 block/vmk3_cracker_org.vgweb01_lvol1 (rw)]
  |     | o- iqn.2015-03.com.cracker:vmk2 ......................................................................... [Mapped LUNs: 1]
  |     |   o- mapped_lun0 ........................................................ [lun0 block/vmk3_cracker_org.vgweb01_lvol1 (rw)]
  |     o- luns .......................................................................................................... [LUNs: 1]
  |     | o- lun0 ...................................................... [block/vmk3_cracker_org.vgweb01_lvol1 (/dev/vgweb01/lvol1)]
  |     o- portals .................................................................................................... [Portals: 1]
  |       o- 192.168.1.163:3260 ............................................................................................... [OK]
  o- loopback ......................................................................................................... [Targets: 0]
```
* [initiator]
```
# iscsiadm -m discovery -t st -p 192.168.1.165 -l
192.168.1.165:3260,1 iqn.2015-02.org.cracker:remotedisk1

[root@vmk3 bigchoo]# lsblk -l -fs | tail -3
vgdb1-lvol1    xfs               186bf264-f7ad-4221-b125-0ec6bb0c29c1   /var/mysql/data
sdb            LVM2_member       7uUjb9-yfte-nTGU-CiSh-u8O8-8ZeS-PKHrkX
sdc            LVM2_member       KAmdu6-Y0Ja-8DXs-Z4JF-DNaR-KdIQ-jkSHlp
```
* copy (rsync) data from old location to new prepared storage one.
* change configuration /etc/my.conf (if you have a farm cluster, you might consider Chef/Puppet)
```
[bigchoo@vmk3 ~]$ cat /etc/my.cnf
[mysqld]
user=mysql
datadir=/var/mysql/data
socket=/var/mysql/data/mysql.sock

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
```
