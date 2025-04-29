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
                        System.debug('Processing Customer record: ' + recordMap);
                        Customer__c customer = new Customer__c();
                        customer.Name = (String) recordMap.get('Name');
                        customer.Email__c = (String) recordMap.get('Email__c');
                        customer.Points_Balance__c = recordMap.containsKey('Points_Balance__c') ?
                            Integer.valueOf(String.valueOf(recordMap.get('Points_Balance__c'))) : 0;
                        customer.Tier__c = (String) recordMap.get('Tier__c');
                        sObjectsToInsert.add(customer);

                    } else if (objectName == 'Reward' && Schema.sObjectType.Reward__c.isCreateable()) {
                        Reward__c reward = new Reward__c();
                        reward.Name = (String) recordMap.get('Name');
                        reward.Description__c = (String) recordMap.get('Description__c');
                        reward.Points_Required__c = recordMap.containsKey('Points_Required__c') ?
                            Integer.valueOf(String.valueOf(recordMap.get('Points_Required__c'))) : 0;
                        reward.Partner__c = (String) recordMap.get('Partner__c');
                        //add expriration date if present or if not add date 30 days from now using operator
                        if (recordMap.containsKey('Expiry_Date__c')) {
                            reward.Expiry_Date__c = Date.valueOf((String) recordMap.get('Expiry_Date__c'));
                        } else {
                            reward.Expiry_Date__c = Date.today().addDays(30);
                        }
                        reward.Is_Active__c = (Boolean) recordMap.get('Is_Active__c');

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
