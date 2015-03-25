###### Notes
- Two parts of learning: using Chef and Puppet with Vagrant. First part will be Puppet and Chef has its own seperated instructions.

###### 1. Puppet Way: Develop Sample Web with Vagrant 
* initialize new project on vagrant
```
- add new web project
$ cd web

- initialize vagrant
$ vagrant init

- start with box
$ vagrant box list
```

* check out https://atlas.hashicorp.com/boxes/search and choose image from catalog.

* preparing the Vagrantfile
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # serach from cloud https://atlas.hashicorp.com/boxes/search
  # find popularity and high trustworthy image file name
  config.vm.box = "ubuntu/trusty64"

  # map port from host to vm
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # run bootstrap shell script after vagrant up
  config.vm.provision :shell, path: "bootstrap.sh"
end
```

* preparing bootstrap files and web contents
```
% mkdir html
% cat >html/index.html

    _____________________________________________________
   /       _  _  ____    _            _   _              \
   |   ___| || ||___ \  | |_ ___  ___| |_(_)_ __   __ _  |
   |  / _ \ || |_ __) | | __/ _ \/ __| __| | '_ \ / _` | |
   | |  __/__   _/ __/  | ||  __/\__ \ |_| | | | | (_| | |
   |  \___|  |_||_____|  \__\___||___/\__|_|_| |_|\__, | |
   \                                              |___/  /
    -----------------------------------------------------
           \   ^__^
            \  (oo)\_______
               (__)\       )\/\
                   ||----w |
                   ||     ||

% cat >bootstrap.sh
#!/usr/bin/env bash

# update & install
apt-get update
apt-get install -y apache2

# point /var/www at /vagrant mount
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

# restart apache
/etc/init.d/apache2 restart
```

* bring up with vagrant
```
$ vagrant up

- login to vagrant
$ vagrant ssh

- check os version
$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 14.04.2 LTS
Release:        14.04
Codename:       trusty

- check the web local content
$ curl http://localhost

    _____________________________________________________
   /       _  _  ____    _            _   _              \
   |   ___| || ||___ \  | |_ ___  ___| |_(_)_ __   __ _  |
   |  / _ \ || |_ __) | | __/ _ \/ __| __| | '_ \ / _` | |
   | |  __/__   _/ __/  | ||  __/\__ \ |_| | | | | (_| | |
   |  \___|  |_||_____|  \__\___||___/\__|_|_| |_|\__, | |
   \                                              |___/  /
    -----------------------------------------------------
           \   ^__^
            \  (oo)\_______
               (__)\       )\/\
                   ||----w |
                   ||     ||

- content from host also shares in vagrant
$ ls /vagrant
bootstrap.sh  html  Vagrantfile
```

- testing from outside with port 8080
```
% curl localhost:8080

    _____________________________________________________
   /       _  _  ____    _            _   _              \
   |   ___| || ||___ \  | |_ ___  ___| |_(_)_ __   __ _  |
   |  / _ \ || |_ __) | | __/ _ \/ __| __| | '_ \ / _` | |
   | |  __/__   _/ __/  | ||  __/\__ \ |_| | | | | (_| | |
   |  \___|  |_||_____|  \__\___||___/\__|_|_| |_|\__, | |
   \                                              |___/  /
    -----------------------------------------------------
           \   ^__^
            \  (oo)\_______
               (__)\       )\/\
                   ||----w |
                   ||     ||
```

* what is in the box list?
```
% vagrant box list
ubuntu/trusty64 (virtualbox, 14.04)
```

* remove them if software are no longer needed.
```
% vagrant destroy default
% vagrant box remove ubuntu/trusty64
```

###### 2. Next project with multiple instances
* bring up the vagrant
```
$ cd nagios
$ cat Vagrantfile
$ vagrant up
```

* login to individual instance
```
% vagrant box list
vchef/centos-6.5 (virtualbox, 1.0.0)

% vagrant status
Current machine states:

web                       running (virtualbox)
db                        running (virtualbox)
file                      running (virtualbox)
nagios                    running (virtualbox)

% vagrant ssh web
Last login: Fri Mar  7 16:57:20 2014 from 10.0.2.2

[vagrant@localhost ~]$ cat /etc/redhat-release
CentOS release 6.5 (Final)
```

###### 3. First Puppet Manifest
  - [~\(:$)/~](https://github.com/boonchu/opslab/tree/vagrant1/vagrant/puppetlab1)

###### 4. Second Puppet Manifest to manage IPTABLES on CentOS 6.x
  - [~\(:$)/~](https://github.com/boonchu/opslab/tree/vagrant1/vagrant/puppetlab2)
  
###### 5. [Chef Recipes: Vagrant on Chef](https://github.com/boonchu/opslab/tree/vagrant1/vagrant/cheflab1)

###### Notes:
```
- if you are running out of space, try to remove some images.
bigchoo at vm1 in ~/Documents/opslab/vagrant/puppetlab3 (master●)
$ vagrant box list
centos-6.5-x86_64-minimal (virtualbox, 0)
centos64-x86_64-minimal   (virtualbox, 0)

bigchoo at vm1 in ~/Documents/opslab/vagrant/puppetlab3 (master●)
$ vagrant box remove centos64-x86_64-minimal
Removing box 'centos64-x86_64-minimal' (v0) with provider 'virtualbox'...
```

###### references
   - [Vagrant Crash Course](https://sysadmincasts.com/episodes/42-crash-course-on-vagrant-revised)
