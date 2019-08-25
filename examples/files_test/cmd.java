public string cmdExecution(String id){ 
   try {
     Runtime rt = Runtime.getRuntime();
     rt.exec("cmd.exe /C LicenseChecker.exe" + " -ID " + id);
   }
   catch(Exception e){
     //...
   }
 }
