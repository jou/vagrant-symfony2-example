Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.hostname = "vagrant-sf2-example"
  config.vm.network :forwarded_port, guest: 80, host: 8090

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file  = "sf2_example.pp"
    puppet.manifests_path = "vagrant/puppet/manifests"
    puppet.module_path    = "vagrant/puppet/modules"
  end
end