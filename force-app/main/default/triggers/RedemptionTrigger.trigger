trigger RedemptionTrigger on Redemption__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        RedemptionTriggerHandler.handleAfterInsert(Trigger.new);
    }
}
