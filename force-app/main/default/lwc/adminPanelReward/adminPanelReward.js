import { LightningElement } from 'lwc';
import createReward from '@salesforce/apex/RewardAdminController.createReward';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AdminRewardCreator extends LightningElement {
    rewardName = '';
    pointsCost = null;
    pointsRequired = null;
    expiryDate = '';
    isActive = false;
    isSubmitting = false;

    handleNameChange(event) {
        this.rewardName = event.target.value;
    }

    handlePointsCostChange(event) {
        this.pointsCost = Number(event.target.value);
    }

    handlePointsRequiredChange(event) {
        this.pointsRequired = Number(event.target.value);
    }

    handleExpiryDateChange(event) {
        this.expiryDate = event.target.value;
    }

    handleIsActiveChange(event) {
        this.isActive = event.target.checked;
    }

    async handleSubmit() {
        this.isSubmitting = true;

        try {
            const payload = {
                Name: this.rewardName,
                Points_Cost__c: this.pointsCost,
                Points_Required__c: this.pointsRequired,
                Expiry_Date__c: this.expiryDate,
                Is_Active__c: this.isActive
            };

            await createReward({ rewardData: payload });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Reward created successfully',
                variant: 'success'
            }));

            this.clearForm();
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Error creating reward',
                variant: 'error'
            }));
        } finally {
            this.isSubmitting = false;
        }
    }

    clearForm() {
        this.rewardName = '';
        this.pointsCost = null;
        this.pointsRequired = null;
        this.expiryDate = '';
        this.isActive = false;
    }
}
