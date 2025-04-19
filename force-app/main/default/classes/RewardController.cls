public with sharing class RewardController {
    @AuraEnabled(cacheable=true)
    public static List<Reward__c> getAvailableRewards() {
        // Apply field-level security
        if (!Schema.sObjectType.Reward__c.isAccessible()) {
            throw new AuraHandledException('You do not have permission to access Reward records.');
        }
        List<Reward__c> rewards = [SELECT Id, Name, Points_Required__c, Description__c 
                                   FROM Reward__c 
                                   WHERE Is_Active__c = TRUE 
                                   ORDER BY CreatedDate DESC];

        List<Reward__c> safeRewards = new List<Reward__c>();
        for (Reward__c r : rewards) {
            Reward__c safe = new Reward__c();
            safe.Id = r.Id;
            safe.Name = r.Name;
            safe.Points_Required__c = r.Points_Required__c;
            safe.Description__c = r.Description__c;
            safeRewards.add(safe);
        }

        return safeRewards;
    }
}
