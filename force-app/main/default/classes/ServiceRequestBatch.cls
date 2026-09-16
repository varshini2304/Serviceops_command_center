global with sharing class ServiceRequestBatch
    implements Database.Batchable<SObject> {

    global Database.QueryLocator start(
        Database.BatchableContext bc
    ) {

        return Database.getQueryLocator([
            SELECT
                Id,
                Status__c,
                Priority__c,
                SLA_Due__c,
                Is_Escalated__c
            FROM Service_Request__c
            WHERE Status__c != 'Closed'
        ]);
    }

    global void execute(
        Database.BatchableContext bc,
        List<Service_Request__c> scope
    ) {

        for (Service_Request__c request : scope) {

            if (
                request.SLA_Due__c != null &&
                request.SLA_Due__c < System.now()
            ) {
                request.Is_Escalated__c = true;
            }
        }

        if (!scope.isEmpty()) {
            update scope;
        }
    }

    global void finish(
        Database.BatchableContext bc
    ) {
        System.debug(
            'Service Request Batch Completed'
        );
    }
}