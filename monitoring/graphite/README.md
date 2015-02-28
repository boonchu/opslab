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
* Very unfortunate... this app framework requires django version below 1.6. I need to install django-1.4.x web framework for graphite-web (note that [django-1.6.x is incompatible](https://docs.djangoproject.com/en/1.4/releases/1.4/#updated-default-project-layout-and-manage-py))
```
$ sudo yum install python-django python-django-tagging
$ python
>>> import django
>>> django.VERSION
(1, 6, 10, 'final', 0)
>>> quit()
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
