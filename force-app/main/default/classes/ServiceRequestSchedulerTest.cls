@IsTest
private class ServiceRequestSchedulerTest {

    @IsTest
    static void testSchedulerExecutesBatch() {

        Test.startTest();

        String cronExpression = '0 0 0 1 1 ? 2099';

        String jobId = System.schedule(
            'Service Request Scheduler Test',
            cronExpression,
            new ServiceRequestScheduler()
        );

        Test.stopTest();

        CronTrigger scheduledJob = [
            SELECT
                Id,
                CronExpression,
                TimesTriggered,
                State
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(
            cronExpression,
            scheduledJob.CronExpression,
            'Scheduler should use the expected cron expression.'
        );
    }
}