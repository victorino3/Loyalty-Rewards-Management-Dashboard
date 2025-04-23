public with sharing class CustomerDetailsHandlers {
   public static void setTierLevel(List<Customer__c> customers) {
        for (Customer__c customer : customers) {
            if (customer.Points_Balance__c != null) {
                customer.Tier__c = LoyaltyUtils.getTierForPoints(customer.Points_Balance__c);
            }else{
                customer.Tier__c = 'Bronze';
            }
        }

    }
    
    public static void sendEmailToCustomer(List<Customer__c> customers) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Customer__c customer : customers) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { customer.Email__c });
            email.setSubject('Welcome to our Loyalty Program');
            email.setPlainTextBody('Dear ' + customer.Name + ',\n\nThank you for joining our loyalty program. Your current tier level is: ' + customer.Tier__c + '.\n\nBest regards,\nLoyalty Team');
            emails.add(email);
        }
        Messaging.sendEmail(emails);
    }

    public static void updateTierLevel(Map<Id, Customer__c> newMap, Map<Id, Customer__c> oldMap) {
        List<Customer__c> customersToUpdate = new List<Customer__c>();
    
        for (Id custId : newMap.keySet()) {
            Customer__c newCustomer = newMap.get(custId);
            Customer__c oldCustomer = oldMap.get(custId);
    
            if (newCustomer.Points_Balance__c != oldCustomer.Points_Balance__c) {
                Customer__c updated = new Customer__c(
                    Id = custId,
                    Tier__c = LoyaltyUtils.getTierForPoints(newCustomer.Points_Balance__c)
                );
                customersToUpdate.add(updated);
            }
        }
    
        if (!customersToUpdate.isEmpty()) {
            if (Schema.sObjectType.Customer__c.isUpdateable()) {
                update customersToUpdate;
            } else {
                throw new System.SecurityException('Insufficient permissions to update Customer records.');
            }
        }
    }
    
    
}