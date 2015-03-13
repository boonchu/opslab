###### Starting with Linux Kernl Module Programning
* preparing host for developing kernel module
```
$ sudo yum install -y kernel-devel kernel-headers gcc
```
* run make
```
$ make
```
$ install kernel module and verify
```
$ sudo insmod helloworld.ko
$ dmesg
$ sudo rmmod helloworld.ko
```
