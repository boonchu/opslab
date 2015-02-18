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
* list of rpm files
```
\> ls -ltr *.rpm
-rw-rw-r--. 1 bigchoo bigchoo   82469 Feb 17 14:30 python-carbon-0.9.10-1.noarch.rpm
-rw-rw-r--. 1 bigchoo bigchoo 2331908 Feb 17 21:26 python-graphite-web-0.9.10-1.noarch.rpm
-rw-rw-r--. 1 bigchoo bigchoo   21261 Feb 17 21:30 python-whisper-0.9.10-1.noarch.rpm
```
