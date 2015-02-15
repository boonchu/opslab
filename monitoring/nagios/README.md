###### Monitoring with nagios (latest - 4.0.7)
* install nagios service
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
* suggested output from configure
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
* run make to install services 
```
$ make all
$ sudo make install
$ sudo make install-int
$ sudo make install-commandmode
$ sudo make install-config
```
* install web components
```
$ sudo make install-webconf
```
* add nagios administration user
```
$ sudo htpasswd -s -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
```
* start apache httpd service
```
$ sudo system start httpd
```
* install nagios plugins service
```
$ cd ~/nagios/nagios-plugins-2.0.3
$ ./configure --with-nagios-user=nagios --with-nagios-group=nagios
$ make
$ sudo make install
```
* verify configuration
```
$ sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```
* enable and start nagios service
```
$ sudo chkconfig --add nagios
$ sudo chkconfig --level 35 nagios on
$ sudo systemctl start nagios
$ sudo systemctl reload httpd
```
* login nagios from web browser http://your host/nagios

* install nrpe nagios clent and plugins at managed nodes
```
$ yum install -y nrpe nagios-plugins-all openssl
$ ls -l /usr/lib64/nagios/plugins/
```
* review the configration /etc/nagios/nrpe.cfg
* enable nrpe nagios client service
```
sudo systemctl enable nrpe
sudo systemctl start nrpe
```
