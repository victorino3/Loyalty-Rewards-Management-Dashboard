public with sharing class RewardEvaluatorService {

    public class RewardAssignmentResult {
        public String email;
        public String rewardName;
        public String message;
        public Boolean success;
    }

    public static List<RewardAssignmentResult> evaluatePurchasesAndSendEmails(List<MuleSoftPurchaseService.PurchaseDTO> purchases) {
        List<RewardAssignmentResult> results = new List<RewardAssignmentResult>();

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

            List<Reward__c> partnerRewards = rewardsByPartner.get(purchase.partner);

            if (partnerRewards != null && !partnerRewards.isEmpty()) {
                Reward__c selectedReward = partnerRewards[Math.mod(Crypto.getRandomInteger(), partnerRewards.size())];
                result.rewardName = selectedReward.Name;

                // Send email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { purchase.email });
                email.setSubject('🎁 You’ve Earned a Reward!');
                email.setPlainTextBody(
                    'Hi there,\n\n' +
                    'Thanks for your recent purchase of ' + purchase.product + '.\n' +
                    'You’ve earned a reward: "' + selectedReward.Name + '" worth ' + selectedReward.Points_Required__c + ' points.\n\n' +
                    'To redeem it, simply reply to this email with the word "redeem".\n\n' +
                    'Enjoy your reward!\n- Your Loyalty Team'
                );

                try {
                    Messaging.sendEmail(new List<Messaging.Email> { email });
                    result.success = true;
                    result.message = 'Email sent with reward: ' + selectedReward.Name;
                } catch (Exception ex) {
                    result.success = false;
                    result.message = 'Failed to send email: ' + ex.getMessage();
                }

            } else {
                result.success = false;
                result.message = 'No reward found for partner: ' + purchase.partner;
            }

            results.add(result);
        }

        return results;
    }
}
