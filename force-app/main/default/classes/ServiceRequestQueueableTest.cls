@IsTest
private class ServiceRequestQueueableTest {

    @IsTest
    static void testHighAndCriticalRequestsAreEscalated() {

        List<Service_Request__c> requests =
            new List<Service_Request__c>();

        requests.add(
            new Service_Request__c(
                Subject__c = 'High Priority Test',
                Priority__c = 'High',
                Status__c = 'New'
            )
        );

        requests.add(
            new Service_Request__c(
                Subject__c = 'Critical Priority Test',
                Priority__c = 'Critical',
                Status__c = 'New'
            )
        );

        requests.add(
            new Service_Request__c(
                Subject__c = 'Medium Priority Test',
                Priority__c = 'Medium',
                Status__c = 'New'
            )
        );

        insert requests;

        Set<Id> requestIds = new Map<Id, Service_Request__c>(
            requests
        ).keySet();

        Test.startTest();

        System.enqueueJob(
            new ServiceRequestQueueable(requestIds)
        );

        Test.stopTest();

        List<Service_Request__c> results = [
            SELECT
                Id,
                Priority__c,
                Is_Escalated__c
            FROM Service_Request__c
            WHERE Id IN :requestIds
        ];

        for (Service_Request__c request : results) {

            if (
                request.Priority__c == 'High' ||
                request.Priority__c == 'Critical'
            ) {
                System.assertEquals(
                    true,
                    request.Is_Escalated__c,
                    request.Priority__c +
                    ' request should be escalated.'
                );

            } else if (request.Priority__c == 'Medium') {

                System.assertEquals(
                    false,
                    request.Is_Escalated__c,
                    'Medium request should not be escalated.'
                );
            }
        }
    }
}