###### Grafana 

Grafana is nice metric visualziation that pull data from metric platform like Graphite, InflexDB or OpenTSDB. 

* after I finished the [part one for graphite setup](https://github.com/boonchu/opslab/blob/master/monitoring/graphite/README.md), I move on to part two for visualization.

###### Installation
* Tested with CentOS 7.x and httpd apache >2.4 
* have CNAME alias. In my case, I use www.cracker.org
* [git clone](https://github.com/torkelo/grafana) and copy to /opt/grafana
* [install elasticsearch](https://devops.profitbricks.com/tutorials/install-elasticsearch-on-centos-7/)
```
$ sudo rpm -Uvh https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.noarch.rpm
$ sudo systemctl daemon-reload

$ edit /etc/elasticsearch/elasticsearch.yml
cluster.name: elasticsearch
node.data: true
transport.tcp.port: 8180
http.port: 9200

$ sudo systemctl start elasiticsearch
$ sudo systemctl enable elasticsearch
$ curl http://server1.cracker.org:9200/
{
  "status" : 200,
  "name" : "Ariann",
  "version" : {
    "number" : "1.3.2",
    "build_hash" : "dee175dbe2f254f3f26992f5d7591939aaefd12f",
    "build_timestamp" : "2014-08-13T14:29:30Z",
    "build_snapshot" : false,
    "lucene_version" : "4.9"
  },
  "tagline" : "You Know, for Search"
}
```
* [configure grafana](http://kaivanov.blogspot.com/2014/07/metrics-visualisation-and-collection.html)
```
$ chown -R root.root /opt/grafana/src
$ cd /opt/grafana/src
$ cp config.sample.js config.js
edit this line and point to Graphite service
>>>     graphiteUrl: "http://server1.cracker.org:8080",
>>>     elasticsearch: "http://server1.cracker.org:9200",
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

![CORS](https://github.com/boonchu/opslab/blob/master/monitoring/grafana/CORS.png)

* note if you encounter the "Cross Origin Request Blocked" issue like mine after you use grafana first time.
```
1) pip install django-cors-headers
2) Edit /opt/graphite/webapp/graphite/app_settings.py and add the below settings :

INSTALLED_APPS = (
    ...
    'corsheaders',
    ...
)

MIDDLEWARE_CLASSES = (
    ...
    'corsheaders.middleware.CorsMiddleware',
    ...
)

CORS_ORIGIN_ALLOW_ALL = True
3) restart graphite
```
* final picture after importing dashboard from Graphite.
![dashboard-graphite](https://github.com/boonchu/opslab/blob/master/monitoring/grafana/dashboard-grafana.png)
