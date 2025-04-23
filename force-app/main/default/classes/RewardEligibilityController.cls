public with sharing class RewardEligibilityController {

    public class ValidationResultWrapper {
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public String message;
    }

    @AuraEnabled(cacheable=false)
    public static ValidationResultWrapper validateRewardRedemption(Id customerId, Id rewardId) {
        if (customerId == null || rewardId == null) {
            throw new AuraHandledException('Customer ID and Reward ID are required.');
        }

        if (!Schema.sObjectType.Customer__c.isAccessible()) {
            throw new AuraHandledException('You do not have permission to access Customer records.');
        }

        Customer__c customer = [
            SELECT Id, Points_Balance__c
            FROM Customer__c
            WHERE Id = :customerId
            LIMIT 1
        ];

        if (!Schema.sObjectType.Reward__c.isAccessible()) {
            throw new AuraHandledException('You do not have permission to access Reward records.');
        }

        Reward__c reward = [
            SELECT Id, Is_Active__c, Expiry_Date__c, Points_Required__c
            FROM Reward__c
            WHERE Id = :rewardId
            LIMIT 1
        ];

        RewardEligibilityService.RedemptionValidationResult result =
            RewardEligibilityService.validate(customer, reward);

        ValidationResultWrapper wrapper = new ValidationResultWrapper();
        wrapper.isValid = result.isValid;
        wrapper.message = result.message;
        return wrapper;
    }
}
