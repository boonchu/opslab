###### Self-signed Certificate
 * http://stackoverflow.com/questions/21297139/how-do-you-sign-certificate-signing-request-with-your-certification-authority
```
* checkout this git and modify openssl.conf
* generate new cert req
	- openssl req -config ./openssl.conf -newkey rsa:2048 -sha256 -nodes -out servercert.csr -outform PEM
* verify new cert req
	- openssl req -text -noout -verify -in servercert.csr
* add CA conf 
* increase index and serial
	- touch index.txt
	- echo '01' > serial.txt
* update CA to server cert req
	- openssl ca -config ./openssl-ca.conf -policy signing_policy \
		-extensions signing_req -out servercert.pem -infiles servercert.csr
* verify new server cert
	- openssl x509 -in servercert.pem -text -noout
```
