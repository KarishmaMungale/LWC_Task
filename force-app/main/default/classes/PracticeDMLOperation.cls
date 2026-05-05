public class PracticeDMLOperation {
    
    public static void insertStatement(){
        
        Account acc = new Account();
        acc.Name = 'First Account';
        
        Account acc2 = new Account();
        acc2.Name = 'Second Account';
        
        List <Account> accList = new List <Account> ();
        accList.add(acc);
        accList.add(acc2);
        
        insert accList;
       
    }

}