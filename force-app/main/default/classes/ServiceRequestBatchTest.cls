@IsTest
private class ServiceRequestBatchTest {

    @IsTest
    static void testOverdueRequestsAreEscalated() {

        DateTime pastDue = System.now().addDays(-1);
        DateTime futureDue = System.now().addDays(1);

        Service_Request__c overdueRequest =
            new Service_Request__c(
                Subject__c = 'Overdue Batch Test',
                Priority__c = 'High',
                Status__c = 'In Progress',
                Is_Escalated__c = false
            );

        Service_Request__c futureRequest =
            new Service_Request__c(
                Subject__c = 'Future Batch Test',
                Priority__c = 'Medium',
                Status__c = 'In Progress',
                Is_Escalated__c = false
            );

        Service_Request__c closedRequest =
            new Service_Request__c(
                Subject__c = 'Closed Batch Test',
                Priority__c = 'High',
                Status__c = 'Closed',
                Is_Escalated__c = false
            );

        insert new List<Service_Request__c>{
            overdueRequest,
            futureRequest,
            closedRequest
        };

        // Set SLA dates after insert so the before-update
        // handler does not recalculate them because
        // Priority__c has not changed.
        overdueRequest.SLA_Due__c = pastDue;
        futureRequest.SLA_Due__c = futureDue;
        closedRequest.SLA_Due__c = pastDue;

        update new List<Service_Request__c>{
            overdueRequest,
            futureRequest,
            closedRequest
        };

        Test.startTest();

        Database.executeBatch(
            new ServiceRequestBatch(),
            100
        );

        Test.stopTest();

        Map<Id, Service_Request__c> results =
            new Map<Id, Service_Request__c>([
                SELECT
                    Id,
                    Status__c,
                    SLA_Due__c,
                    Is_Escalated__c
                FROM Service_Request__c
                WHERE Id IN :new Set<Id>{
                    overdueRequest.Id,
                    futureRequest.Id,
                    closedRequest.Id
                }
            ]);

        System.assertEquals(
            true,
            results.get(overdueRequest.Id).Is_Escalated__c,
            'Overdue open request should be escalated.'
        );

        System.assertEquals(
            false,
            results.get(futureRequest.Id).Is_Escalated__c,
            'Future SLA request should not be escalated.'
        );

        System.assertEquals(
            false,
            results.get(closedRequest.Id).Is_Escalated__c,
            'Closed request should not be processed by the batch.'
        );
    }
}