import { createElement } from 'lwc';
import CustomerTile from 'c/customerTile';

function flushPromises() {
    return new Promise((resolve) => process.nextTick(resolve));
}

describe('c-customer-tile', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders customer name and tier text content', async () => {
        const element = createElement('c-customer-tile', {
            is: CustomerTile
        });

        element.customer = {
            Name: 'Alice Smith',
            Tier__c: 'Gold',
            Points_Balance__c: 1200,
            Email__c: 'alice@example.com'
        };

        document.body.appendChild(element);
        await flushPromises();

        // Instead of accessing lightning-card.title, just check for name in shadow text
        const text = element.shadowRoot.textContent;
        expect(text).toMatch(/Alice Smith/);
        expect(text).toMatch(/Gold/);
    });
});
