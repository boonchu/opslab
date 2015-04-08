* [Console services dies](https://tickets.puppetlabs.com/browse/ENTERPRISE-482) or
* [not starting after reboot](https://tickets.puppetlabs.com/browse/ENTERPRISE-502)
	* [work around](https://tickets.puppetlabs.com/browse/ENTERPRISE-483)
* solution: 
	* In order to resolve these issues you need to ensure pe-puppetserver starts after pe-puppet and 
        * pe-console-services starts after pe-postgresql.
```
- /var/log/pe-puppetserver/puppetserver.log
2015-04-08 09:31:40,105 INFO  [puppet-server] mount[pe_modules] allowing * access
2015-04-08 09:31:45,067 ERROR [puppet-server] Puppet Unable to submit report: Error 500 while communicating with server1.cracker.org on port 4435:

- /var/log/pe-console-services/console-services.log
2015-04-08 09:31:34,541 ERROR [p.t.internal] Error during service init!!!
org.postgresql.util.PSQLException: Connection refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.
        at org.postgresql.core.v3.ConnectionFactoryImpl.openConnectionImpl(ConnectionFactoryImpl.java:207) ~[console-services-release.jar:na]
        at org.postgresql.core.ConnectionFactory.openConnection(ConnectionFactory.java:64) ~[console-services-release.jar:na]
        at org.postgresql.jdbc2.AbstractJdbc2Connection.<init>(AbstractJdbc2Connection.java:136) ~[console-services-release.jar:na]
        at org.postgresql.jdbc3.AbstractJdbc3Connection.<init>(AbstractJdbc3Connection.java:29) ~[console-services-release.jar:na]
        at org.postgresql.jdbc3g.AbstractJdbc3gConnection.<init>(AbstractJdbc3gConnection.java:21) ~[console-services-release.jar:na]
        at org.postgresql.jdbc4.AbstractJdbc4Connection.<init>(AbstractJdbc4Connection.java:31) ~[console-services-release.jar:na]
```
