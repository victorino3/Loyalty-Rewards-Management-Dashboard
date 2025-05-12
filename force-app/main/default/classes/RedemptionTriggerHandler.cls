public with sharing class RedemptionTriggerHandler {


    public static void handleAfterInsert(List<Redemption__c> newRedemptions) {
        system.debug('RedemptionTriggerHandler.handleAfterInsert() - Start');
        system.debug('RedemptionTriggerHandler.handleAfterInsert() - newRedemptions: ' + newRedemptions);
        Set<Id> customerIds = new Set<Id>();
        Set<Id> rewardIs = new Set<Id>();
        Map<Id, Decimal> pointsToDeduct = new Map<Id, Decimal>();

        for (Redemption__c red : newRedemptions) {
            if (red.Customer__c != null && red.Reward__c != null) {
                System.debug('RedemptionTriggerHandler.handleAfterInsert() - red.Customer__c: ' + red.Customer__c);
                System.debug('RedemptionTriggerHandler.handleAfterInsert() - red.Reward__c: ' + red.Reward__c); 
                customerIds.add(red.Customer__c);
                rewardIs.add(red.Reward__c);
            }
            
        }

        Map<Id, Reward__c> rewardMap = new Map<Id, Reward__c>(
            [SELECT Id, Points_Cost__c FROM Reward__c WHERE Id IN :rewardIs]
        );
        System.debug('RedemptionTriggerHandler.handleAfterInsert() - rewardMap: ' + rewardMap);

        for (Redemption__c red : newRedemptions) {
            if (rewardMap.containsKey(red.Reward__c)) {
                Decimal cost = rewardMap.get(red.Reward__c).Points_Cost__c;
                addToPointsMap(pointsToDeduct, red.Customer__c, cost);
                System.debug('RedemptionTriggerHandler.handleAfterInsert() - addToPointsMap cost: ' + cost);
            }
        }

        if (Schema.sObjectType.Customer__c.isAccessible()) {
            List<Customer__c> customersToUpdate = [
                SELECT Id, Points_Balance__c, Tier__c FROM Customer__c WHERE Id IN :customerIds
            ];
            System.debug('RedemptionTriggerHandler.handleAfterInsert() - customersToUpdate: ' + customersToUpdate);
            for (Customer__c cust : customersToUpdate) {
                Decimal toDeduct = pointsToDeduct.get(cust.Id);
                System.debug('RedemptionTriggerHandler.handleAfterInsert() - toDeduct: ' + toDeduct);
                cust.Points_Balance__c = Math.max(0, cust.Points_Balance__c - toDeduct);
                cust.Tier__c = LoyaltyUtils.getTierForPoints(cust.Points_Balance__c);
            }

            if (Schema.sObjectType.Customer__c.isUpdateable()) {
                update customersToUpdate;
            }
        }
    }

    private static void addToPointsMap(Map<Id, Decimal> pointsMap, Id customerId, Decimal cost) {
        if (pointsMap.containsKey(customerId)) {
            pointsMap.put(customerId, pointsMap.get(customerId) + cost);
        } else {
            pointsMap.put(customerId, cost);
        }
        System.debug('RedemptionTriggerHandler.addToPointsMap() - pointsMap: ' + pointsMap);
    }
    
}
