Vagrant.configure("2") do |config|
   config.vm.box = "scribeui"
   config.vm.network "forwarded_port", guest: 5432, host: 5454
   config.vm.network "forwarded_port", guest: 80, host: 8080
   config.vm.network "public_network"
   config.vm.provision "shell", path: "install_msa.sh"
end
