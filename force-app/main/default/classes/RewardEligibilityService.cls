public class RewardEligibilityService {
    public class RedemptionValidationResult {
        public Boolean isValid;
        public String message;
    }

    public static RedemptionValidationResult validate(Customer__c customer, Reward__c reward) {
        RedemptionValidationResult result = new RedemptionValidationResult();

        if (!reward.Is_Active__c) {
            result.isValid = false;
            result.message = 'Reward is not active.';
            return result;
        }

        if (reward.Expiry_Date__c != null && reward.Expiry_Date__c < Date.today()) {
            result.isValid = false;
            result.message = 'Reward has expired.';
            return result;
        }

        if (customer.Points_Balance__c < reward.Points_Required__c) {
            result.isValid = false;
            result.message = 'Customer does not have enough points.';
            return result;
        }

        result.isValid = true;
        result.message = 'Eligible to redeem.';
        return result;
    }
}
