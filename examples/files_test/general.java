private String driver = "com.mysql.jdbc.Driver";  
  
   private String URL = "jdbc:mysql://localhost/seuBanco";//Vc tem que colocar o nome do seu banco. Vc coloca o localhost se o MySql estive na mesma maquina da aplicação, se não vc tem que colocar o ip do servidor de Dados.  
  
   private String USE = "root";// Geralmente é root a não ser que vc mude  
  
   private String SENHA = "123456";//seu senha  
  
   private Connection conn;   
  
        public void teste(){  
                try{  
                 Class.forName(driver);  
                Connection con = DriverManager.getConnection(URL, USE, SENHA);  
  
      Statement stmt = con.createStatement();  
  
            ResultSet rs = stmt.executeQuery("Select CA.CodCart, CA.NomeCart, C.Cor, I.NomeImpressora from cartucho CA inner join Cor C on (ca.cor= c.codCor) inner join Impressoras I on (CA.Impressora = I.codImpressora);");//linguagem SQL  
               }catch(Exception e){  
  
                }  
