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

* [client] install nrpe nagios clent and plugins at managed nodes
```
$ yum install -y openssl nrpe nagios-plugins-all nagios-plugins-nrpe
$ ls -l /usr/lib64/nagios/plugins/
```
* [client] review the configration /etc/nagios/nrpe.cfg
* [client] enable nrpe nagios client service
```
$ sudo systemctl enable nrpe
$ sudo systemctl start nrpe
```
* [server] promote a new cluster environment to be monitored
  - create /usr/local/nagios/etc/objects/clusterA
  - update parameter cfg_dir at /usr/local/nagios/etc/nagios.cfg
```
cfg_dir=/usr/local/nagios/etc/objects/clusterA
```
  - create three files from hosts.cfg, services.cfg, commands.cfg
```
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
