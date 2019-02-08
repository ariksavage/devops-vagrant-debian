<?php  $config = json_decode(file_get_contents('/home/vagrant/config/vagrant.config.json')); ?>
<html>
  <head>
    <title>Vagrant Default Index</title>
    <link rel="stylesheet" href="/css/example.css"/>
  </head>
  <body>
    <h1><?php echo $config->post_up_message;?></h1>
    <h3>Database</h3>
     <?php
    $servername = "localhost";
    $username = $config->mysql->user->username;
    $password = $config->mysql->user->password;
    $database = $config->mysql->database;
    // Create connection
    $conn = new mysqli($servername, $username, $password, $database);
    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    echo "Connected successfully to $database as $username";
    ?>
    <?php phpinfo(); ?>
  </body>
</html>
