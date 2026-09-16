trigger ServiceRequestTrigger
on Service_Request__c (
    before insert,
    before update
) {

    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            ServiceRequestTriggerHandler.beforeInsert(
                Trigger.new
            );
        }

        if (Trigger.isUpdate) {
            ServiceRequestTriggerHandler.beforeUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }
    }
}