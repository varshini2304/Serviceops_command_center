global class ServiceRequestScheduler
    implements Schedulable {

    global void execute(
        SchedulableContext context
    ) {
        Database.executeBatch(
            new ServiceRequestBatch(),
            100
        );
    }
}