public class DeliveryInfoClass {

    public static void practisingClass (Integer amount){
        
        List <Delivery_Information__c> lstDelivery = [Select id, Status__c, Amount__c From Delivery_Information__c];
        
        for (Delivery_Information__c del : lstDelivery)
        {
            if (del.Status__c == 'Delivered')
            {
                del.Amount__c = amount;
                
            }
        }
        Database.update(lstDelivery, false);
            
    }
}