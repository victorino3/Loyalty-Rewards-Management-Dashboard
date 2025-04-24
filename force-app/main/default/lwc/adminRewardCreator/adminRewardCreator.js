import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
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
        this.rewards = [];
        this.customers = [];
    }

    handleMuleActionChange(event) {
        this.muleAction = event.target.value;
    }

    get isFormMode() {
        return this.mode === 'form';
    }

    get isMuleSoftMode() {
        return this.mode === 'mulesoft';
    }

    get isRetrieveDisabled() {
        return !this.muleAction;
    }

    handleRetrieveData() {
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
                this.customers = []; // clear customer if switching
                this.showToast('Success', 'Rewards fetched successfully!', 'success');
            })
            .catch(error => {
                this.rewards = [];
                this.showToast('Error', 'Failed to fetch rewards.', 'error');
                console.error(error);
            });
    }

    getCustomers() {
        fetchCustomersFromMuleSoft()
            .then(result => {
                this.customers = result;
                this.rewards = []; // clear reward if switching
                this.showToast('Success', 'Customers fetched successfully!', 'success');
            })
            .catch(error => {
                this.customers = [];
                this.showToast('Error', 'Failed to fetch customers.', 'error');
                console.error(error);
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
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

    get modeOptions() {
        return [
            { label: 'MuleSoft', value: 'mulesoft' },
            { label: 'Form', value: 'form' }
        ];
    }

    get muleOptions() {
        return [
            { label: 'Retrieve Rewards', value: 'rewards' },
            { label: 'Retrieve Customers', value: 'customers' }
        ];
    }

    handleViewRewards() {
        this.navigateToObject('Reward__c');
    }

    handleViewCustomers() {
        this.navigateToObject('Customer__c');
    }
}
