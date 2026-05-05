public class HandleDatabaseOperations {

    public static void createAccountRecords(){
        Account acc1 = new Account(Name='Karishma1', rating= 'Hot' );
        Account acc2 = new Account(Name='Karishma2', rating= 'Cold' );
        
        List<Account> accList = new List<Account>{acc1, acc2};
       Database.insert(accList);
       
    }
}