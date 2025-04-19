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
    /* eslint-disable @lwc/lwc/no-async-operation */
    handleSearchChange(event) {
        window.clearTimeout(this.delayTimeout);
        const value = event.target.value;

        this.delayTimeout = setTimeout(() => {
            this.searchKey = value;
            this.findCustomers();
        }, 300); // Debounce delay in ms
    }
    
    findCustomers() {
        if (!this.searchKey) {
            this.customers = [];
            this.isNoResult = false;
            this.isLoading = false; // ✅ Reset spinner
            return;
        }
    
        this.isLoading = true;
    
        searchCustomers({ keyword: this.searchKey })
            .then((result) => {
                this.customers = result;
                this.isNoResult = result.length === 0;
                this.error = undefined;
                this.isLoading = false; // ✅ Turn off spinner
            })
            .catch((error) => {
                this.error = error.body?.message || 'Unknown error';
                this.customers = [];
            })
            .finally(() => {
                this.isLoading = false; // ✅ Turn off spinner
            });
    }
    
/* eslint-enable @lwc/lwc/no-async-operation */
    handleCustomerNavigate(event) {
        const customer = event.detail;
        console.log('Customer selected:', customer);
        console.log('Customer ID in handle:', customer.Id);
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


    get validCustomers() {
        return this.customers?.filter(c => c && c.Id);
    }
    
}
