import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class CustomerDetail extends LightningElement {
    @api recordId; 
    @track internalRecordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.internalRecordId = currentPageReference.state.c__recordId;
        }
    }

    connectedCallback() {
        console.log('Customer Detail for ID:', this.internalRecordId);
    }
}
