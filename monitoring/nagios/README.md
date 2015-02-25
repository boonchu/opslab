###### [Latest Nagios Conference 2014](http://tinyurl.com/km8pezb)
###### [Nagios product information](http://www.nagios.com/handouts/)
###### Monitoring with nagios (latest - 4.0.7)
* [server] install nagios service
```
$ sudo yum install -y httpd php gcc glibc glibc-common make gd gd-devel net-snmp 
$ sudo useradd nagios
$ sudo groupadd nagcmd
$ sudo usermod -G nagcmd nagios
$ sudo usermod -G nagcmd apache
$ mkdir ~/nagios && cd ~/nagios
$ wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.7.tar.gz 
$ wget http://www.nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz 
$ tar zxvf nagios-4.0.7.tar.gz nagios-plugins-2.0.3.tar.gz
$ cd nagios-4.0.7
$ ./configure --with-command-group=nagcmd
```
* [server] suggested output from configure
```
General Options:
 -------------------------
        Nagios executable:  nagios
        Nagios user/group:  nagios,nagios
       Command user/group:  nagios,nagcmd
             Event Broker:  yes
        Install ${prefix}:  /usr/local/nagios
    Install ${includedir}:  /usr/local/nagios/include/nagios
                Lock file:  ${prefix}/var/nagios.lock
   Check result directory:  ${prefix}/var/spool/checkresults
           Init directory:  /etc/rc.d/init.d
  Apache conf.d directory:  /etc/httpd/conf.d
             Mail program:  /bin/mail
                  Host OS:  linux-gnu
          IOBroker Method:  epoll

 Web Interface Options:
 ------------------------
                 HTML URL:  http://localhost/nagios/
                  CGI URL:  http://localhost/nagios/cgi-bin/
 Traceroute (used by WAP):
```
* [server] run make to install services 
```
$ make all
$ sudo make install
$ sudo make install-int
$ sudo make install-commandmode
$ sudo make install-config
```
* [server] install web components
```
$ sudo make install-webconf
```
* [server] add nagios administration user
```
$ sudo htpasswd -s -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
```
* [server] start apache httpd service
```
$ sudo system start httpd
```
* [server] install nagios plugins service
```
$ cd ~/nagios/nagios-plugins-2.0.3
$ ./configure --with-nagios-user=nagios --with-nagios-group=nagios
$ make
$ sudo make install
```
* [server] verify configuration
```
$ sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```
* [server] enable and start nagios service
```
$ sudo chkconfig --add nagios
$ sudo chkconfig --level 35 nagios on
$ sudo systemctl start nagios
$ sudo systemctl reload httpd
```
* [server] login nagios from web browser http://your host/nagios

* [clients] install nrpe nagios clent and plugins at managed nodes
```
$ yum install -y openssl nrpe nagios-plugins-all nagios-plugins-nrpe
$ ls -l /usr/lib64/nagios/plugins/
```
* [clients] review the configration /etc/nagios/nrpe.cfg
* [clients] enable nrpe nagios client service
```
$ sudo systemctl enable nrpe
$ sudo systemctl start nrpe
```
* [server] promote a new cluster environment to be monitored
  - create /usr/local/nagios/etc/objects/clusterA
  - update parameter cfg_dir at /usr/local/nagios/etc/nagios.cfg
  - update parameter $USER1$ at /usr/local/nagios/etc/resource.cfg [use Chef or puppet to provision cfg, discussed in serverfault](http://serverfault.com/questions/335984/nrpe-and-the-user1-variable)
  - create three files from hosts.cfg, services.cfg, commands.cfg
```
edit >>> /usr/local/nagios/etc/nagios.cfg
cfg_dir=/usr/local/nagios/etc/objects/clusterA
edit >>> 
$USER1$=/usr/lib64/nagios/plugins

bigchoo@server1-eth0 1128 $ cat commands.cfg
define command {
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}

bigchoo@server1-eth0 1129 $ cat services.cfg
define service {
        use generic-service
        host_name vmk1.cracker.org
        service_description PING
        check_command check_ping!100.0,20%!500.0,60%
}

define service {
        use generic-service
        host_name vmk1.cracker.org
        service_description Current Load
        check_command check_nrpe!check_load
}

define service {
        use generic-service
        host_name vmk1.cracker.org
        service_description Total Processes
        check_command check_nrpe!check_users
}

bigchoo@server1-eth0 1130 $ cat hosts.cfg
define host {
        use linux-server
        host_name vmk1.cracker.org
        alias nodejs-docker1
        address 192.168.1.161
}
```
* [server] reload configuration
```
$ sudo systemctl reload nagios
$ sudo systemctl reload httpd
```
* [server] validate the connection
```
$ /usr/lib64/nagios/plugins/check_nrpe -H 192.168.1.161
NRPE v2.15
```
![screens_output](https://github.com/boonchu/opslab/blob/master/monitoring/nagios/services_page.png)
* noticed from web UI that still have failed status. Use this step to clear the issue
  - edit parameter allowed_hosts /etc/nagios/nrpe.cfg 
  - restart nrpe nagios client service
```
allowed_hosts=127.0.0.1,[IP of your nagios host]

$ sudo systemctl restart nrpe
```

###### What is the [nagios plugins](http://nagios-plugins.org/documentation/) and why is so important?
* Understand the return code from check. It helps you to know how alerts setup.
```
bigchoo@vmk1 1015 $ /usr/lib64/nagios/plugins/check_dummy 3 "Unknown"
UNKNOWN: Unknown
bigchoo@vmk1 1012 $ /usr/lib64/nagios/plugins/check_dummy 2 "Critical"
CRITICAL: Critical
bigchoo@vmk1 1013 $ /usr/lib64/nagios/plugins/check_dummy 1 "Warning"
WARNING: Warning
bigchoo@vmk1 1014 $ /usr/lib64/nagios/plugins/check_dummy 0 "OK"
OK: OK
```
###### types of nrpe check (image sources from nagios)
  - direct check
![direct](https://github.com/boonchu/opslab/blob/master/monitoring/nagios/direct_nrpe.png)

  - indirect check
![indirect](https://github.com/boonchu/opslab/blob/master/monitoring/nagios/indirect_nrpe.png)
* sample plugins. 
  - I support HP DL360G 12 cores, 24 threads hardware with
some good size of local disk array. I need to monitoring array and alert it. this check requires
hp array cli software and some pre-configured sudoers to allow script to run array cli.

```
$ cd /usr/lib64/nagios/plugins && wget "http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=3521&cf_id=30" -O check_hpacucli
$ sudo ./check_hpacucli -i
check_hpacucli OK -    array A: OK    physicaldrive 1I:1:1 (port 1I.....
$ grep nagios /etc/sudoers
nagios ALL=NOPASSWD: /usr/local/bin/hpacucli
```
  - If this is not type of RAID you've, you can verify from this [github](https://github.com/glensc/nagios-plugin-check_raid/blob/master/README.md)

##### What happens when I monitor multiple hosts in the farm or cluster?
* how to confgiure hostgroup.cfg
* enable regex for hostname syntax in the same farm
```
bigchoo@server1 1067 \> grep regex nagios.cfg
# Values: 1 = enable regexp matching, 0 = disable regexp matching
use_regexp_matching=0
# (* and ?).  If the option is ENABLED, regexp matching occurs
use_true_regexp_matching=0
```

###### see [samples of plugins](https://github.com/harisekhon/nagios-plugins) from contributor who use nagios 

Reference:
- http://sharadchhetri.com/2013/03/02/how-to-install-and-configure-nagios-nrpe-in-centos-and-red-hat/
- http://www.slideshare.net/nagiosinc/nagios-conference-2014-jim-prins-passive-monitoring-with-nagios
