import { LightningElement, api } from 'lwc';
import createRedemption from '@salesforce/apex/RedemptionController.createRedemption';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RedemptionForm extends LightningElement {
    @api selectedReward;
    customerId = '';
    isSubmitting = false;

    handleCustomerChange(event) {
        this.customerId = event.target.value;
    }


    async handleSubmit() {
        this.isSubmitting = true;
        try {
            await createRedemption({ 
                customerId: this.customerId, 
                rewardId: this.selectedReward.Id 
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `Redemption created for ${this.selectedReward.Name}`,
                variant: 'success'
            }));

            this.customerId = '';
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error creating redemption',
                message: error.body.message,
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
