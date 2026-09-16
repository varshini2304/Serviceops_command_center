public with sharing class ServiceRequestService {

    public static void calculateSla(
        List<Service_Request__c> requests
    ) {
        for (Service_Request__c request : requests) {

            if (request.Priority__c == 'Critical') {
                request.SLA_Due__c =
                    System.now().addHours(4);

            } else if (request.Priority__c == 'High') {
                request.SLA_Due__c =
                    System.now().addHours(8);

            } else if (request.Priority__c == 'Medium') {
                request.SLA_Due__c =
                    System.now().addHours(24);

            } else if (request.Priority__c == 'Low') {
                request.SLA_Due__c =
                    System.now().addHours(48);
            }
        }
    }
}