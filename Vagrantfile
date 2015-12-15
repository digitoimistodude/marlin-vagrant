# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "marlin" do |t| end

  config.vm.network "forwarded_port", host: 80, guest: 80, auto_correct: true
  config.vm.network "forwarded_port", host: 443, guest: 443, auto_correct: true
  config.vm.network "private_network", ip: "10.1.2.4"
  config.ssh.forward_agent = true
  config.ssh.insert_key = false
  config.vm.network "public_network", ip: "192.168.0.242", bridge: "en6: USB Ethernet"
  config.vm.synced_folder "~/Projects", "/var/www", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp,actimeo=2']

  config.vm.provider "virtualbox" do |v|
    v.name = "marlin"
    v.customize ["modifyvm", :id, "--memory", "4096", "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
    v.customize ["modifyvm", :id, "--cpus", 1]
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  config.vm.provision :shell, :path => "provision.sh"

end
