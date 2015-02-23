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
   * two luns (/dev/sdb, /dev/sdc) presents and become part of lvm vgdb1 and exports as logical group lvol1
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
