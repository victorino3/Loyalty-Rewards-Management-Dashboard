import { LightningElement } from 'lwc';
import fetchRewardsFromMuleSoft from '@salesforce/apex/MuleSoftAPIController.fetchRewardsFromMuleSoft';
import fetchCustomersFromMuleSoft from '@salesforce/apex/MuleSoftAPIController.fetchCustomersFromMuleSoft';
import { NavigationMixin } from 'lightning/navigation';

export default class AdminPanel extends NavigationMixin(LightningElement) {
    mode = 'form';
    muleAction = '';
    rewards = [];
    customers = [];

    handleModeChange(event) {
        this.mode = event.target.value;
        this.muleAction = '';
    }

    handleMuleActionChange(event) {
        this.muleAction = event.target.value;
        if (this.muleAction === 'rewards') {
            this.getRewards();
        } else if (this.muleAction === 'customers') {
            this.getCustomers();
        }
    }

    getRewards() {
        fetchRewardsFromMuleSoft()
            .then(result => {
                this.rewards = result;
            })
            .catch(error => {
                console.error('Error fetching rewards:', error);
            });
    }

    getCustomers() {
        fetchCustomersFromMuleSoft()
            .then(result => {
                this.customers = result;
            })
            .catch(error => {
                console.error('Error fetching customers:', error);
            });
    }

    handleViewRewards() {
        this.navigateToObject('Reward__c');
    }

    handleViewCustomers() {
        this.navigateToObject('Customer__c');
    }

    navigateToObject(objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }
}
