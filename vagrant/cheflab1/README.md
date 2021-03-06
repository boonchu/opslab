###### Getting start with Chef Vagrant

* Prep steps:
  - Download ChefDK for MAC, Linux, bah bah
  - [kitchen from ChefDK](https://docs.chef.io/config_yml_kitchen.html)
  - Git repository for your recipes
  - Test from [Bare Metal/Based box CentOS 6.5 image](http://www.vagrantbox.es/) for vagrant
  
* Setup: 
```
$ cd /tmp
$ chef generate cookbook cheflab1

- prepare .kitchen.yml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

platforms:
  - name: centos65-chef
    driver:
      box: centos-6.5-x86_64-minimal
      box_url: http://ks.cracker.org/Kickstart/centos7/centos64-x86_64-minimal.box

suites:
  - name: default
    run_list:
      - recipe[cheflab1::default]
    attributes:

- converge it (noted that status said "Converged" from past run)
$ kitchen list
Instance               Driver   Provisioner  Last Action
default-centos65-chef  Vagrant  ChefZero     Converged
$ kitchen converge
```

* adding Tomcat
```
- looking at Chef tree, it has recipes, spec, and test.
% tree
.
├── Berksfile
├── Berksfile.lock
├── README.md
├── chefignore
├── metadata.rb
├── recipes
│   └── default.rb
├── spec
│   ├── spec_helper.rb
│   └── unit
│       └── recipes
│           └── default_spec.rb
└── test
    └── integration
        └── default
            └── serverspec
                ├── default_spec.rb
                └── spec_helper.rb

- add 'depends "tomcat"' to metadata.rb

- run 'berks install' to get all dependencies from supermarket

- converge again

-----> Chef Omnibus installation detected (install only if missing)
       Transferring files to <default-centos65-chef>
       Starting Chef Client, version 12.1.1
       [2015-03-18T15:03:11+00:00] WARN: Child with name 'dna.json' found in multiple directories: /tmp/kitchen/dna.json and /tmp/kitchen/dna.json
       resolving cookbooks for run list: ["cheflab1::default"]
       Synchronizing Cookbooks:
         - tomcat
         - java
         - chef-sugar
         - yum-epel
         - openssl
         - yum
         - cheflab1
       Compiling Cookbooks...
       Converging 3 resources
       Recipe: tomcat::default
        (up to date)
         * yum_package[tomcat6-admin-webapps] action install (up to date)
         * tomcat_instance[base] action configure (up to date)
         * directory[/usr/share/tomcat6/lib/endorsed] action create (up to date)
        (up to date)
         * template[/etc/tomcat6/server.xml] action create (up to date)
         * template[/etc/tomcat6/logging.properties] action create (up to date)
         * execute[Create Tomcat SSL certificate] action run (up to date)
        (up to date)
        (up to date)
         * execute[wait for tomcat6] action nothing (skipped due to action :nothing)

       Running handlers:
       Running handlers complete
       Chef Client finished, 0/10 resources updated in 7.696423545 seconds
       Finished converging <default-centos65-chef> (0m9.63s).
-----> Kitchen is finished. (0m10.10s)

```

* now satisfied with result. jump to first cookbook recipe
  - review attributes on the supermarket's [java cookbook](https://supermarket.chef.io/cookbooks/java)
  - create 'attributes/default.rb' file
```
% cat attributes/default.rb
node.default['java']['install_flavor'] = 'openjdk'  # this is the default, but let's be EXPLICIT!
node.default['java']['jdk_version'] = '7'
$ kitchen converge
```

* adding yum recipes
```
- adding 'depends "yum"' on metadata.rb

- adding "include_recipe 'yum'" on recipes/default.rb
 
- converge again
$ kitchen converge
       Compiling Cookbooks...
       Converging 4 resources
       Recipe: yum::default


             - update content in file /etc/yum.conf from a403d7 to 31c39a
             --- /etc/yum.conf  2013-02-22 11:26:34.000000000 +0000
             +++ /tmp/chef-rendered-template20150318-15794-1jf9bwi      2015-03-18 15:22:25.903568253 +0000
             @@ -1,26 +1,15 @@
             +# This file was generated by Chef
             +# Do NOT modify this file by hand.
             +
       [main]
       cachedir=/var/cache/yum/$basearch/$releasever
             -keepcache=0
       debuglevel=2
             -logfile=/var/log/yum.log
             +distroverpkg=centos-release
       exactarch=1
             -obsoletes=1
       gpgcheck=1

             +keepcache=0
             +logfile=/var/log/yum.log
             +obsoletes=1
       plugins=1
             -installonly_limit=5
             -bugtracker_url=http://bugs.centos.org/set_project.php?project_id=16&ref=http://bugs.centos.org/bug_report_page.php?category=yum
             -distroverpkg=centos-release
             -
```

* how do I know if openjdk7 is properly installed?
   - [using bats - bash automated testing systems](https://github.com/sstephenson/bats)
   - run kitchen verify (finished in 6m, it's pretty slow)
```

% mkdir -p test/integration/default/bats
% vim test/integration/default/bats
#!/usr/bin/env bats

@test "java is found in PATH" {
  run which java
  [ "$status" -eq 0 ]
}

# stackoverflow.com case
# http://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script
@test "using java jdk 6 or 7" {
  result="$(java -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')"
  [ "$result" -eq 17 ] || [ "$result" -eq 16 ]
}

@test "tomcat process is visible " {
  result=$(ps aux | grep java | grep tomcat|wc -l)
  [ "$result" -eq 1 ]
}

- verify with kitchen and it fails.
% kitchen verify
-----> Starting Kitchen (v1.3.1)
-----> Verifying <default-centos65-chef>...
       Removing /tmp/busser/suites/serverspec
       Removing /tmp/busser/suites/bats
       Uploading /tmp/busser/suites/bats/tomcat.bats (mode=0644)
       Uploading /tmp/busser/suites/serverspec/default_spec.rb (mode=0644)
       Uploading /tmp/busser/suites/serverspec/spec_helper.rb (mode=0644)
-----> Running bats test suite
 ✓ java is found in PATH
 ✗ using java jdk 6 or 7
          (in test file /tmp/busser/suites/bats/tomcat.bats, line 12)
            `[ "$result" -eq 17 ] || [ "$result" -eq 16 ]' failed
 ✓ tomcat process is visible

       3 tests, 1 failure

>>>>>> ----------------------
```
* dang! forget to add 'include_recipe "java"'. 
```
$ kitchen converge
       Compiling Cookbooks...
       Converging 10 resources
       Recipe: yum::default

        (up to date)
            (up to date)
       Recipe: java::openjdk

           - install version 1.7.0.75-2.5.4.0.el6_6 of package java-1.7.0-openjdk
           - install version 1.7.0.75-2.5.4.0.el6_6 of package java-1.7.0-openjdk-devel

       Recipe: java::set_java_home

           - update content in file /etc/profile.d/jdk.sh from none to b45e89
           --- /etc/profile.d/jdk.sh    2015-03-18 17:26:04.071777530 +0000
           +++ /etc/profile.d/.jdk.sh20150318-16835-cj6vcr      2015-03-18 17:26:04.071777530 +0000

       Recipe: tomcat::default

            # Where your java installation lives
           -JAVA_HOME=
           +JAVA_HOME=/usr/lib/jvm/java-1.7.0
```

* verify again and pass the test.
```
$ kitchen verify
-----> Running bats test suite
 ✓ java is found in PATH
 ✓ using java jdk 6 or 7
 ✓ tomcat process is visible

       3 tests, 0 failures
-----> Running serverspec test suite
```

* Reference:
  - [really inspired by this instruction, love it](http://tcotav.github.io/chefdk_getting_started.html)
