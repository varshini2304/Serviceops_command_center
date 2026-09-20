@IsTest
private class ServiceRequestControllerTest {

    @IsTest
    static void testGetRequests() {

        Service_Request__c request = new Service_Request__c(
            Subject__c = 'Controller Test Request',
            Priority__c = 'High',
            Status__c = 'New',
            Category__c = 'Technical'
        );

        insert request;

        Test.startTest();

        List<Service_Request__c> results =
            ServiceRequestController.getRequests();

        Test.stopTest();

        System.assert(
            results.size() > 0,
            'Controller should return service requests.'
        );

        System.assertEquals(
            request.Id,
            results[0].Id,
            'Controller should return the created request.'
        );
    }

    @AuraEnabled(cacheable=true)
public static List<Service_Request__c> searchRequests(
    String searchTerm
) {
    if (String.isBlank(searchTerm)) {
        return new List<Service_Request__c>();
    }

    String searchPattern = '*' + searchTerm.trim() + '*';

    List<List<SObject>> searchResults = [
        FIND :searchPattern
        IN ALL FIELDS
        RETURNING
            Service_Request__c(
                Id,
                Name,
                Subject__c,
                Description__c,
                Status__c,
                Priority__c,
                Category__c,
                SLA_Due__c,
                Resolved_Date__c,
                Is_Escalated__c
                LIMIT 50
            )
    ];

    return (List<Service_Request__c>) searchResults[0];
}

}