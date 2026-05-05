public with sharing class productController {
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {

        return [SELECT Id, Name, Description from Product2 Limit 10];
    }
}