public with sharing class MuleSoftIntegrationHandlerQueueable implements Queueable, Database.AllowsCallouts {

    private String objectName;
    private String responseBody;

    public MuleSoftIntegrationHandlerQueueable(String objectName, String responseBody) {
        this.objectName = objectName;
        this.responseBody = responseBody;
    }

    public class InsertResultWrapper {
        public List<Id> successIds = new List<Id>();
        public List<String> errorMessages = new List<String>();
    }

    public void execute(QueueableContext context) {
        InsertResultWrapper resultWrapper = new InsertResultWrapper();
        List<SObject> sObjectsToInsert = new List<SObject>();

        try {
            System.debug('Response Body: ' + responseBody);

            Object parsedResponse = JSON.deserializeUntyped(responseBody);

            if (parsedResponse instanceof List<Object>) {
                List<Object> records = (List<Object>) parsedResponse;

                for (Object recordObj : records) {
                    Map<String, Object> recordMap = (Map<String, Object>) recordObj;

                    if (objectName == 'Customer' && Schema.sObjectType.Customer__c.isCreateable()) {
                        Customer__c customer = new Customer__c();
                        customer.Name = (String) recordMap.get('name');
                        customer.Email__c = (String) recordMap.get('email');
                        customer.Points_Balance__c = recordMap.containsKey('Points_Balance__c') ?
                            Integer.valueOf(String.valueOf(recordMap.get('Points_Balance__c'))) : 0;
                        customer.Tier__c = (String) recordMap.get('Tier__c');
                        sObjectsToInsert.add(customer);

                    } else if (objectName == 'Reward' && Schema.sObjectType.Reward__c.isCreateable()) {
                        Reward__c reward = new Reward__c();
                        reward.Name = (String) recordMap.get('name');
                        reward.Description__c = (String) recordMap.get('description');
                        reward.Points_Required__c = recordMap.containsKey('points') ?
                            Integer.valueOf(String.valueOf(recordMap.get('points'))) : 0;
                        reward.Partner__c = (String) recordMap.get('partner');
                        sObjectsToInsert.add(reward);
                    }
                }

                if (!sObjectsToInsert.isEmpty()) {
                    System.debug('Inserting sObjects: ' + sObjectsToInsert.size());
                    Database.SaveResult[] results = Database.insert(sObjectsToInsert, false);

                    for (Integer i = 0; i < results.size(); i++) {
                        if (results[i].isSuccess()) {
                            resultWrapper.successIds.add(results[i].getId());
                        } else {
                            for (Database.Error err : results[i].getErrors()) {
                                resultWrapper.errorMessages.add('Error at record ' + i + ': ' + err.getMessage());
                            }
                        }
                    }
                }
            } else {
                throw new AuraHandledException('Unexpected response format: expected a list of records.');
            }

            System.debug('InsertResultWrapper: ' + resultWrapper);
        } catch (Exception e) {
            System.debug('Exception in MuleSoftIntegrationHandlerQueueable: ' + e.getMessage());
            throw new AuraHandledException('Error inserting records: ' + e.getMessage());
        }
    }
}
