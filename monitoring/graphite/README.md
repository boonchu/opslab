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
* [graphite-web] Configure HTTPD
```
root@server1 1091 \> cp /opt/graphite/examples/example-graphite-vhost.conf /etc/httpd/conf.d/graphite.conf

Adding retention: /opt/graphite/conf/storage-schemas.conf
[default]
pattern = .*
retentions = 10s:4h, 1m:3d, 5m:8d, 15m:32d, 1h:1y

root@server1 1096 \> systemctl restart httpd
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
* [graphite-web] start graphite
```
root@server1 1027 \> /usr/local/bin/run-graphite-devel-server.py /opt/graphite/
Running Graphite from /opt/graphite/ under django development server

/bin/django-admin runserver --pythonpath /opt/graphite/webapp --settings graphite.settings 0.0.0.0:8080
Could not import graphite.local_settings, using defaults!
/opt/graphite/webapp/graphite/settings.py:233: UserWarning: SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security
  warn('SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security')
Could not import graphite.local_settings, using defaults!
/opt/graphite/webapp/graphite/settings.py:233: UserWarning: SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security
  warn('SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security')
Validating models...

0 errors found
February 28, 2015 - 17:51:21
Django version 1.5.12, using settings 'graphite.settings'
Development server is running at http://0.0.0.0:8080/
Quit the server with CONTROL-C.
```
- Fedora 21
* installation
```
$ sudo yum localinstall -y python-carbon python-whisper grpahite-web supervisor
$ tree /etc/graphite-web/
/etc/graphite-web/
├── dashboard.conf
├── local_settings.py
├── local_settings.pyc
└── local_settings.pyo

```
* adding two ini files for supervisord
```
bigchoo@server2 224 $ tail -2 /etc/supervisord.conf
[include]
files = supervisord.d/*.ini
```
