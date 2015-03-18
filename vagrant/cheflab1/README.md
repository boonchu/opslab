####### Getting start with Chef Vagrant

* Prep steps:
  - Download ChefDK for MAC, Linux, bah bah
  - Git repository for your recipes
  - Bare Metal virtual box image for vagrant
  
* Setup: 
```
$ cd /tmp
$ chef generate cookbook cheflab1

- prepare .kitchen.yml
```
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
```

```
