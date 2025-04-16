public with sharing class CustomerController {
    @AuraEnabled(cacheable=true)
    public static List<Customer__c> getCustomers() {
        if (!Schema.sObjectType.Customer__c.isAccessible() || !Schema.sObjectType.Customer__c.isQueryable()) {
            throw new AuraHandledException('You do not have permission to access Customer records.');
        }
        return [
            SELECT Id, Name, Email__c, Points_Balance__c, Tier__c
            FROM Customer__c
            ORDER BY Name ASC
            LIMIT 50
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Customer__c> searchCustomers(String keyword) {
        String searchTerm = '%' + keyword + '%';
        return [
            SELECT Id, Name, Email__c, Points_Balance__c, Tier__c
            FROM Customer__c
            WHERE Name LIKE :searchTerm
            ORDER BY Name ASC
            LIMIT 50
        ];
    }
}
