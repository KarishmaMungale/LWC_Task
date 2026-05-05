public class ListExample1 {

    public static void listEx ()
    {
        List<string> lstAcc = new List<string>();
        
            for (Account acc : [Select Name from Account]){
                
          lstAcc.add(acc.Name);
                
            }
    }
}