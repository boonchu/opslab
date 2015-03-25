###### Starting with Packer
* follow this instruction
```
https://github.com/shiguredo/packer-templates
```
* building box image
```
$ packer build -only=virtualbox-iso template.json
 
==> virtualbox-iso (vagrant): Creating Vagrant box for 'virtualbox' provider
    virtualbox-iso (vagrant): Copying from artifact: output-virtualbox-iso/packer-virtualbox-iso-1427249217-disk1.vmdk
    virtualbox-iso (vagrant): Copying from artifact: output-virtualbox-iso/packer-virtualbox-iso-1427249217.ovf
    virtualbox-iso (vagrant): Renaming the OVF to box.ovf...
    virtualbox-iso (vagrant): Compressing: Vagrantfile
    virtualbox-iso (vagrant): Compressing: box.ovf
    virtualbox-iso (vagrant): Compressing: metadata.json
    virtualbox-iso (vagrant): Compressing: packer-virtualbox-iso-1427249217-disk1.vmdk
Build 'virtualbox-iso' finished.

==> Builds finished. The artifacts of successful builds are:
--> virtualbox-iso: 'virtualbox' provider box: centos-7-0-x64-virtualbox.box
```
