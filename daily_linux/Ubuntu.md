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
