trigger CustomerDetails on 	Customer__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        CustomerDetailsHandlers.setTierLevel(Trigger.new);
        CustomerDetailsHandlers.sendEmailToCustomer(Trigger.new);
    }
    
}