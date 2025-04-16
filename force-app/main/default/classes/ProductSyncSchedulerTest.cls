@isTest
public class ProductSyncSchedulerTest {

    @TestSetup
    static void setupTestData() {
        Product__c testProduct = new Product__c(
            Name = 'Test Product to Delete',
            API_Id__c = '999',
            Category__c = 'Test',
            Price__c = 100
        );
        insert testProduct;
    }

    @isTest
    static void testSuccessfulSyncExecution() {
        // Setup mock HTTP callout with sample product data
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockSuccess());
        
        Test.startTest();
        new ProductSyncScheduler().execute(null);
        Test.stopTest();
        List<Product__c> products = [SELECT Id FROM Product__c WHERE API_Id__c = '1'];
        System.assertEquals(1, products.size(), 'New product should be created from mock response');
        
        List<Product__c> deletedProducts = [SELECT Id FROM Product__c WHERE API_Id__c = '999'];
        System.assertEquals(0, deletedProducts.size(), 'Test product should be deleted as not in API response');

        System.assertEquals(0, [SELECT COUNT() FROM Error_Log__c], 'No error logs should exist for successful sync');
    }

    @isTest
    static void testFailedSyncExecution() {
        // Setup failed HTTP callout
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockFailure());
        
        Test.startTest();
        new ProductSyncScheduler().execute(null);
        Test.stopTest();

        List<Error_Log__c> errorLogs = [SELECT Error_Message__c, Source__c, Severity__c FROM Error_Log__c];
        System.assertEquals(1, errorLogs.size(), 'Error log should be created');
        System.assertEquals('ProductSyncScheduler', errorLogs[0].Source__c, 'Correct error source');
        System.assertEquals('High', errorLogs[0].Severity__c, 'Correct error severity');
        System.assert(errorLogs[0].Error_Message__c.contains('API Error'), 'Should contain API error message');
    }

    @isTest
    static void testScheduleJobExecution() {
        String jobName = 'Test_Product_Sync';
        String cronExp = '0 0 12 * * ?';
        
        Test.startTest();
        String jobId = System.schedule(jobName, cronExp, new ProductSyncScheduler());
        Test.stopTest();
        CronTrigger scheduledJob = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, scheduledJob.CronExpression, 'Correct cron expression');
        System.assertEquals('WAITING', scheduledJob.State, 'Job should be in waiting state');
    }

    public class ProductSyncMockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{' +
                '"products": [' +
                '  {' +
                '    "id": "1",' +
                '    "title": "Test Product",' +
                '    "category": "Test",' +
                '    "price": 100' +
                '  }' +
                ']' +
                '}');
            return res;
        }
    }

    // Enhanced mock for failed API call
    public class ProductSyncMockFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Server Error');
            return res;
        }
    }
}