public with sharing class RewardAssignmentJobHandler {

    @future(callout=true)
    public static void executeJob() {
        List<MuleSoftPurchaseService.PurchaseDTO> purchases = MuleSoftPurchaseService.fetchPurchases();

        List<RewardEvaluatorService.RewardAssignmentResult> results =
            RewardEvaluatorService.evaluatePurchasesAndSendEmails(purchases);

        for (RewardEvaluatorService.RewardAssignmentResult r : results) {
            System.debug('Email to: ' + r.email + ' | Status: ' + r.message);
        }
    }
}
