
import { LightningElement, wire } from 'lwc';
import getAvailableRewards from '@salesforce/apex/RewardController.getAvailableRewards';

export default class RewardCatalog extends LightningElement {
    rewards;
    error;

    @wire(getAvailableRewards)
    wiredRewards({ data, error }) {
        if (data) {
            this.rewards = data;
        } else if (error) {
            this.error = error.body.message;
        }
    }

    handleSelect(reward) {
        // Emit reward to parent (e.g. RedemptionForm)
        const event = new CustomEvent('rewardselected', {
            detail: reward
        });
        this.dispatchEvent(event);
    }
}
