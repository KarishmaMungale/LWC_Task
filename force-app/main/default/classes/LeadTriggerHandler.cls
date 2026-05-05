public class LeadTriggerHandler {

    	public static void handleActivitiesAfterInsert(List<Lead> leadRec)
        {
            List <Task> taskListToInsert = new List <Task>();
            for (Lead leadrecord : leadRec){
                Task t = new Task();
                t.Priority = 'High';
                t.OwnerId = leadrecord.OwnerId;
                t.Description ='Follow up with the Customer';
                t.WhoId = leadrecord.Id;
                taskListToInsert.add(t);
            }
            if(!taskListToInsert.isEmpty())
                insert taskListToInsert;
        }
}