public class ContactTriggerHandler {

    public static void handleBeforeInsert (List<Contact> newRecords)
    {
        for  (Contact con : newRecords)
            if(con.AccountId == null)
        {
            con.addError('Please Enter account Details');
        }
    }
}