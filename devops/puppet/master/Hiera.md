###### Hiera
  * [how to configure Class parameter input in puppet](https://docs.puppetlabs.com/pe/latest/puppet_assign_configurations.html)
  * [SSHD with Hiera](https://puppetlabs.com/blog/first-look-installing-and-using-hiera)
  * [resolv.conf with Hiera](https://puppetlabs.com/blog/the-problem-with-separating-data-from-puppet-code)

###### example: from git
* use three simple way for configure /etc/test_file[X].conf
```
- from three test case from s1, s2, and s3 module
- s1 is simple one
- s2 is passing from sub class
- s3 is passing from Hiera
$ cat /etc/test*
search puppetlabs.s1
 nameserver 1.1.1.1
search puppetlabs.s2
 nameserver 2.2.2.2
search puppetlabs.s4
 nameserver 4.4.4.4
```
* be able to query Hiera data
```
$ hiera -c /etc/puppetlabs/puppet/hiera.yaml dnsserver
4.4.4.4
```
