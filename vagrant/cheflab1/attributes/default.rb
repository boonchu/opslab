node.default['java']['install_flavor'] = 'openjdk'  
node.default['java']['jdk_version'] = '7'

# solution: http://serverfault.com/questions/390840/how-does-one-get-tomcat-to-bind-to-ipv4-address
node.default['tomcat']['catalina_options'] = '-Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses'
