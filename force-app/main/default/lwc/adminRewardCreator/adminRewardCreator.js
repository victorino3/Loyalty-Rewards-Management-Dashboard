import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchRewardsFromMuleSoft from '@salesforce/apex/MuleSoftAPIController.fetchRewardsFromMuleSoft';
import fetchCustomersFromMuleSoft from '@salesforce/apex/MuleSoftAPIController.fetchCustomersFromMuleSoft';
import enqueueMuleSoftInsert from '@salesforce/apex/MuleSoftAPIController.enqueueMuleSoftInsert';
import { NavigationMixin } from 'lightning/navigation';

export default class AdminPanel extends NavigationMixin(LightningElement) {
    mode = 'form';
    muleAction = '';
    rewards = [];
    customers = [];
    showSaveButton = false;

    handleModeChange(event) {
        this.mode = event.target.value;
        this.muleAction = '';
        this.rewards = [];
        this.customers = [];
        this.showSaveButton = false;
    }

    handleMuleActionChange(event) {
        this.muleAction = event.target.value;
        this.showSaveButton = false;
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
                this.customers = [];
                this.showSaveButton = true; 
                this.showToast('Success', 'Rewards fetched successfully!', 'success');
            })
            .catch(error => {
                this.rewards = [];
                this.showSaveButton = false;
                this.showToast('Error', 'Failed to fetch rewards.', 'error');
                console.error(error);
            });
    }

    getCustomers() {
        fetchCustomersFromMuleSoft()
            .then(result => {
                this.customers = result;
                this.rewards = []; // clear reward if switching
                this.showSaveButton = true; // <== ENABLE Save
                this.showToast('Success', 'Customers fetched successfully!', 'success');
            })
            .catch(error => {
                this.customers = [];
                this.showSaveButton = false;
                this.showToast('Error', 'Failed to fetch customers.', 'error');
                console.error(error);
            });
    }

    handleSaveData() {
        enqueueMuleSoftInsert({ 
            objectName: this.muleAction === 'rewards' ? 'Reward' : 'Customer', 
            responseBody: JSON.stringify(this.muleAction === 'rewards' ? this.rewards : this.customers) 
        })
            .then(() => {
                this.showToast('Success', 'Insert job queued successfully!', 'success');
                this.showSaveButton = false; // Optionally hide Save after enqueuing
            })
            .catch(error => {
                this.showToast('Error', 'Failed to enqueue insert.', 'error');
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

    get hasRewards() {
        return this.rewards && this.rewards.length > 0;
    }
    
    get hasCustomers() {
        return this.customers && this.customers.length > 0;
    }
}
