# Vagrant Symfony2 Example

A simple project demonstrating [Vagrant][] with a Symfony2 project, as described on our [Blog post][post].

 [Vagrant]: http://www.vagrantup.com/
 [post]: #

## Before you start

Initialise and update Git submodules: `git submodule init && git submodule update`. Otherwise Puppet will complain about `Invalid resource type`.

## What to do

 1. Make sure you have [Vagrant][vagrant-install] and [VirtualBox][] installed
 2. Open a terminal inside the checked out repository
 3. Run `vagrant up` and wait until it finished
 4. Point your browser at <http://localhost:8090/app_dev.php/demo/hello/World> and see Symfony2's hello world demo
 5. Change some code and see the changes reflected

 [vagrant-install]: http://docs.vagrantup.com/v2/installation/index.html
 [VirtualBox]: https://www.virtualbox.org

