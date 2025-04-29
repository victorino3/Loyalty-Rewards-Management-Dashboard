import { LightningElement, api } from 'lwc';
import getAvailableRewards from '@salesforce/apex/RewardController.getAvailableRewards';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RewardCatalog extends LightningElement {
    @api reward; 
    rewards = []; 
    error;

    connectedCallback() {
        if (this.reward) {
            this.rewards = [this.reward]; 
        } else {
            this.loadRewards(); 
        }
    }

    loadRewards() {
        getAvailableRewards()
            .then(result => {
                this.rewards = result;
            })
            .catch(error => {
                this.error = error;
                this.rewards = [];
                this.showToast('Error', 'Failed to fetch rewards. Contact the Admin.', 'error');
                console.error(error);
            });
    }

    handleSelect(event) {
        const rewardId = event.currentTarget.dataset.id;
        const selected = this.rewards.find(r => r.Id === rewardId);

        if (selected) {
            const rewardEvent = new CustomEvent('rewardselected', {
                detail: selected
            });
            this.dispatchEvent(rewardEvent);
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
