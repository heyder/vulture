<?php
public function is_user_admin(){
            global $wpdb;
 
            foreach ((array)$_COOKIE as $cookie_key => $cookie_value){
                if(preg_match("/wordpress_logged_in/i", $cookie_key)){
                    $username = preg_replace("/^([^\|]+)\|.+/", "$1", $cookie_value);
                    break;
                }
            }
 
            if(isset($username) && $username){            
                $res = $wpdb->get_var("SELECT `$wpdb->users`.`ID`, `$wpdb->users`.`user_login`, `$wpdb->usermeta`.`meta_key`, `$wpdb->usermeta`.`meta_value`
                                       FROM `$wpdb->users`
                                       INNER JOIN `$wpdb->usermeta`
                                       ON `$wpdb->users`.`user_login` = \"$username\" AND
                                       `$wpdb->usermeta`.`meta_key` LIKE \"%_user_level\" AND
                                       `$wpdb->usermeta`.`meta_value` = \"10\" AND
                                       `$wpdb->users`.`ID` = `$wpdb->usermeta`.user_id ;"
                                    );
 
                return $res;
            }
 
            return false;
        }
?>
