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
    config.vm.box = "debian/jessie64"
    config.vm.box_url="https://app.vagrantup.com/debian/boxes/jessie64"
    config.vm.box_check_update = true
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
    # Install dependencies: PHP, MySQL, Apache, NodeJS, etc
    mysql_root_pw = config_json["mysql"]["root_pw"]
    mysql_username = config_json["mysql"]["user"]["username"]
    mysql_password = config_json["mysql"]["user"]["password"]
    mysql_db = config_json["mysql"]["database"]
    mysql_content = config_json["mysql"]["content"]
    web_root = config_json["web_root"]
    url = config_json["url"]

    config.vm.provision :shell, :path => "provision/create_local_env.sh", :args => ['Local', '127.0.0.1', url, web_root, 'vagrant', mysql_username, mysql_password, 3306, mysql_db], :privileged => true


    if !mysql_root_pw.nil? && !mysql_root_pw.empty?
      config.vm.provision :shell, :path => "provision/install_dependencies.sh", :args => mysql_root_pw, :privileged => true
    end

    # Create database
    if !mysql_root_pw.nil? && !mysql_root_pw.empty? && !mysql_username.nil? && !mysql_username.empty? && !mysql_password.nil? && !mysql_password.empty? && !mysql_db.nil? && !mysql_db.empty?
      config.vm.provision :shell, :path => "provision/create_db_with_user.sh", :args => [mysql_root_pw, mysql_db, mysql_username, mysql_password], :privileged => true
    end

    #import data to database
    if !mysql_username.nil? && !mysql_username.empty? && !mysql_password.nil? && !mysql_password.empty? && !mysql_db.nil? && !mysql_db.empty? && !mysql_content.nil? && !mysql_content.empty?
      config.vm.provision :shell, :path => "provision/import_database.sh", :args => [mysql_username, mysql_password, mysql_db, mysql_content], :privileged => true
    end

    # configure apache
    if !web_root.nil? && !web_root.empty?
      config.vm.provision :shell, :path => "provision/configure_apache.sh", :args => [web_root, url], :privileged => true
    end

    cms = config_json["cms"]
    if !cms.nil? && !cms.empty?
      case cms
        when "wordpress"
          config.vm.provision :shell, :path => "provision/cms/wordpress.sh", :args => [web_root, mysql_db, mysql_username, mysql_password], :privileged => true
      end
    end

    config.ssh.forward_agent = true
    config.vm.boot_timeout = 120
  end
end
