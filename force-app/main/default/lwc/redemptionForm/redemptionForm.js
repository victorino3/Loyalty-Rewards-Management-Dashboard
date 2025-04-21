import { LightningElement, api } from 'lwc';
import createRedemptionBulk from '@salesforce/apex/RedemptionController.createRedemptionBulk';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateRewardRedemption from '@salesforce/apex/RewardEligibilityController.validateRewardRedemption';

export default class RedemptionForm extends LightningElement {
    @api selectedReward;
    customerId = '';
    isSubmitting = false;

    handleCustomerChange(event) {
        this.customerId = event.target.value;
    }

    buildRedemptionList() {
        const redemption = {
            Customer__c: this.customerId,
            Reward__c: this.selectedReward.Id,
            Status__c: this.selectedReward.Is_Active__c,
            Date__c: new Date().toISOString().split('T')[0]
        };
        return [redemption];
    }
    /**
     * Add in future for bulk
     * buildRedemptionList() {
    const redemptionList = [];

    const rewards = this.selectedRewards; // imagine this is an array
    for (const reward of rewards) {
        redemptionList.push({
            Customer__c: this.customerId,
            Reward__c: reward.Id,
            Status__c: reward.Is_Active__c ? 'Active' : 'Inactive',
            Date__c: new Date().toISOString()
        });
    }

    return redemptionList;
}
     */

    async handleSubmit() {
        this.isSubmitting = true;
        try {
            //Validate reward eligibility
            const validationResult = await validateRewardRedemption({
                customerId: this.customerId,
                rewardId: this.selectedReward.Id
            });
    
            if (!validationResult.isValid) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Ineligible',
                    message: validationResult.message,
                    variant: 'warning'
                }));
                return;
            }
    
            // ✅ If eligible: build redemption and call Apex
            const redemptionList = this.buildRedemptionList();
            const payload = JSON.stringify(redemptionList);

            await createRedemptionBulk({ redemptionsJson: payload });
    
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `Redemption created for ${this.selectedReward.Name}`,
                variant: 'success'
            }));
    
            this.customerId = '';
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error creating redemption',
                message: error.body?.message || 'Unknown error',
                variant: 'error'
            }));
        } finally {
            this.isSubmitting = false;
        }
    }
    
    

    get isRedeemDisabled() {
        return this.isSubmitting || !this.customerId;
    }
}
