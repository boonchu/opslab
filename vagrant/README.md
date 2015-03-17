###### Vagrant Tool
* initialize new project on vagrant
```
- add new web project
$ cd web

- initialize vagrant
$ vagrant init

- start with box
$ vagrant box list
```

* check out https://atlas.hashicorp.com/boxes/search and choose image

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
``
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