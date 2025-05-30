import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchCustomers from '@salesforce/apex/CustomerController.searchCustomers';

export default class CustomerList extends NavigationMixin(LightningElement)  {
    @track customers;
    @track error;
    @track isNoResult = false;
    searchKey = '';
    delayTimeout;
    isLoading = false;
    @track selectedReward;
    /* eslint-disable @lwc/lwc/no-async-operation */
    handleSearchChange(event) {
        window.clearTimeout(this.delayTimeout);
        const value = event.target.value;

        this.delayTimeout = setTimeout(() => {
            this.searchKey = value;
            this.findCustomers();
        }, 300);
    }
    
    findCustomers() {
        if (!this.searchKey) {
            this.customers = [];
            this.isNoResult = false;
            this.isLoading = false; 
            return;
        }
    
        this.isLoading = true;
    
        searchCustomers({ keyword: this.searchKey })
            .then((result) => {
                this.customers = result;
                this.isNoResult = result.length === 0;
                this.error = undefined;
                this.isLoading = false; 
            })
            .catch((error) => {
                this.error = error.body?.message || 'Unknown error';
                this.customers = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
/* eslint-enable @lwc/lwc/no-async-operation */
    handleCustomerNavigate(event) {
        const customer = event.detail;
        const customerId = customer?.Id;

        if (!customerId) return;

        this[NavigationMixin.Navigate]({
            /*
            Was redirecting to the customer detail component Aura, but preferred to redirect to the costumer record page
            type: 'standard__component',
            attributes: {
                componentName: 'c__CustomerDetailAura'
            },
            state: {
                c__recordId: customerId
            }*/
            type: 'standard__recordPage',
            attributes: {
                    recordId: customer.Id,
                    objectApiName: 'Customer__c', // or 'Contact'
                    actionName: 'view'
                }
          
        });
    }

    handleRewardSelected(event) {
        this.selectedReward = event.detail;
        
    }


    get validCustomers() {
        return this.customers?.filter(c => c && c.Id);
    }
    
}
