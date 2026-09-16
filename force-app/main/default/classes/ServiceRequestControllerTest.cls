@IsTest
private class ServiceRequestControllerTest {

    @IsTest
static void testSearchRequests() {

    Service_Request__c request =
        new Service_Request__c(
            Subject__c = 'Laptop Network Issue',
            Priority__c = 'High',
            Status__c = 'New'
        );

    insert request;

    Test.startTest();

    List<Service_Request__c> results =
        ServiceRequestController.searchRequests('Laptop');

    Test.stopTest();

    System.assertEquals(
        1,
        results.size(),
        'SOSL should find the matching Service Request.'
    );

    System.assertEquals(
        'Laptop Network Issue',
        results[0].Subject__c
    );
}
}