###### Self-signed Certificate
 * http://stackoverflow.com/questions/21297139/how-do-you-sign-certificate-signing-request-with-your-certification-authority
```
* checkout this git and modify openssl-ca.conf and openssl.conf
* modify openssl-ca.conf
* generate new ca cert req
	- openssl req -x509 -config openssl-ca.conf -newkey rsa:4096 -sha256 -nodes -out cacert.pem -outform PEM
* verify ca cert pem
	- openssl x509 -in cacert.pem -text -noout
* verify "Any purpose CA is yes"
	- openssl x509 -purpose -in cacert.pem -inform PEM | less
* modify openssl.conf
* generate new server req
	- openssl req -config openssl.conf -newkey rsa:2048 -sha256 -nodes -out servercert.csr -outform PEM
* verify new cert req
	- openssl req -text -noout -verify -in servercert.csr
* increase index and serial
	- touch index.txt
	- echo '01' > serial.txt
* sign with your CA to server cert req
	- openssl ca -config ./openssl-ca-step2.conf -policy signing_policy -extensions signing_req -out servercert.pem -infiles servercert.csr

Using configuration from ./openssl-ca-step2.conf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
countryName           :PRINTABLE:'US'
stateOrProvinceName   :ASN.1 12:'CA'
localityName          :ASN.1 12:'San Jose'
commonName            :ASN.1 12:'www4.cracker.org.'
Certificate is to be certified until Jan 20 18:28:50 2018 GMT (1000 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

* verify new server cert
	- openssl x509 -in servercert.pem -text -noout
```
