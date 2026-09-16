@IsTest
private class ServiceRequestServiceTest {

    @IsTest
    static void testCriticalPrioritySla() {

        Service_Request__c request = new Service_Request__c(
            Subject__c = 'Critical Test Request',
            Priority__c = 'Critical',
            Status__c = 'New'
        );

        Test.startTest();
        insert request;
        Test.stopTest();

        Service_Request__c savedRequest = [
            SELECT Id, SLA_Due__c
            FROM Service_Request__c
            WHERE Id = :request.Id
        ];

        System.assertNotEquals(
            null,
            savedRequest.SLA_Due__c,
            'Critical request should have an SLA Due date.'
        );

        Long expectedSeconds = 4 * 60 * 60;

        Long actualSeconds =
            Math.abs(
                savedRequest.SLA_Due__c.getTime()
                - System.now().getTime()
            ) / 1000;

        System.assert(
            actualSeconds <= expectedSeconds + 10,
            'Critical SLA should be approximately 4 hours from now.'
        );
    }

    @IsTest
    static void testAllPrioritySlaValues() {

        List<Service_Request__c> requests =
            new List<Service_Request__c>();

        for (String priority : new List<String>{
            'Critical',
            'High',
            'Medium',
            'Low'
        }) {
            requests.add(
                new Service_Request__c(
                    Subject__c = priority + ' SLA Test',
                    Priority__c = priority,
                    Status__c = 'New'
                )
            );
        }

        Test.startTest();
        insert requests;
        Test.stopTest();

        List<Service_Request__c> savedRequests = [
            SELECT Id, Priority__c, SLA_Due__c
            FROM Service_Request__c
            WHERE Id IN :requests
        ];

        System.assertEquals(
            4,
            savedRequests.size(),
            'All four test requests should be inserted.'
        );

        for (Service_Request__c request : savedRequests) {

            System.assertNotEquals(
                null,
                request.SLA_Due__c,
                request.Priority__c +
                ' request should have an SLA Due date.'
            );
        }
    }
}