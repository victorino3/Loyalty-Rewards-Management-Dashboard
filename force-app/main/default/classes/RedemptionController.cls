public with sharing class RedemptionController {
    @AuraEnabled
    public static void createRedemptionBulk(String redemptionsJson) {
        List<Redemption__c> redemptions = (List<Redemption__c>) JSON.deserialize(redemptionsJson, List<Redemption__c>.class);

        // Optional: Add FLS check
        for (Redemption__c red : redemptions) {
            if (!Schema.sObjectType.Redemption__c.fields.Customer__c.isCreateable() ||
                !Schema.sObjectType.Redemption__c.fields.Reward__c.isCreateable()) {
                throw new System.SecurityException('Insufficient field permissions to create Redemption.');
            }
        }

        insert redemptions;
    }

    @AuraEnabled
    public static List<Customer__c> getCustomerName(String customerEmail) {

        if (!Schema.sObjectType.Customer__c.fields.Name.isAccessible()) {
            throw new AuraHandledException('You do not have permission to access Customer Name.');
        }
        List<Customer__c> customers = [SELECT Id, Name FROM Customer__c WHERE Email__c = :customerEmail LIMIT 1];
        return customers;
    }
}
