# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/focal64'

  # Load Balancer
  config.vm.define 'lb' do |c|
    c.vm.provider 'virtualbox' do |v|
      v.cpus = 1
      v.memory = 512
    end
    c.vm.hostname = 'lb'
    c.vm.network 'private_network', ip: '192.168.50.10'
    #c.vm.network :forwarded_port, guest: 80, host: 8080
    c.vm.provision 'shell', path: 'conf/install-haproxy.sh'
  end

  # Masters and Workers
  (1..7).each do |i|
    name = (1..2).include?(i) ?  "master-#{i}" : "worker-#{i - 3}"
    config.vm.define name, autostart: %w(1 2 3).include?("#{i}") do |c|
      c.vm.provider 'virtualbox' do |v|
        v.cpus = 2
        v.memory = 2048
      end
      c.vm.hostname = name
      c.vm.network 'private_network', ip: "192.168.50.#{i+10}"
      c.vm.provision 'shell', path: 'conf/install-k8s.sh'
    end
  end
end
