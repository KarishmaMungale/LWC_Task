public class OpportyunityTriggerHandler5 {

    public static void handleActivitiesAfterInsert( ){}
    
    
    public static void handleActivitiesAfterUpdate(List<Opportunity> newRecords){
        List<Task> taskListToInsert = new List<Task>();
        for (Opportunity opp: newRecords){
            if (opp.StageName == 'Closed Won'){
                
                // create a related record- Task Record
                
                Task taskRecord = new Task();
                taskRecord.Priority = 'High';
                taskRecord.OwnerId = opp.OwnerId;
                taskRecord.Description= 'Please Split the Revenue amongst the team Member';
                taskRecord.Status= 'Not Started';
                taskRecord.WhatId = opp.Id;
                taskListToInsert.add(taskRecord);
            }
        }
        
        if(!taskListToInsert.isEmpty())
            insert taskListToInsert;
    }
}