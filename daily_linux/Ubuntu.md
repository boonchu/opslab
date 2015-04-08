###### Ubuntu 
* debian package management 
```
- show dependencies
$ apt-cache depends penguin-command
penguin-command
  Depends: libc6
  Depends: libsdl-image1.2
  Depends: libsdl-mixer1.2
  Depends: libsdl1.2debian
  Conflicts: penguin-command:i386
  
- find package from content name
$ dpkg -S $(which nm-connection-editor)
network-manager-gnome: /usr/bin/nm-connection-editor
$ dpkg -l | grep network-manager
ii  network-manager                     0.9.8.8-0ubuntu7                  amd64        network management framework (daemon and userspace tools)

- find package which file belong to
$ sudo apt-file update
$ apt-file search [file name] | head -2 (to list package name)
$ apt-file list [package name] (to list content in package)

```
* what is your ubuntu release
```
# lsb_release -sc
trusty
```
* how to recompile the sources
```
- build source file
$ sudo apt-get install dpkg-dev libglib2.0-dev
$ sudo apt-get build-dep network-manager-gnome
$ apt-get source network-manager-gnome
$ cd network-manager-applet-0.X.X.X/
$ ./configure --prefix=/opt/nm/ --disable-more-warnings \
  --disable-migration --enable-introspection=no \
  --with-modem-manager-1=no --with-gtkver=2 --without-bluetooth
$ make
$ sudo make install
$ cd /opt/nm/

- take content and transfer
$ tar czf ~/Desktop/nm-custom.tgz 

- copy to target host
$ sudo mkdir /opt/nm
$ cd /opt/nm
$ sudo tar xvf ~/nm-custom.tgz
$ sudo apt-get --no-install-recommends install libnm-glib-vpn1

- run command 
$ sudo /opt/nm/bin/nm-connection-editor
```
* install [Network Manager on 14.04](https://help.ubuntu.com/community/NetworkManager)
```
sudo apt-get install network-manager network-manager-gnome
sudo start network-manager

- start with configuration tool
$ sudo nm-connection-editor

- check device status after bonding setup
$ nmcli d
DEVICE     TYPE              STATE
bond0      bond              connected
eth2       802-3-ethernet    connecting (getting IP configuration)
eth1       802-3-ethernet    connected
eth0       802-3-ethernet    unmanaged
$ nmcli c
NAME                      UUID                                   TYPE              TIMESTAMP-REAL
bond0 slave 1             792fa476-6a40-4a89-bb26-13d7cde11ba9   802-3-ethernet    Fri 03 Apr 2015 11:23:54 AM PDT
Wired connection 2        98768046-06c8-4f57-ad02-1428b58d74b2   802-3-ethernet    Fri 03 Apr 2015 11:03:53 AM PDT
Wired connection 1        7fd7ce64-21f9-44a7-93af-edaf0de781ba   802-3-ethernet    Fri 03 Apr 2015 11:03:53 AM PDT
bond0                     4931af17-687b-43ef-813e-232d54836072   bond              Fri 03 Apr 2015 11:23:54 AM PDT
bond0 slave 2             78183cd6-5c89-440d-aaac-cd17674d2995   802-3-ethernet    Fri 03 Apr 2015 11:23:54 AM PDT
```
* setup time server
```
command line 
$ echo "America/Los_Angeles" | sudo tee /etc/timezone
$ sudo dpkg-reconfigure --frontend noninteractive tzdata

command line (14.04 trusty)
- use tzselect to consult TZ
$ tzselect
- use timedatectl
$ timedatectl set-timezone America/Los_Angeles

interactive tool
$ sudo dpkg-reconfigure tzdata
```
* setup firewall
```
# ufw status
Status: inactive
```
* list package content
```
# dpkg-query -L pe-puppet | head -10
/.
/var
/var/log
/var/log/pe-puppet
/var/opt
/var/opt/lib
/var/opt/lib/pe-puppet
/var/opt/lib/pe-puppet/reports
/var/opt/lib/pe-puppet/ssl
/usr

# dpkg-query -c pe-puppet | head -10
/var/lib/dpkg/info/pe-puppet.prerm
/var/lib/dpkg/info/pe-puppet.postinst
/var/lib/dpkg/info/pe-puppet.md5sums
/var/lib/dpkg/info/pe-puppet.postrm
```
* firewall troubleshooting
```
- if puppet firewall has been set, you may need to turn off
sudo iptables-save > /root/firewall.rules
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -F

```
* if you are encountering like this sources, so frastrating.
```
W: Failed to fetch http://us.archive.ubuntu.com/ubuntu/dists/trusty-updates/universe/i18n/Translation-en  Cannot initiate the connection to us.archive.ubuntu.com:80 (2001:67c:1562::13). - connect (101: Network is unreachable) [IP: 2001:67c:1562::13 80]

try this solution:
http://askubuntu.com/questions/37753/how-can-i-get-apt-to-use-a-mirror-close-to-me-or-choose-a-faster-mirror

here is mine apt sources.lst
# West Coast US (California):
deb http://us-west-1.ec2.archive.ubuntu.com/ubuntu/ precise main restricted universe multiverse
deb http://us-west-1.ec2.archive.ubuntu.com/ubuntu/ precise-updates main restricted universe multiverse
deb http://us-west-1.ec2.archive.ubuntu.com/ubuntu/ precise-security main restricted universe multiverse

# West Coast US (Oregon):
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ precise main restricted universe multiverse
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ precise-updates main restricted universe multiverse
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ precise-security main restricted universe multiverse
```
* trusty soruces repository guide
```
http://ubuntuguide.org/wiki/Ubuntu_Trusty_Packages_and_Repositories

- clean up after update
$ sudo apt-get update 
$ sudo apt-get clean
$ sudo apt-get autoremove
```
