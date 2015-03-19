###### Testing through server spec
  * noted when I started with bats to test my apps. Serverspec is similar and what Chef want to use as test suite.
  * look at tree structure
```
- tree structure for test suite
└── test
    └── integration
        └── default
            ├── bats
            │   └── tomcat.bats
            └── serverspec
                ├── default_spec.rb
                └── spec_helper.rb


```
  *  add serverspec file, 'test/integration/default/serverspec/default_spec.rb'
```
require 'spec_helper'

describe package('java-1.7.0-openjdk') do
  it { should be_installed }
end

describe package('tomcat6') do
  it { should be_installed }
end

describe port(8080) do
  it { should be_listening }
end

describe file('/var/lib/tomcat6/webapps/punter.war') do
  it { should be_file }
end

describe file('/var/lib/tomcat6/webapps/punter') do
  it { should be_directory }
end

describe "Custom checking on tomcat apps" do
  it "is listening on port 8080" do
    expect(port(8080)).to be_listening
  end

  it "has a running service of tomcat6" do
    expect(service("tomcat6")).to be_running
  end
end
```
  * run kicthen to verify and test with serverspec
```
$ kitchen verify
-----> Running serverspec test suite
       /opt/chef/embedded/bin/ruby -I/tmp/busser/suites/serverspec -I/tmp/busser/gems/gems/rspec-support-3.2.2/lib:/tmp/busser/gems/gems/rspec-core-3.2.2/lib /opt/chef/embedded/bin/rspec --pattern /tmp/busser/suites/serverspec/\*\*/\*_spec.rb --color --format documentation --default-path /tmp/busser/suites/serverspec

       Package "java-1.7.0-openjdk"
         should be installed

       Package "tomcat6"
         should be installed

       Port "8080"
         should be listening

       File "/var/lib/tomcat6/webapps/punter.war"
         should be file

       File "/var/lib/tomcat6/webapps/punter"
         should be directory

       Custom checking on tomcat apps
         is listening on port 8080
         has a running service of tomcat6

       Finished in 0.10935 seconds (files took 0.23029 seconds to load)
       7 examples, 0 failures

       Finished verifying <default-centos65-chef> (0m2.45s).
```
* add content validation test on guest instance. For instance, I want to check /etc/tomcat6/tomcat6.conf if it contains bah bah configuration parameter.
```
- append to default server spec file, 'test/integration/default/serverspec/default_spec.rb'
describe file('/etc/tomcat6/tomcat6.conf') do
  its(:content) { should match /^SECURITY_MANAGER?=?"false?"$/ }
end

- run test
$ kitchen verify
       File "/etc/tomcat6/tomcat6.conf"
         content
           should match /^SECURITY_MANAGER?=?"false?"$/

       Finished in 0.12495 seconds (files took 0.23783 seconds to load)
       8 examples, 0 failures
```
###### Reference:
  * [ServerSpec Test](https://github.com/enovance/openstack-serverspec/tree/master/spec/tests)
