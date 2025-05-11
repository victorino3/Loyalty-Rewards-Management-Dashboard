import { LightningElement, api, track } from 'lwc';
import createRedemptionBulk from '@salesforce/apex/RedemptionController.createRedemptionBulk';
import getCustomerName from '@salesforce/apex/RedemptionController.getCustomerName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateRewardRedemption from '@salesforce/apex/RewardEligibilityController.validateRewardRedemption';

export default class RedemptionForm extends LightningElement {
    @api selectedReward;
    isSubmitting = false;
    customerEmail = '';
    customerName;
    customerId;
    customerError;
    @track isLoading = false;
    searchTimeout;

    debounceTimeout;
     // eslint-disable-next-line @lwc/lwc/no-async-operation
    handleCustomerChange(event) {
        this.customerEmail = event.target.value;
        // Debounce the actual Apex call
        clearTimeout(this.searchTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimeout = setTimeout(() => {
            this.searchCustomer();
        }, 700);
    }

     searchCustomer() {
        if (!this.customerEmail) return;

        this.isLoading = true;
        getCustomerName({ customerEmail: this.customerEmail })
            .then(result => {
                this.customerName = result[0].Name;
                this.customerId = result[0].Id;
                this.customerError = null;
            })
            .catch(error => {
                this.customerError = error;
                this.customerName = null;
                this.customerId = null;
                console.error('Error fetching customer:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    //Update the status after to some TriggerFlow to make it more dynamic
    buildRedemptionList() {
        const redemption = {
            name: `Redemption for ${this.selectedReward.Name}`,
            Customer__c: this.customerId,
            Reward__c: this.selectedReward.Id,
            Partner__c: this.selectedReward.Partner__c,
            Status__c: 'Redeemed',
            Date__c: new Date().toISOString().split('T')[0],
            Points_Used__c: this.selectedReward.Points_Required__c,
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
                message: `Redemption created for ${this.selectedReward.Name} to ${this.customerName}`,
                variant: 'success'
            }));
    
            this.customerId = '';
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error creating redemption contact the Admin',
                message: error.body?.message || 'Unknown error',
                variant: 'error'
            }));
        } finally {
            this.isSubmitting = false;
        }
    }
    
    

    get isRedeemDisabled() {
        return this.isSubmitting || !this.customerEmail;
    }
}
