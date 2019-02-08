# Devops: Vagrant Debian
  Vagrant Settings for Debian Web Server

## Initial Setup
  1.  Copy the example-vagrant.config.json to config/vagrant.config.json
  2.  Update any settings necessary.
  3.  Initialize submodules:
        host$ git submodule init && git submodule update
  4.  host$ vagrant up
  5.  host$ npm install && gulp

## MySQL Connection (host)
  Ensure no other boxes are running. This gets it confused
  Connect via ssh. see vagrant ssh-config for keyfile and port

### Sequel Pro Settings
  - MySQL Host: 127.0.0.1
  - Username: [uername (see config)]
  - Password: [password (see config)]
  - Database: [database name]
  - Port: 3306

  - SSH Host: localhost
  - SSH User: vagrant
  - SSH Key:  [keyfile see vagrant ssh-config]
  - SSH Port: [port see vagrant ssh-config]
