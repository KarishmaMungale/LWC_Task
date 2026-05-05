public class ConditionalApex {
	
    public static void handleCustomerInteractions(string typeOfCustomer, Decimal purchaseAmount, Boolean isNewCustomer, Boolean refundrequested){
        
        if(typeOfCustomer== 'Premium'&& purchaseAmount>0){
            System.debug('Thank you, Here is your gift card');
        }
        else if(typeOfCustomer == 'Regular' && purchaseAmount >0){
            System.debug('Thank you');
        }
        if(isNewCustomer && typeOfCustomer == 'Premium'){
            System.debug('thank you!');
        }
        if(typeOfCustomer =='Premium' && refundRequested){
            System.debug('Your refund has been Initiated');
        }
        if(typeOfCustomer =='Regular'&& refundRequested){
            System.debug('Your refund has not been Initiated');
        }
        if (typeOfCustomer!= 'Regular' && typeOfCustomer != 'Premium' && purchaseAmount>0){
            System.debug('Congrats! You are getting 10% Discount');
        }
        if(purchaseAmount < 0){
            system.debug('Please try Again');
        }
        if ((typeOfCustomer == 'Regular' || typeOfCustomer == 'Guest')&& purchaseAmount>0){
            System.debug('Thank You for purchasing');
        }
        
    }
       
    public static void handleMyschedule(Integer timeInHours){
            if(timeInHours == 10 ){
                System.debug('It\'s time to breakfast' );
            }
               else if (timeInHours ==13)  {
                   System.debug('It\'s time to Study');
                                              
             }
                else if (timeInHours == 16){
                      System.debug('Its time to lunch');
              }
            else {
                system.debug('Its free time');
            }
        }
    
    public static void handleMyScheduleInSwitchCase(integer timeInHours){
        switch on timeInHours {
            when 10 {
                system.debug('its time for breakfast');
            }
            when 12,14 {
                system.debug('its time for nap');
            }
            when 19 {
                system.debug('its time for roaming');
            }
            when else{
                system.debug('Its free time');
            }
        }
    }
                             
    }