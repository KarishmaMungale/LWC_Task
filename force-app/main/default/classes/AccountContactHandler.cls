public class AccountContactHandler {
    
    public static void handleAfterAccountContacttrigger (List <Account> lstAcc, Map <Id, Account> oldMap)
    {
        map <Id,String> accTowebsiteMap = new Map<Id, String>();
       // List <Id> addAccIdList = new List<Id>();
        
        for (Account acc : lstAcc)
        {
            if(acc.Website__c != oldMap.get(acc.Id).Website__c)
            {
                accTowebsiteMap.put(acc.Id, acc.Website__c);
                
            }
        }
        
        if(accTowebsiteMap.keySet().size()>0)
        {
            List<Contact> addConToUpdate= new List <Contact>();
            List<Contact> conRecords = [select id, FirstName, Website__c from contact Where AccountId IN :accTowebsiteMap.keySet()];
      		for (Contact con : conRecords)
            {
                con.Website__c = accTowebsiteMap.get(con.AccountId);
           		addConToUpdate.add(con);
            }
        
        
        if (addConToUpdate.size()>0)
        {
            update addConToUpdate;
        }
        }
    }

}