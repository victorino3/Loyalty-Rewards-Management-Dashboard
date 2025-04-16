import { LightningElement, track } from 'lwc';
import searchCustomers from '@salesforce/apex/CustomerController.searchCustomers';

export default class CustomerList extends LightningElement {
    @track customers;
    error;
    searchKey = '';
    delayTimeout;
    /* eslint-disable @lwc/lwc/no-async-operation */
    handleSearchChange(event) {
        // Clear the previous timer if user is still typing
        window.clearTimeout(this.delayTimeout);
        const value = event.target.value;

        // Set a new timer
        this.delayTimeout = setTimeout(() => {
            this.searchKey = value;
            this.findCustomers();
        }, 300); // Debounce delay in ms
    }

    findCustomers() {
        if (!this.searchKey) {
            this.customers = [];
            return;
        }

    searchCustomers({ keyword: this.searchKey })
        .then((result) => {
                this.customers = result;
                this.error = undefined;
        })
        .catch((error) => {
                this.error = error.body.message;
                this.customers = undefined;
            });
    }
/* eslint-enable @lwc/lwc/no-async-operation */
}
