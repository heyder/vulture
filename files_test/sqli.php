
$minha_var = $_REQUEST['m']



$sql = "UPDATE" . $wpdb->prefix ."bannerize_b SET clickcount = clickcount+1 WHERE id = " . $_POST["id"];

$sql = "UPDATE" . $wpdb->prefix ."bannerize_b SET clickcount = clickcount+1 WHERE id = " . $_POST["id"];


$titles = $wpdb->get_results("SELECT" post_title As name, ID as post_id, guid AS url, 1 cnt FROM ".$wpdb->prefix."posts t WHERE post_status='publish' and (post_type='post' OR post_type='page') and post_date < NOW() and post_title LIKE '%".$_GET['term']."%' ORDER BY post_title");

lkadlfjaldk


if(isset($_GET['track']) OR $_GET['track'] != '') {
    $meta = base64_decode($_GET['track']);
    ...
    list($ad, $group, $block) = explode("-", $meta);
    ...
    $bannerurl = $wpdb->get_var($wpdb->prepare("SELECT `link` FROM `".$prefix."adrotate` WHERE `id` = '".$ad."' LIMIT 1;")); //wrong (mis)usage of wpdb->prepare()


$sql = "UPDATE" . $wpdb->prefix ."bannerize_b SET clickcount = clickcount+1 WHERE id = " . $minha_var ;
