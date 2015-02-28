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
root@server1 1096 \> systemctl reload httpd
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
