number_of_agents = (ENV['K3S_AGENTS'] || "2").to_i 
box_name = (ENV['VAGRANT_BOX'] || "generic/rocky8")  

Vagrant.configure("2") do |config|
  config.vm.box = "#{box_name}"
  
  config.vm.define "master" do |master|
    master.vm.hostname = 'master'
    master.vm.network :private_network, ip: "192.168.56.10", :netmask => "255.255.255.0"
    master.vm.provision :shell, :path => "master.sh"
    master.vm.provider :virtualbox do |vbox|
        vbox.customize ["modifyvm", :id, "--memory", 2048]
        vbox.customize ["modifyvm", :id, "--cpus", 1]
    end
    
    master.trigger.after :up do |trigger|
      trigger.run = {inline: "rm -rf apiserver-details"}
      trigger.run = {inline: "vagrant scp master:/home/vagrant/apiserver-details ."}
    end
  end

  (1..number_of_agents).each do |node_number|
    config.vm.define "agent#{node_number}" do |agent|
      agent.vm.hostname = "agent#{node_number}"
      ip = node_number + 100
      agent.vm.network :private_network, ip: "192.168.56.#{ip}", :netmask => "255.255.255.0"
      
      agent.vm.provision "file", source: "apiserver-details", destination: "/home/vagrant/apiserver-details"
      
      agent.vm.provision :shell, :path => "agent.sh"
      
      agent.vm.provider :virtualbox do |vbox|
          vbox.customize ["modifyvm", :id, "--memory", 2048]
          vbox.customize ["modifyvm", :id, "--cpus", 1]
      end
    end
  end
end
