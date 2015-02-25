##### IPA 

IPA stand for Identity Policy and Audit. This freeipa is the service can provide
the one central identity SSO, AAA design, and AD integration.

Starting with freeIPA
- list of components
* [389 Directory Server](http://directory.fedoraproject.org/)
* [MIT Kerberos](http://k5wiki.kerberos.org/wiki/Main_Page)
* [NTP](http://ntp.org/)
* [Dogtag](http://fedoraproject.org/wiki/Features/DogtagCertificateSystem)
* [SSSD](https://fedorahosted.org/sssd/)

- installation
* create virtual IP on base host (using nmcli)
* update virtual IP to DNS or /etc/hosts
```
$ tail -1 /etc/hosts
192.168.1.128   ipserver.cracker.org ipserver

$ sudo yum -y install ipa-server bind bind-dyndb-ldap

$ sudo ipa-server-install
```
* [MongoDB identity platform integration](http://docs.mongodb.org/ecosystem/tutorial/configure-red-hat-enterprise-linux-identity-management/)
* Reference:
   - http://www.certdepot.net/rhel7-configure-freeipa-server/
   - https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Linux_Domain_Identity_Authentication_and_Policy_Guide/index.html
   - https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Windows_Integration_Guide/index.html
