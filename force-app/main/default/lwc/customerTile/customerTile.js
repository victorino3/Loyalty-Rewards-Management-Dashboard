import { LightningElement, api } from 'lwc';

export default class CustomerTile extends LightningElement {
    @api customer;
    handleClick() {
        const selectedEvent = new CustomEvent('customerselected', {
            detail: this.customer
        });
        this.dispatchEvent(selectedEvent);
    }
}