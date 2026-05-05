public class CollectionsInApex {
    
    public static void mapListCollection(String employeeId){
        
        Map<string, string> employeeDetails = new Map<string, string>();
   		employeeDetails.put('EMP2020', 'Karishma');
        employeeDetails.put('EMP3030', 'Thash');
        
        System.debug(employeeDetails);
        employeeDetails.remove('EMP3030');
        System.debug(employeeDetails);
        employeeDetails.put('EMP4545', 'Karina');
        system.debug(employeeDetails);
        system.debug(employeeDetails.size());
        System.debug('You are Seeking info for '+ employeeDetails.get(employeeId));
    }	
    
    public static void handleListCollections(){
        List<String> myFavPlaces = new List<string> {'Nagpur', 'Umred', 'Mumbai'};
        List <Integer> myFavNumber = new List<Integer> {4,6,9,3};
        List <Boolean> myThoughts = new List<Boolean> {true, false};
        
        Account acc = new Account();
        List<Account> accRecords= new List<Account> {acc};
            
            myFavPlaces.add('Ambernath');
        myFavNumber.add(7);
        System.debug('My favourite Numbers' +myFavNumber);
        
        System.debug('The place is '+ myFavPlaces.get(0) );
        System.debug('The number of places '+ myFavPlaces.size());
    }
    
    public static void handleSetCollections(){
        Set<String> myPaintings = new set <string>();
        Set <String> pens = new Set<String>{'Montex','Gel' ,'Gel', 'Pilot'};
        System.debug(pens);
        
        System.debug(pens.add('Hauser'));
       System.debug (pens.remove('Gel'));
        
        system.debug(pens.contains('Montex'));
        system.debug(pens.size());
    } 
}