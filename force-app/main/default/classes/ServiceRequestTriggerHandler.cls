public with sharing class ServiceRequestTriggerHandler {

    public static void beforeInsert(
        List<Service_Request__c> requests
    ) {
        ServiceRequestService.calculateSla(requests);
    }

    public static void beforeUpdate(
        List<Service_Request__c> requests,
        Map<Id, Service_Request__c> oldMap
    ) {
        List<Service_Request__c> priorityChangedRequests =
            new List<Service_Request__c>();

        for (Service_Request__c request : requests) {

            Service_Request__c oldRequest =
                oldMap.get(request.Id);

            if (
                request.Priority__c != oldRequest.Priority__c
            ) {
                priorityChangedRequests.add(request);
            }
        }

        if (!priorityChangedRequests.isEmpty()) {
            ServiceRequestService.calculateSla(
                priorityChangedRequests
            );
        }
    }
}