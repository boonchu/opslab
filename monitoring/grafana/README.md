###### Grafana 

Grafana is nice metric visualziation that pull data from metric platform like Graphite, InflexDB or OpenTSDB. 

* after I finished the [part one for graphite setup](https://github.com/boonchu/opslab/blob/master/monitoring/graphite/README.md), I move on to part two for visualization.

###### Installation
* Tested with CentOS 7.x and httpd apache >2.4 
* have CNAME alias. In my case, I use www.cracker.org
* git clone and copy to /opt/grafana
* configure grafana
```
$ chown -R root.root /opt/grafana/src
$ cd /opt/grafana/src
$ cp config.sample.js config.js
edit this line and point to Graphite service
>>>     graphiteUrl: "http://server1.cracker.org:8080",
```
* configure grafana on httpd side
```
$ cat /etc/httpd/conf.d/grafana.conf
<VirtualHost *:80>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, OPTIONS"
    Header set Access-Control-Allow-Headers "origin, authorization, accept"

    ServerAdmin webmaster@localhost
    ServerName www.cracker.org

    DocumentRoot "/opt/grafana/src"

    Alias /grafana  /opt/grafana/src
    <Directory /opt/grafana/src>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/grafana-error.log
    CustomLog /var/log/httpd/grafana-access.log combined

</VirtualHost>
```
* disable selinux if it enable by default. Otherwise, you have to deal with many fixing steps. I do not include in this guide how to fix selinux. My host is up with enforcing mode.
```
$ setenforce 0
```
* reload httpd
```
$ sudo systemctl reload httpd
```
* note if you encounter the same issue like mine after you use grafana first time.
```

```
