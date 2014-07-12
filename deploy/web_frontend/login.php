<?php

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    session_start();
    $username = $_POST['username'];
    $passwort = $_POST['password'];
    $hostname = $_SERVER['HTTP_HOST'];
    $path = dirname($_SERVER['PHP_SELF']);
    //Parse IniFile
    $ini_array = parse_ini_file("auth/access.ini");
    // Benutzername und Passwort werden überprüft
    
    if ($username == $ini_array["user"] && $passwort == $ini_array["pwd"]) {
        $_SESSION['angemeldet'] = true;
        // Weiterleitung zur geschützten Startseite
        
        if ($_SERVER['SERVER_PROTOCOL'] == 'HTTP/1.1') {
            
            if (php_sapi_name() == 'cgi') {
                header('Status: 303 See Other');
            }
            else {
                header('HTTP/1.1 303 See Other');
            }
        }
        //header('Location: http://'.$hostname.($path == '/' ? '' : $path).'/index3.php');
        header('Location: http://' . $hostname . '/' . 'index.php');
        exit;
    }
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
 <head>
  <title>Geschuetzter Bereich</title>
     <link href="assets/css/bootstrap.css" rel="stylesheet">
  <link href="assets/css/bootstrap-responsive.css" rel="stylesheet">
      <script type="text/javascript"
     src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.8.3/jquery.min.js">
    </script> 
   
    <script src="assets/js/bootstrap.js">
    </script>
 </head>
 
 <body>

  <!-- <form action="login.php" method="post">
   Username: <input type="text" name="username" /><br />
   Passwort: <input type="password" name="passwort" /><br />
   <input type="submit" value="Anmelden" />
  </form>-->
      <div class="navbar navbar-fixed-top navbar-inverse">
      <div class="navbar-inner">
        <div class="container-fluid">
         
          <a class="brand" href="#">
            Sensetrace
          </a>
    
    
        </div>
      </div>
    </div>
  
  <div class="container">
    <div class="row">
		<div class="span12">
			<form class="form-horizontal" action="login.php" method="post">
			  <fieldset>
			    <div id="legend">
			      <legend class="">Login</legend>
			    </div>
			    <div class="control-group">
			      <!-- Username -->
			      <label class="control-label"  for="username">Username</label>
			      <div class="controls">
			        <input type="text" name="username" placeholder="" class="input-xlarge">
			      </div>
			    </div>
			    <div class="control-group">
			      <!-- Password-->
			      <label class="control-label" for="password">Password</label>
			      <div class="controls">
			        <input type="password" name="password" placeholder="" class="input-xlarge">
			      </div>
			    </div>
			    <div class="control-group">
			      <!-- Button -->
			      <div class="controls">
			        <button class="btn btn-success">Login</button>
			      </div>
			    </div>
			  </fieldset>
			</form>
		</div>
	</div>
</div>

 </body>
</html>
