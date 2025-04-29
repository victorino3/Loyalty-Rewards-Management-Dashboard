public with sharing class RewardAdminController {
    @AuraEnabled
    public static void createReward(Map<String, Object> rewardData) {
        Reward__c reward = new Reward__c();
        reward.Name = (String) rewardData.get('Name');
        reward.Points_Cost__c = (Decimal) rewardData.get('Points_Cost__c');
        reward.Points_Required__c = (Decimal) rewardData.get('Points_Required__c');
        reward.Expiry_Date__c = Date.valueOf((String) rewardData.get('Expiry_Date__c'));
        reward.Is_Active__c = (Boolean) rewardData.get('Is_Active__c');
        reward.Partner__c = (String) rewardData.get('Partner__c');
        reward.Description__c = (String) rewardData.get('Description__c');
    
        if (Schema.sObjectType.Reward__c.isCreateable()) {
            insert reward;
        } else {
            throw new AuraHandledException('You do not have permission to create Reward records.');
        }
    }
}
