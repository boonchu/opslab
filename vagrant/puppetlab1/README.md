###### Starting with puppet lab 1

* start with centos box image and bring up the instance
```
$ vagrant box add centos64-x86_64-minimal centos64-x86_64-minimal.box
$ vagrant up
```

* change to my motd
```
$ rm -f puppet/modules/motd/files/motd && cat >puppet/modules/motd/files/motd
                                                             ,d
                                                             88
8b,dPPYba,  88       88 8b,dPPYba,  8b,dPPYba,   ,adPPYba, MM88MMM
88P'    "8a 88       88 88P'    "8a 88P'    "8a a8P_____88   88
88       d8 88       88 88       d8 88       d8 8PP"""""""   88
88b,   ,a8" "8a,   ,a88 88b,   ,a8" 88b,   ,a8" "8b,   ,aa   88,
88`YbbdP"'   `"YbbdP'Y8 88`YbbdP"'  88`YbbdP"'   `"Ybbd8"'   "Y888
88                      88          88
88                      88          88

88            88          88
88            88        ,d88
88            88      888888
88 ,adPPYYba, 88,dPPYba,  88
88 ""     `Y8 88P'    "8a 88
88 ,adPPPPP88 88       d8 88
88 88,    ,88 88b,   ,a8" 88
88 `"8bbdP"Y8 8Y"Ybbd8"'  88

$ vagrant provision
```

* login to my instance
```
% vagrant ssh
Last login: Tue Mar 17 13:39:37 2015 from 10.0.2.2
8b,dPPYba,  88       88 8b,dPPYba,  8b,dPPYba,   ,adPPYba, MM88MMM
88P'    "8a 88       88 88P'    "8a 88P'    "8a a8P_____88   88
88       d8 88       88 88       d8 88       d8 8PP"""""""   88
88b,   ,a8" "8a,   ,a88 88b,   ,a8" 88b,   ,a8" "8b,   ,aa   88,
88`YbbdP"'   `"YbbdP'Y8 88`YbbdP"'  88`YbbdP"'   `"Ybbd8"'   "Y888
88                      88          88
88                      88          88

88            88          88
88            88        ,d88
88            88      888888
88 ,adPPYYba, 88,dPPYba,  88
88 ""     `Y8 88P'    "8a 88
88 ,adPPPPP88 88       d8 88
88 88,    ,88 88b,   ,a8" 88
88 `"8bbdP"Y8 8Y"Ybbd8"'  88

[vagrant@localhost ~]$ cat /etc/redhat-release
CentOS release 6.4 (Final)
```

* reference:
  - [video puppet crash course](https://sysadmincasts.com/episodes/8-learning-puppet-with-vagrant)
  - search github for any new puppet modules
  - [community puppet](forge.puppetlabs.com)
