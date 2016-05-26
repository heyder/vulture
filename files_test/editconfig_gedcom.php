http://www.securityfocus.com/archive/1/352355

if (empty($gedcom_config)) {
 if (!empty($_POST["gedcom_config"])) $gedcom_config = $_POST["gedcom_config"];
 else $gedcom_config = "config_gedcom.php";
}

require($gedcom_config);
