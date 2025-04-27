import { LightningElement, api } from 'lwc';

export default class RewardCatalog extends LightningElement {
    @api reward; 
    error;

    handleSelect(event) {
        const rewardId = event.currentTarget.dataset.id;
        if (this.reward.Id === rewardId) { 
            const rewardEvent = new CustomEvent('rewardselected', {
                detail: this.reward
            });
            this.dispatchEvent(rewardEvent);
        }
    }
}
