$MessageFile = "cwe-94/messages.out";
if ($_GET["action"] == "NewMessage") {
$name = $_GET["name"];
$message = $_GET["message"];
$handle = fopen($MessageFile, "a+");
fwrite($handle, "<b>$name</b> says '$message'<hr>\n");
fclose($handle);
echo "Message Saved!<p>\n";
}
else if ($_GET["action"] == "ViewMessages") {
include($MessageFile);
}

#http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2008-5071

if(isset($_GET['rid'])){
# $rids=explode(':',$_GET['rid']);
# if(isset($_GET['proj_id']) && $_GET['proj_id']){
# $proj_id=$_GET['proj_id'];
# eval("\$pps= new $cname(".$_GET['proj_id'].");"); // PHP inj 1
# }
# }elseif(isset($_GET['proj_id']) && !empty($_GET['proj_id'])){
# $proj_id=$_GET['proj_id'];
#
# if(isset($_GET['pr_list_type']))
# $plt=$_GET['pr_list_type'];
# else
# $plt='full';
#
# eval("\$pps= new $cname($proj_id);"); // PHP inj 2
