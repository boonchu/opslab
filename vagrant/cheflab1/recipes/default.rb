#
# Cookbook Name:: cheflab1
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'yum'
include_recipe 'java'
include_recipe 'tomcat'
include_recipe 'simple_iptables'

cookbook_file "/var/lib/tomcat6/webapps/punter.war" do
	source	"punter.war"
	mode 00744
	owner 'root'
	group 'root'
end

# Allow SSH
simple_iptables_rule "ssh" do
  rule "--proto tcp --dport 22"
  jump "ACCEPT"
end

# Allow TOMCAT
simple_iptables_rule "tomcat" do
  rule [ "--proto tcp --dport 8080" ]
  jump "ACCEPT"
end
