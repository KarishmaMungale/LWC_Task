public class UpsertHandler {
    public static void upsertStatement(){
    List<Account> accsToUpsert =new List<Account>();
    
    Account acc = new Account();
    acc.Name ='First Company';
        
    
    Account acc2 = new Account();
    acc2.Name ='second Company';
    
    accsToUpsert.add(acc);
    accsToUpsert.add(acc2);
    
    List<Account> lstAcc = [SELECT Id, Name From Account Where AccountNumber!= null ];
    For (Account acc4 : lstAcc)
    {
        acc4.Rating ='Hot';
        accsToUpsert.add(acc4);
            
    }
    upsert accsToUpsert;
    
    
}


}