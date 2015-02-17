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

```
bigchoo@server1-eth0 ~/lab/opslab/daily_linux (master)*$ /usr/lib64/nagios/plugins/check_dummy --help
check_dummy v2.0.1 (nagios-plugins 2.0.1)
Copyright (c) 1999 Ethan Galstad <nagios@nagios.org>
Copyright (c) 1999-2014 Nagios Plugin Development Team
        <devel@nagios-plugins.org>

This plugin will simply return the state corresponding to the numeric value
of the <state> argument with optional text


Usage:
 check_dummy <integer state> [optional text]

Options:
 -h, --help
    Print detailed help screen
 -V, --version
    Print version information

Send email to help@nagios-plugins.org if you have questions regarding use
of this software. To submit patches or suggest improvements, send email to
devel@nagios-plugins.org
```
* see [samples of plugins](https://github.com/harisekhon/nagios-plugins) from contributor who use nagios 

Reference:
- http://sharadchhetri.com/2013/03/02/how-to-install-and-configure-nagios-nrpe-in-centos-and-red-hat/
