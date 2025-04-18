import { createElement } from 'lwc';
import CustomerList from 'c/customerList';
import searchCustomers from '@salesforce/apex/CustomerController.searchCustomers';

jest.mock(
    '@salesforce/apex/CustomerController.searchCustomers',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);


describe('c-customer-list', () => {
    beforeEach(() => {
        // Clean DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders customers from Apex', async () => {
        searchCustomers.mockResolvedValue([
            { Id: '1', Name: 'Test User', Tier__c: 'Gold' }
        ]);

        const element = createElement('c-customer-list', {
            is: CustomerList
        });

        document.body.appendChild(element);

        // Simulate user typing
        const input = element.shadowRoot.querySelector('lightning-input');
        input.value = 'Test';
        input.dispatchEvent(new CustomEvent('change'));

        // Flush Promises
        await Promise.resolve();

        const tiles = element.shadowRoot.querySelectorAll('c-customer-tile');
        expect(tiles.length).toBe(1);
    });
});
