public with sharing class RedemptionController {
    @AuraEnabled
    public static void createRedemption(Id customerId, Id rewardId) {
        // FLS check
        if (!Schema.sObjectType.Redemption__c.fields.Customer__c.isCreateable() ||
            !Schema.sObjectType.Redemption__c.fields.Reward__c.isCreateable()) {
            throw new System.SecurityException('Insufficient field permissions to create Redemption.');
        }

        Redemption__c redemption = new Redemption__c(
            Customer__c = customerId,
            Reward__c = rewardId
        );
        insert redemption;
    }
}
