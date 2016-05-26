<?php 

$my_name = $_GET['nome'];
?>
<HTML>
  <title>XSS Test</title>
<body>
<form METHOD="GET" NAME="xssForm" ACTION="">
  <table border="1">
      <tr><td>What is your name?: <INPUT TYPE="text" name="nome" id=""> <INPUT TYPE="submit" VALUE="submit"></td></tr>
      <tr><td><br>Your name is: <? echo $my_name ?></td></tr>  <tr><td><br>Your name is: <? echo $_GET['nome'] ?></td></tr>
      <tr><td><br>Your name is: <? echo $_GET['nome'] ?></td></tr>
  </table>
</form>
</body>
