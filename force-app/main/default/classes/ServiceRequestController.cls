public with sharing class ServiceRequestController {

    @AuraEnabled(cacheable=true)
    public static List<Service_Request__c> getRequests() {

        return [
            SELECT
                Id,
                Name,
                Subject__c,
                Description__c,
                Status__c,
                Priority__c,
                Category__c,
                SLA_Due__c,
                Resolved_Date__c,
                Is_Escalated__c,
                Account__r.Name,
                Contact__r.Name,
                Assigned_To__r.Name
            FROM Service_Request__c
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Service_Request__c> searchRequests(
        String searchTerm
    ) {

        if (String.isBlank(searchTerm)) {
            return new List<Service_Request__c>();
        }

        String searchPattern =
            '*' + String.escapeSingleQuotes(searchTerm) + '*';

        List<List<SObject>> searchResults = [
            FIND :searchPattern
            IN ALL FIELDS
            RETURNING Service_Request__c(
                Id,
                Name,
                Subject__c,
                Status__c,
                Priority__c,
                Category__c
                LIMIT 50
            )
        ];

        return (List<Service_Request__c>)
            searchResults[0];
    }
}