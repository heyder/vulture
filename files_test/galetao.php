<?

echo "<HTML>
      <title>XSS Test</title>
      <br>
      <BODY>
      ";

//print_r($_POST)
?>
  <form METHOD="POST" NAME="fuck" ACTION="">
    <table border="1">
      <tr><td>What is your name?: <INPUT TYPE="text" name="nome" id=""> <INPUT TYPE="submit" VALUE="submit"></td></tr>
      <tr><td><br>Your name is: </td></tr>
    </table>
  </form>  


  <form METHOD="POST" NAME="galetao" ACTION="">
      <tr><td>OtherForm: <INPUT TYPE="text" name="OtherForm" id=""> <INPUT TYPE="submit" VALUE="submit"></td></tr>
  </form>  

<?

echo "</BODY>
       <br>
       </HTML>";

?>
