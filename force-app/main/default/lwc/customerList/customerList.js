import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchCustomers from '@salesforce/apex/CustomerController.searchCustomers';

export default class CustomerList extends NavigationMixin(LightningElement)  {
    @track customers;
    @track error;
    @track isNoResult = false;
    searchKey = '';
    delayTimeout;
    @track isLoading = false;
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
            return;
        }
        this.isLoading = true;
        searchCustomers({ keyword: this.searchKey })
            .then((result) => {
                this.customers = result;
                this.isNoResult = result.length === 0;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error.body?.message || 'Unknown error';
                this.customers = [];
            });
    }
/* eslint-enable @lwc/lwc/no-async-operation */
    handleCustomerNavigate(event) {
        const customerId = event.detail;

        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__CustomerDetailAura'
            },
            state: {
                c__recordId: customerId
            }
        });
    }
}
