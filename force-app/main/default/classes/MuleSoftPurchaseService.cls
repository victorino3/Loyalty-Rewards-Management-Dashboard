public with sharing class MuleSoftPurchaseService {

    public class PurchaseDTO {
        public String externalId;
        public String partner;
        public String product;
        public String description;
        public Decimal price;
        public String email;
    }

    @AuraEnabled(cacheable=true)
    public static List<PurchaseDTO> fetchPurchases() {
        System.debug('Fetching purchases from MuleSoft...');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:EcommersEvents/purchases');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return (List<PurchaseDTO>) JSON.deserialize(res.getBody(), List<PurchaseDTO>.class);
        } else {
            throw new AuraHandledException('Failed to fetch purchases: ' + res.getStatus());
        }
    }
}
