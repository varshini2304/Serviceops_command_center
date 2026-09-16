public with sharing class ServiceRequestQueueable
    implements Queueable {

    private Set<Id> requestIds;

    public ServiceRequestQueueable(Set<Id> requestIds) {
        this.requestIds = requestIds;
    }

    public void execute(QueueableContext context) {

        List<Service_Request__c> requests = [
            SELECT
                Id,
                Priority__c,
                Status__c,
                Is_Escalated__c
            FROM Service_Request__c
            WHERE Id IN :requestIds
        ];

        for (Service_Request__c request : requests) {

            if (
                request.Priority__c == 'Critical' ||
                request.Priority__c == 'High'
            ) {
                request.Is_Escalated__c = true;
            }
        }

        if (!requests.isEmpty()) {
            update requests;
        }
    }
}