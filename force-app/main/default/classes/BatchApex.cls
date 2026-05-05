public class BatchApex implements Database.Batchable <Sobject>
{
	public Database.QueryLocator start (Database.BatchableContext bc)
    {
        return database.getQueryLocator ('Select Id, Name From Account');
    }
    
    public void execute (Database.batchableContext bc, List<Account> lstAccount)
    {
        //process each batch
    }
    
    public void finish (Database.BatchableContext bc)
    {
        //after all batches complete
    }
    
}