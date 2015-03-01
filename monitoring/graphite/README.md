###### [David Josephsen: Alert on What You Draw - Nagios Con 2014](https://www.youtube.com/watch?v=wvoOT4QbSkY)
###### [Graphite Design Paper] (http://www.aosabook.org/en/graphite.html)
###### Graphite 
  * What is graphite? see from this [link](http://graphite.wikidot.com/screen-shots)
  * What components in graphite? 
    - [Whisper](https://github.com/graphite-project/whisper/blob/master/README.md) - fixed size time series db
    - [Carbon](https://github.com/graphite-project/carbon/blob/master/README.md) - metric processing
    - [Graphite-web](https://github.com/graphite-project/graphite-web/blob/master/README.md) - web front and http service

- ###### Building rpm with CI
  * [learning how to build rpm with CI process](https://github.com/boonchu/CI)

- ###### Building rpm with fpm
* test from CentOS 7.x
* mkdir /tmp/graphite && cd /tmp/graphite
* build carbon rpm
```
git clone git@github.com:graphite-project/carbon.git
fpm --rpm-os linux --python-install-bin /usr/local/bin -s python -t rpm carbon/setup.py
```
* build graphite-web
```
git clone git@github.com:graphite-project/graphite-web.git
fpm --rpm-os linux --python-install-bin /usr/local/bin -s python -t rpm graphite-web/setup.py
```
* build whisper
```
git clone git@github.com:graphite-project/whisper.git
fpm --rpm-os linux --python-install-bin /usr/local/bin -s python -t rpm whisper/setup.py
```
###### Install Graphite Dev Mode
* install rpm files
```
sudo yum localinstall python-carbon-0.9.10-1.noarch.rpm  \
   python-graphite-web-0.10.0_alpha-1.noarch.rpm  \
   python-whisper-0.9.10-1.noarch.rpm
```
* use Django version below 1.6
```
$ sudo yum install -y python-pip
$ pip install 'django<1.6'
```
* [graphite-web] Configure HTTPD
```
root@server1 1091 \> cp /opt/graphite/examples/example-graphite-vhost.conf /etc/httpd/conf.d/graphite.conf

Adding retention: /opt/graphite/conf/storage-schemas.conf
[default]
pattern = .*
retentions = 10s:4h, 1m:3d, 5m:8d, 15m:32d, 1h:1y

root@server1 1096 \> systemctl restart httpd
```
* [graphite-web] Configure dashboard
```
cd /opt/graphite/conf
cp dashboard.conf.example dashboard.conf
```
* [graphite-web] Configure static content
```
root@server1 1066 \> PYTHONPATH=/opt/graphite/webapp  django-admin.py collectstatic \
    --noinput --settings=graphite.settings
==| OR |==
root@server1 1071 \> django-admin.py collectstatic --noinput \
    --settings=graphite.settings --pythonpath=/opt/graphite/webapp
```
* [graphite-web] Configure database (default is SQLite DB)
```
root@server1 1090 \> PYTHONPATH=/opt/graphite/webapp  django-admin.py syncdb --settings=graphite.settings
You just installed Django's auth system, which means you don't have any superusers defined.
Would you like to create one now? (yes/no): yes
Username (leave blank to use 'root'):
Email address: bigchoo@gmail.com
Password:
Password (again):
Superuser created successfully.
Installing custom SQL ...
Installing indexes ...
Installed 0 object(s) from 0 fixture(s)

root@server1 1162 \> sqlite3 /opt/graphite/storage/graphite.db
SQLite version 3.7.17 2013-05-20 00:56:22
Enter ".help" for instructions
Enter SQL statements terminated with a ";"

sqlite> .tables
account_mygraph             dashboard_dashboard
account_profile             dashboard_dashboard_owners
account_variable            dashboard_template
account_view                dashboard_template_owners
account_window              django_admin_log
auth_group                  django_content_type
auth_group_permissions      django_session
auth_permission             events_event
auth_user                   tagging_tag
auth_user_groups            tagging_taggeditem
auth_user_user_permissions  url_shortener_link

sqlite> select * from auth_user;
```
* [carbon-cache] reconfigure carbon-cache
```
root@server1 1036 \> cat /etc/carbon/storage-schemas.conf
[carbon]
pattern = ^carbon\.
retentions = 60:90d

[default_1min_for_1day]
pattern = .*
retentions = 60s:1d

[collectd]
pattern = ^collectd.*
retentions = 10s:1d,1m:7d,10m:1y

root@server1 1037 \> cat /etc/carbon/storage-aggregation.conf
[min]
pattern = \.min$
xFilesFactor = 0.1
aggregationMethod = min
```
* [carbon-cache] start carbon-cache
```
root@server1 1005 \> /usr/bin/carbon-cache --config=/etc/carbon/carbon.conf start

check log message at /var/log/carbon/carbon-cache-a/console.log
```
* [graphite-web] change your local time-zone and secret key 
```
cd  /opt/graphite/webapp/graphite && cp local_settings.py.example local_settings.py
```
* [graphite-web] start local dev graphite service
```
root@server1 1035 \> /usr/local/bin/run-graphite-devel-server.py /opt/graphite/
Running Graphite from /opt/graphite/ under django development server

/bin/django-admin runserver --pythonpath /opt/graphite/webapp --settings graphite.settings 0.0.0.0:8080
Validating models...

0 errors found
February 28, 2015 - 10:00:06
Django version 1.5.12, using settings 'graphite.settings'
Development server is running at http://0.0.0.0:8080/
Quit the server with CONTROL-C.
```
* [graphic-web] noted that if you encounter problem with 404 error. use this [stackoverflow instruction](http://stackoverflow.com/questions/26505644/graphite-as-django-web-application-returns-404-for-all-static-resources)
* [carbon] testing data push to carbon
   - ensure that data appears on carbon side.
```
root@server1 1027 \> python example-client.py
sending message

--------------------------------------------------------------------------------
system.loadavg_1min 0.00 1425158663
system.loadavg_5min 0.01 1425158663
system.loadavg_15min 0.05 1425158663

20      /var/lib/carbon/whisper/system/loadavg_1min.wsp
20      /var/lib/carbon/whisper/system/loadavg_5min.wsp
20      /var/lib/carbon/whisper/system/loadavg_15min.wsp
```
* [collectd](https://github.com/shawn-sterling/collectd) example of data collection: pull HTTPD metrics from remote host
```
$ sudo yum install -y collectd collectd-apache 

$ cat /etc/httpd/conf.d/status.conf
LoadModule status_module modules/mod_status.so

<location /server-status>
    SetHandler server-status
    Order allow,deny
    Allow from all
</location>

# systemctl reload httpd

$ curl vmk1.cracker.org/server-status?auto
Total Accesses: 12
Total kBytes: 13
Uptime: 505
ReqPerSec: .0237624
BytesPerSec: 26.3604
BytesPerReq: 1109.33
BusyWorkers: 1
IdleWorkers: 5
Scoreboard: W_____.............

$ ls /usr/lib64/collectd/ [<-- plugin ]
$ ls /etc/collectd.d/ [<-- config file ]
```
* [collectd] update [plugins configuration](https://collectd.org/documentation/manpages/collectd.conf.5.shtml)
```
root@vmk1 419 $ cat write_graphite.conf
LoadPlugin "write_graphite"
<Plugin "write_graphite">
 <Node "example">
   Host "server1.cracker.org"
   Port "2003"
   #Prefix "collectd."
   #Postfix ""
   #Protocol "udp"
   #LogSendErrors false
   EscapeCharacter "_"
   SeparateInstances true
   StoreRates false
   AlwaysAppendDS false
 </Node>
</Plugin>
root@vmk1 420 $ cat apache.conf
LoadPlugin apache
<Plugin apache>
      URL "http://localhost/server-status?auto"
     # User "www-user"
     # Password "secret"
     # CACert "/etc/ssl/ca.crt"
</Plugin>
root@vmk1 421 $ cat network.conf
LoadPlugin network
<Plugin network>
  <Server "192.168.1.101" "25826">
    SecurityLevel None
    Interface enp0s3
  </Server>
  MaxPacketSize 1024
  Forward true
  ReportStats true
</Plugin>
root@vmk1 422 $ cat logfile.conf
LoadPlugin "logfile"
<Plugin "logfile">
  LogLevel "info"
  File "/var/log/collectd.log"
  Timestamp true
</Plugin>
```
##### What are inside metrics?
* [carbon-cache] carbon push data in /var/lib/carbon
```
root@server1 1175 \> tree -d /var/lib/carbon/whisper/vmk1_cracker_org/
/var/lib/carbon/whisper/vmk1_cracker_org/
├── apache
│   └── Graphite
│       └── apache_scoreboard
├── cpu
│   ├── 0
│   │   └── cpu
│   └── 1
│       └── cpu
├── interface
│   ├── enp0s3
│   │   ├── if_errors
│   │   ├── if_octets
│   │   └── if_packets
│   └── lo
│       ├── if_errors
│       ├── if_octets
│       └── if_packets
├── load
│   └── load
├── memory
│   └── memory
└── network
    ├── if_octets
    ├── if_packets
    └── total_values

25 directories
```
* [whisper] dump/fetch data
```
root@server1 1180 \> whisper-fetch /var/lib/carbon/whisper/vmk1_cracker_org/apache/Graphite/apache_requests.wsp \
| tail -2
1425157320      253.000000
1425157380      254.000000
```

##### Graphite Dashboard
![dashboard](https://github.com/boonchu/opslab/blob/master/monitoring/graphite/dashboard.png)

##### More metrics
* [http status code bucket distribution](https://github.com/toni-moreno/collectd-apachelog-plugin)

##### how to get custom access log
* [http log web latency](http://httpd.apache.org/docs/2.2/mod/mod_log_config.html)

##### Similar product to Graphite
* RRDTool : 
  * simple round robin data
* OpenTSDB : 
  * requires Hbase and Hadoop. 
  * weakness is the hot spot.
* InfluxDB : 
  * written in go. 
  * use time series DB.
  * HTTP native for pulling/pushing data with role-based security wrapper.
* Kairos : 
  * requires Apache Cassandra clusters. 
  * weakness is the hot spoot since the code from OpenTSDB.

##### Install Graphite Production Mode
* [system] how to work with [supervisord](https://github.com/miguno/graphite-supervisord-rpm)
* [system] another site for [supervisord](https://serversforhackers.com/monitoring-processes-with-supervisord)
* [system] alternate to supervisord, [monit](https://github.com/arnaudsj/monit)
* [security]
```
$ sudo groupadd -g 53012 graphite
$ sudo useradd -u 53012 -g 53012 -d /opt/graphite -s /bin/bash graphite -c "Graphite service account"
$ sudo chage -I -1 -E -1 -m -1 -M -1 -W -1 -E -1 graphite
```
* [run on gunicorn]
* [external storage DB]
```
/opt/graphite/webapp/graphite/local_settings.py

DATABASES = {
  'default': {
    'NAME': 'graphite',
    'ENGINE': 'django.db.backends.mysql',
    'USER': 'graphite',
    'PASSWORD': 'complexpassw0rd',
    'HOST': 'localhost',
    'PORT': '3306',
  }
}

# mysql -e "CREATE USER 'graphite'@'localhost' IDENTIFIED BY 'complexpassw0rd';" -u root -p
# mysql -e "GRANT ALL PRIVILEGES ON graphite.* TO 'graphite'@'localhost';" -u root -p
# mysql -e "CREATE DATABASE graphite;" -u root -p
# mysql -e 'FLUSH PRIVILEGES;' -u root -p
```
