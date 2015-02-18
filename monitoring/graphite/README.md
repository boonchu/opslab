###### [David Josephsen: Alert on What You Draw - Nagios Con 2014](https://www.youtube.com/watch?v=wvoOT4QbSkY)
###### Graphite 
  * What is graphite? see from this [link](http://graphite.wikidot.com/screen-shots)
  * What components in graphite? 
    - [Whisper](https://github.com/graphite-project/whisper/blob/master/README.md)
    - [Carbon](https://github.com/graphite-project/carbon/blob/master/README.md)
    - [Graphite-web](https://github.com/graphite-project/graphite-web/blob/master/README.md)

- ###### Building the rpm 
  * [learning how to build rpm with CI process](https://github.com/boonchu/CI)

- ###### Building rpm with fpm
- CentOS 
* build carbon rpm
```
PKG_VERSION=0.9.10
wget http://launchpad.net/graphite/0.9/${PKG_VERSION}/+download/carbon-${PKG_VERSION}.tar.gz
fpm --rpm-os linux --python-install-bin /usr/local/bin -s python -t rpm carbon-0.9.10/setup.py
```
* build graphite-web
```
PKG_VERSION=0.9.10
wget http://launchpad.net/graphite/0.9/${PKG_VERSION}/+download/graphite-web-${PKG_VERSION}.tar.gz
fpm --rpm-os linux --python-install-bin /usr/local/bin -s python -t rpm graphite-web-0.9.10/setup.py
```
* build whisper
```
PKG_VERSION=0.9.10
wget http://launchpad.net/graphite/0.9/${PKG_VERSION}/+download/whisper-${PKG_VERSION}.tar.gz
fpm --rpm-os linux --python-install-bin /usr/local/bin -s python -t rpm whisper-0.9.10/setup.py
```
* install rpm files
```
sudo yum localinstall -y python-carbon-0.9.10-1.noarch.rpm \
                   python-whisper-0.9.10-1.noarch.rpm \
                   python-graphite-web-0.9.10-1.noarch.rpm
```
* install django-1.4.x web framework for graphite-web (note that [django-1.6.x is incompatible](https://docs.djangoproject.com/en/1.4/releases/1.4/#updated-default-project-layout-and-manage-py))
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
sudo yum localinstall -y python-carbon python-whisper grpahite-web supervisor
```
