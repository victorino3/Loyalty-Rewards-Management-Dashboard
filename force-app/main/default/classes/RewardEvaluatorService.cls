public with sharing class RewardEvaluatorService {

    public class RewardAssignmentResult {
        public String email;
        public String rewardName;
        public String message;
        public Decimal points;
        public Boolean success;
        public String product;
    }

    public static List<RewardAssignmentResult> evaluatePurchasesAndSendEmails(List<MuleSoftPurchaseService.PurchaseDTO> purchases) {
        List<RewardAssignmentResult> results = new List<RewardAssignmentResult>();
        //FLS check again shh vscode
        if (!Schema.sObjectType.Reward__c.isAccessible()) {
            System.debug('User does not have read access to Reward__c.');
            return results;
        }
        // Fetch all available rewards, grouped by partner
        Map<String, List<Reward__c>> rewardsByPartner = new Map<String, List<Reward__c>>();
        for (Reward__c reward : [SELECT Id, Name, Partner__c, Points_Required__c FROM Reward__c WHERE Partner__c != null]) {
            if (!rewardsByPartner.containsKey(reward.Partner__c)) {
                rewardsByPartner.put(reward.Partner__c, new List<Reward__c>());
            }
            rewardsByPartner.get(reward.Partner__c).add(reward);
        }

        for (MuleSoftPurchaseService.PurchaseDTO purchase : purchases) {
            RewardAssignmentResult result = new RewardAssignmentResult();
            result.email = purchase.email;
            result.product = purchase.product;

            List<Reward__c> partnerRewards = rewardsByPartner.get(purchase.partner);

            if (partnerRewards != null && !partnerRewards.isEmpty()) {
                Reward__c selectedReward = partnerRewards[Math.mod(Crypto.getRandomInteger(), partnerRewards.size())];
                result.rewardName = selectedReward.Name;
                result.points = selectedReward.Points_Required__c;
            } else {
                result.success = false;
                result.message = 'No reward found for partner: ' + purchase.partner;
            }

            results.add(result);
        }
        // Send emails
        sendEmailWrapper(results);
        setErrorLog(results);
        return results;
    }

    public static void sendEmailWrapper(List<RewardAssignmentResult> results) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
        for (RewardAssignmentResult data : results) {
            Boolean isEligible = validateCustomerPoints(data.email, data.rewardName);
    
            if (!isEligible) {
                data.success = false;
                data.message = 'Customer does not exist or lacks enough points to redeem reward.';
                continue;
            }
    
            try {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { data.email });
                email.setSubject('🎁 You’ve Earned a Reward!');
                email.setPlainTextBody(
                    'Hi there,\n\n' +
                    'Thanks for your recent purchase of ' + data.product + '.\n' +
                    'You’ve earned a reward: "' + data.rewardName + '" worth ' + data.points + ' points.\n\n' +
                    'To redeem it, simply reply to this email with the word "redeem".\n\n' +
                    'Enjoy your reward!\n- Your Loyalty Team'
                );
                emails.add(email);
    
                // Mark success now (since we're adding this to send)
                data.success = true;
                data.message = 'Email queued to be sent to.'+ data.email;
            } catch (Exception e) {
                data.success = false;
                data.message = 'Failed to build email: ' + e.getMessage();
            }
        }
    
        try {
            if (!emails.isEmpty() && EmailLimitChecker.checkEmailLimits()) {
                Messaging.sendEmail(emails);
            }
        } catch (Exception ex) {
            for (RewardAssignmentResult result : results) {
                if (result.success) { // Only overwrite if previously marked success
                    result.success = false;
                    result.message = 'Failed to send email to: '+result.email+ 'Due to email limit or ' + ex.getMessage();
                }
            }
        }
    }
    
    public static void setErrorLog(List<RewardAssignmentResult> results) {
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();

        for (RewardAssignmentResult result : results) {
            if (!result.success) {
                Error_Log__c errorLog = new Error_Log__c();
                errorLog.Name = 'Email Error';
                errorLog.Error_Message__c = 'Email in case '+result.email+ 'Error: '+result.message;
                errorLogs.add(errorLog);
            }else{
                Error_Log__c errorLog = new Error_Log__c();
                errorLog.Name = 'Email Success';
                errorLog.Success_Message__c = 'Email in case '+result.email+ 'Success: '+result.message;
                errorLogs.add(errorLog);
            }
        }

        if (!errorLogs.isEmpty()) {
            if (Schema.sObjectType.Error_Log__c.isCreateable()) {
                insert errorLogs;
            } else {
                System.debug('User does not have create access to Error_Log__c.');
            }
        }
    }

    public static Boolean validateCustomerPoints(String email, String rewardName) {
        if (!Schema.sObjectType.Customer__c.isAccessible() || !Schema.sObjectType.Reward__c.isAccessible()) {
            return false;
        }
    
        List<Customer__c> customers = [SELECT Id, Email__c, Points_Balance__c FROM Customer__c WHERE Email__c = :email LIMIT 1];
        if (customers.isEmpty()) {
            return false;
        }
    
        Customer__c customer = customers[0];
    
        List<Reward__c> rewards = [SELECT Id, Name, Points_Required__c FROM Reward__c WHERE Name = :rewardName LIMIT 1];
        if (rewards.isEmpty()) {
            return false;
        }
    
        Reward__c reward = rewards[0];
    
        return customer.Points_Balance__c >= reward.Points_Required__c;
    }
    

}
