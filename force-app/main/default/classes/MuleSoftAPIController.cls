public with sharing class MuleSoftAPIController {
    @AuraEnabled(cacheable=true)
    public static List<Reward__c> fetchRewardsFromMuleSoft() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MuleSoftNamedCredential/rewards');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            // Parse and map JSON to Reward__c records
            List<Reward__c> rewards = (List<Reward__c>) JSON.deserialize(res.getBody(), List<Reward__c>.class);
            return rewards;
        } else {
            throw new AuraHandledException('Error: ' + res.getBody());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Customer__c> fetchCustomersFromMuleSoft() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MuleSoftNamedCredential/customers');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return (List<Customer__c>) JSON.deserialize(res.getBody(), List<Customer__c>.class);
        } else {
            throw new AuraHandledException('Error: ' + res.getBody());
        }
    }

    @AuraEnabled
    public static void enqueueMuleSoftInsert(String objectName, String responseBody) {
        System.enqueueJob(new MuleSoftIntegrationHandlerQueueable(objectName, responseBody));
    }

    @AuraEnabled
    public static void runRewardAssignmentJobNow() {
        RewardAssignmentJobHandler.executeJob();
    }
}
