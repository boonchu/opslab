* when you have issue with 
```
Error: /File[/var/opt/lib/pe-puppet/lib]: Failed to generate additional resources using 'eval_generate': SSL_connect returned=1 errno=0 state=unknown state: certificate verify failed: [unable to get local issuer certificate for /CN=server1.cracker.org]
```
use solution from below to clean up cert and regenerate 
```
puppet cert clean server1.cracker.org
puppet cert generate server1.cracker.org
systemctl restart pe-httpd
```
