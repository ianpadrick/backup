public class OpportunityTriggerHandler {
    
    public static void onBeforeInsert(List<Opportunity> recs) {
        for (Opportunity o : recs) {
            if (o.StageName == 'Test') {
                //WinningAccChecker checker = new WinningAccChecker(accs);
                //checker.checkWinningAccs();
            }
        }
    }
    
    public static void onBeforeUpdate(Map<Id, Opportunity> oldRecs, Map<Id, Opportunity> newRecs) {
        //WinningAccChecker checker = new WinningAccChecker(oldAccs, newAccs);
        //checker.checkWinningAccs();
    }

    public static void onBeforeDelete(List<Opportunity> recs) {
        //WinningAccChecker checker = new WinningAccChecker(accs);
        //checker.checkWinningAccs();
    }

    public static void onAfterInsert(List<Opportunity> recs) {
        //WinningAccChecker checker = new WinningAccChecker(accs);
        //checker.checkWinningAccs();
    }
    
    public static void onAfterUpdate(Map<Id, Opportunity> oldRecs, Map<Id, Opportunity> newRecs) {
        Map<Id, Opportunity> o = oldRecs;
        for (Opportunity n : newRecs.values()) {
            Opportunity old = o.get(n.Id);
            if (n.StageName != old.StageName) {
                OpportunityHistoryCreatorTriggerHandler controller = new OpportunityHistoryCreatorTriggerHandler();
                controller.createHistories(n.Id, old.StageName, n.StageName);
            }
        }
    }

    public static void onAfterDelete(List<Opportunity> recs) {
        //WinningAccChecker checker = new WinningAccChecker(accs);
        //checker.checkWinningAccs();
    }
}