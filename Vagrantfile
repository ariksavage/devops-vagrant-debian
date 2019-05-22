# -*- mode: ruby -*-
# vi: set ft=ruby :

################################################################################
required_plugins=['vagrant-hostsupdater', 'vagrant-vbguest']
required_plugins.each do |plugin|
  if Vagrant.has_plugin?(plugin)
    # nothing
  else
    raise plugin.to_s + " is not installed. This plug-in is required. Run ``vagrant plugin install "+plugin.to_s+"`` to install."
  end
end
################################################################################
if File.file?("../config/vagrant.config.json")
    config_json = JSON.parse(File.read("../config/vagrant.config.json"))
end
#verify no defaults
if config_json["url"].eql? "default.local"
  raise "You are using the default URL. Edit the config.json to update it."
end

if config_json["mysql"]["root_pw"].eql? 'root'
  raise "You are using the default MySQL root password. Edit the config.json to update it."
end
################################################################################################
Vagrant.configure("2") do |config|
  ##############################################################################
  # BOX BASE OPTIONS
  ##############################################################################
  config.vm.box = "debian/jessie64"
  config.vm.box_check_update = true
  config.vm.define config_json["name"]
  config.vm.post_up_message = "This is the start up message!"
  ##############################################################################
  # VIRTUAL BOX OPTIONS
  ##############################################################################
  config.vm.provider "virtualbox" do |vb|
    vb.gui = config_json["gui"]
    vb.memory = config_json["memory"]
    vb.name = config_json["name"]
  end
  ##############################################################################
  # NETWORK OPTIONS
  ##############################################################################
  config.vm.network :private_network, ip: config_json["ip"]

  config_json["forwarded_ports"].each do |port|
    config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: port["auto_correct"]
  end

  config.vm.network "public_network", bridge: ["en0: Wi-Fi (AirPort)"]
  
  if Vagrant.has_plugin?("vagrant-hostsupdater")
    config.vm.hostname = config_json["url"]
    config.hostsupdater.aliases = config_json["alias"]
  end
  ################################################################################
  # Folder and Files Options
  ################################################################################
  config_json["synced_folders"].each do |folder|
    if !Dir.exists?(folder["host"])
      Dir.mkdir folder["host"]
    end
    case folder["type"]
      when "nfs"
        # Set nfs with a timeout of 2 seconds as a balance for performance and gulp watch.
        config.vm.synced_folder folder["host"], folder["guest"], type: "nfs", mount_options: ['actimeo=2']
        # This uses uid and gid of the user that started vagrant.
        config.nfs.map_uid = Process.uid
        config.nfs.map_gid = Process.gid
      else
        config.vm.synced_folder folder["host"], folder["guest"]
    end
  end
  ################################################################################
  # PROVISION
  ################################################################################
  config.vm.provision :shell, :path => "provision/install_dependencies.sh", :args => config_json["mysql"]["root_pw"], :privileged => true
  config.vm.provision :shell, :path => "provision/create_db_with_user.sh", :args => [config_json["mysql"]["root_pw"], config_json["mysql"]["database"], config_json["mysql"]["user"]["username"], config_json["mysql"]["user"]["password"]], :privileged => true
  config.ssh.forward_agent = true
  config.vm.boot_timeout = 120
end
