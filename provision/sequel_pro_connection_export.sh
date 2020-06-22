#!/bin/bash
db_name="$1"
id=$((1000000000000000000 + RANDOM % 9999999999999999999))
ip="$2"
db_user="$3"
identity_file=$(vagrant ssh-config | grep IdentityFile | tail -1 | sed -e 's/IdentityFile//' | sed -e 's/\"//g')
identity_file="$(echo -e "${identity_file}" | tr -d '[:space:]')"
fav="
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
  <key>SPConnectionFavorites</key>
  <array>
    <dict>
      <key>colorIndex</key>
      <integer>-1</integer>
      <key>database</key>
      <string>${db_name}</string>
      <key>host</key>
      <string>127.0.0.1</string>
      <key>id</key>
      <integer>$id</integer>
      <key>name</key>
      <string>Vagrant $db_name</string>
      <key>port</key>
      <string></string>
      <key>socket</key>
      <string></string>
      <key>sshHost</key>
      <string>$ip</string>
      <key>sshKeyLocation</key>
      <string>$identity_file</string>
      <key>sshKeyLocationEnabled</key>
      <integer>1</integer>
      <key>sshPort</key>
      <string></string>
      <key>sshUser</key>
      <string>vagrant</string>
      <key>sslCACertFileLocation</key>
      <string></string>
      <key>sslCACertFileLocationEnabled</key>
      <integer>0</integer>
      <key>sslCertificateFileLocation</key>
      <string></string>
      <key>sslCertificateFileLocationEnabled</key>
      <integer>0</integer>
      <key>sslKeyFileLocation</key>
      <string></string>
      <key>sslKeyFileLocationEnabled</key>
      <integer>0</integer>
      <key>type</key>
      <integer>2</integer>
      <key>useSSL</key>
      <integer>0</integer>
      <key>user</key>
      <string>$db_user</string>
    </dict>
  </array>
</dict>
</plist>"
echo "$fav" > ../Config/sequel-fav.plist