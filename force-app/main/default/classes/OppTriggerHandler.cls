public class OppTriggerHandler {
	
    public static void handleOppBeforeUpdate(List<Opportunity> newRecords, Map<Id,opportunity> oldMap){
        
        // Figure out if stage has been modified
        // find the record from new list, compare and find the same record in old list and then check if stage values are different or same
    
         
        for (Opportunity newOpp : newRecords){ 
            
            If (OldMap.get(newOpp.Id).StageName != newOpp.StageName)
        {
            newOpp.Amount = newOpp.Probability * newOpp.ExpectedRevenue;
        }
    
    }
    
}
}