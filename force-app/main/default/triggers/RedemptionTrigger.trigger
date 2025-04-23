trigger RedemptionTrigger on Redemption__c (after insert) {
    RedemptionTriggerHandler.handleAfterInsert(Trigger.isAfter, Trigger.isInsert);
}
