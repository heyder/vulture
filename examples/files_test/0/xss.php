<?php 

$nome = $_GET['nome'];
?>
<HTML>
  <title>XSS Test</title>
<body>
<form METHOD="GET" NAME="xssForm" ACTION="">
  <table border="1">
      <tr><td>What is your name?: <INPUT TYPE="text" name="nome" id=""> <INPUT TYPE="submit" VALUE="submit"></td></tr>
  </table>
</form>
</body>
