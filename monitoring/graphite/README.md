###### [David Josephsen: Alert on What You Draw - Nagios Con 2014](https://www.youtube.com/watch?v=wvoOT4QbSkY)
###### Graphite 
  * What is graphite? see from this [link](http://graphite.wikidot.com/screen-shots)
  * What components in graphite? 
    - [Whisper](https://github.com/graphite-project/whisper/blob/master/README.md)
    - [Carbon](https://github.com/graphite-project/carbon/blob/master/README.md)
    - [Graphite-web](https://github.com/graphite-project/graphite-web/blob/master/README.md)

- ###### Building rpm with CI
  * [learning how to build rpm with CI process](https://github.com/boonchu/CI)

- ###### Building rpm with fpm
- CentOS 
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
```
* [carbon-cache] start carbon-cache
```
root@server1 1005 \> /usr/bin/carbon-cache --config=/etc/carbon/carbon.conf start
```
* [graphite-web] change your local time-zone and secret key 
```
cd  /opt/graphite/webapp/graphite && cp local_settings.py.example local_settings.py
```
* [graphite-web] start local dev graphite service
```
root@server1 1027 \> /usr/local/bin/run-graphite-devel-server.py /opt/graphite/
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

* [system] how to work with [supervisord](https://github.com/miguno/graphite-supervisord-rpm)
