trigger CustomerDetails on 	Customer__c (before insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        CustomerDetailsHandlers.setTierLevel(Trigger.new);
        CustomerDetailsHandlers.sendEmailToCustomer(Trigger.new);
    }else if (Trigger.isAfter && Trigger.isUpdate){
        CustomerDetailsHandlers.updateTierLevel(Trigger.newMap, Trigger.oldMap);
    }
    
}