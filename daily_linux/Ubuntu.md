###### Ubuntu 
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
