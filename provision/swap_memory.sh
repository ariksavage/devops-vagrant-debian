#! /bin/bash
size="$1"
# https://linuxize.com/post/create-a-linux-swap-file/

if [ ! -f /swapfile ]; then
  # Create a file that will be used for swap:

  fallocate -l "$size" /swapfile

  # Only the root user should be able to write and read the swap file. 
  # To set the correct permissions type:

  chmod 600 /swapfile

  # Use the mkswap utility to set up the file as Linux swap area:

  mkswap /swapfile

  # Enable the swap with the following command:

  swapon /swapfile

  # To make the change permanent open the /etc/fstab file and append the following line:

  echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
fi