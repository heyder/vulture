some code here!
some code here!
$apps_path['themes']
some code here!
include $apps_path['themes']."/".$themes_module."/header.php";
include $apps_path."/".$themes_module."/header.php";
some code here!
if (basename($lp_request_uri) == basename(__FILE__) && isset($_REQUEST['abspath'])) { 
          // Create WordPress environment 
          require_once(urldecode($_REQUEST['abspath']) . WPINC . '/pluggable.php'); 
$color = 'blue';
   if (isset($_GET['COLOR']))
      $color = $_GET['COLOR'];
   include($color . '.php'); ok
some code here!
some code here!
$dir = $_GET['module_name'];
