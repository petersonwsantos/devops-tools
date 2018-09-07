Vagrant.configure(2) do |config|
	config.vm.define "devops-tools" do |devbox|
		devbox.vm.box = "ubuntu/xenial64"
		devbox.vm.box_version = "20180831.0.0"
    	#devbox.vm.network "private_network", ip: "192.168.199.9"
    	devbox.vm.hostname = "devops-tools"
	    devbox.vm.provision "shell", path: "scripts/vagrant-provision.sh"
		devbox.vm.provision :shell, inline: "chsh -s /bin/zsh vagrant"
		devbox.vm.provision "file", source: "scripts/zshrc", destination: "/home/vagrant/.zshrc"
		devbox.vm.provider "virtualbox" do |v|
    		 v.memory = 2048
    		 v.cpus = 2
    	end
	end
end