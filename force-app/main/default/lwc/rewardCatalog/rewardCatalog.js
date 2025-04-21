
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
    
}
