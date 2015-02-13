##### Operational related topic about Linux users

- all test using CentOS 7.x

###### Monitoring with nagios (latest - 4.0.7)
* install nagios service
```
$ sudo yum install -y gcc glibc glibc-common make gd gd-devel net-snmp 
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
* Make 
```
$ make all
$ sudo make install
```
