public with sharing class DashboardController {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String stage, Id ownerId) {
        return [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE StageName = :stage
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getMetrics() {
        Map<String, Integer> data = new Map<String, Integer>();

        data.put('openOpps', [SELECT COUNT() FROM Opportunity WHERE IsClosed = false]);
        data.put('wonDeals', [SELECT COUNT() FROM Opportunity WHERE IsWon = true]);

        return data;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsWithLocation() {
        return [
            SELECT Name, BillingLatitude, BillingLongitude
            FROM Account
            WHERE BillingLatitude != null
        ];
    }
}