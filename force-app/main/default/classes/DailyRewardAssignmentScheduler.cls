public class DailyRewardAssignmentScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        System.debug('⚙️ Running daily reward assignment...');
        RewardAssignmentJobHandler.executeJob();
    }
}
