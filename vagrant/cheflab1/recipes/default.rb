#
# Cookbook Name:: cheflab1
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'yum'
include_recipe 'java'
include_recipe 'tomcat'

cookbook_file "/var/lib/tomcat6/webapps/punter.war" do
	source	"punter.war"
	mode 00744
	owner 'root'
	group 'root'
end
