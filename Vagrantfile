# -*- mode: ruby -*-
# vi: set ft=ruby :

################################################################################
required_plugins=['vagrant-hostsupdater', 'vagrant-vbguest']
required_plugins.each do |plugin|
  if !Vagrant.has_plugin?(plugin)
    raise plugin.to_s + " is not installed. This plug-in is required. Run ``vagrant plugin install "+plugin.to_s+"`` to install."
  end
end
################################################################################
if File.exist?("../config/vagrant.config.json")
  config_json = JSON.parse(File.read("../config/vagrant.config.json"))
elsif File.exist?("vagrant.config.json")
  config_json = JSON.parse(File.read("vagrant.config.json"))
end

# If no config, print error and exit. Otherwise vagrant up
if config_json.nil? || config_json.empty?
  print "No vagrant.config.json file found.\n"
else
  # Verify no defaults
  if config_json["url"].eql? "default.local"
    raise "You are using the default URL. Edit the config.json to update it."
  end

  if config_json["mysql"]["root_pw"].eql? 'root'
    raise "You are using the default MySQL root password. Edit the config.json to update it."
  end
  ################################################################################
  Vagrant.configure("2") do |config|
    ##############################################################################
    # BOX BASE OPTIONS
    ##############################################################################
    config.vm.box = config_json["box"]
    config.vm.box_check_update = config_json["box_check_update"]
    config.vm.define config_json["name"]
    config.vm.post_up_message = config_json["post_up_message"]
    #timezone
    if Vagrant.has_plugin?("vagrant-timezone")
      config.timezone.value = "America/Chicago"
    end
    ##############################################################################
    # VIRTUAL BOX OPTIONS
    ##############################################################################
    config.vm.provider "virtualbox" do |vb|
      vb.gui = config_json["gui"]
      vb.customize ["modifyvm", :id, "--memory", config_json["memory"] ]
      vb.name = config_json["name"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    ##############################################################################
    # NETWORK OPTIONS
    ##############################################################################
    config.vm.network :private_network, ip: config_json["ip"]

    config_json["forwarded_ports"].each do |port|
      config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: port["auto_correct"]
    end

    config.vm.network "public_network", bridge: ["en0: Wi-Fi (Wireless)"]

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

    mysql_root_pw = config_json["mysql"]["root_pw"]

    # Install dependencies: PHP, MySQL, Apache, NodeJS, etc
    if !mysql_root_pw.nil? && !mysql_root_pw.empty?
      config.vm.provision :shell, :path => "provision/install_dependencies.sh", :args => [mysql_root_pw], :privileged => true
    end

    #configure PHP sendmail to use gmail via msmtp
    account_type = config_json["server"]["mail"]["type"]
    email_addr = config_json["server"]["mail"]["sender"]
    email_pass = config_json["server"]["mail"]["password"]
    test_recipient = config_json["server"]["admin"]
    if !account_type.nil? && !account_type.empty? && !email_addr.nil? && !email_addr.empty? && !email_pass.nil? && !email_pass.empty?
      config.vm.provision :shell, :path => "provision/update_sendmail.sh", :args => [account_type, email_addr, email_pass, test_recipient], :privileged => true
    end

    web_root = config_json["web_root"]
    url = config_json["url"]
    server_admin = config_json["server"]["admin"]
    ssl = config_json["ssl"]

    if !web_root.nil? && !web_root.empty? && !url.nil? && !url.empty? && !server_admin.nil? && !server_admin.empty? && !ssl.nil? && !ssl.empty?
      config.vm.provision :shell, :path => "provision/configure_apache.sh", :args => [web_root, url, server_admin, ssl], :privileged => true
    end

    swap_mem = config_json["swap_memory"]

    if !web_root.nil? && !web_root.empty?
      config.vm.provision :shell, :path => "provision/swap_memory.sh", :args => [swap_mem], :privileged => true
    end

    config.ssh.forward_agent = true
    config.vm.boot_timeout = 120
  end
end
