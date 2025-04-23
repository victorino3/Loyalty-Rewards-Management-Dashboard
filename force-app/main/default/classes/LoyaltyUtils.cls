public with sharing class LoyaltyUtils {
    public static String getTierForPoints(Decimal points) {
        if (points >= 1000) {
            return 'Platinum';
        } else if (points >= 500) {
            return 'Gold';
        } else if (points >= 200) {
            return 'Silver';
        }
        return 'Bronze';
    }
}