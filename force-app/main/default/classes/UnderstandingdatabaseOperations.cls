public class UnderstandingdatabaseOperations {

    public static void handleInsertObjects(){
        Account acc = new Account();
        acc.Name = 'test Apex';
       
        Account acc1 = new Account();
        acc1.Name = 'Text';
        
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc1);
        
        insert accList;
    }
    
    public static void handleUpdateObjects(Id contactId){
        //contactId ='003gL00000E1izqQAB';
        
        List <Contact> con = [SELECT id, Title, Department From Contact Where Id= :contactId];
        if (con.size()>0){
            if (con[0].Title == 'setTitle'){
                con[0].Department = 'Salesforce';
            }
        
        update con[0];
            
    }
}

    public static void handleDeleteObjects (){
        
        //delete all the opp ehich are marked closed lost
        
        List<Opportunity> oppList = [Select Id From Opportunity WHERE StageName = 'Closed Lost'];
        if (oppList.size()>0){
            delete oppList;
        }
    }
}