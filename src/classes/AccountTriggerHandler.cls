public class AccountTriggerHandler {
    
    public static void onBeforeInsert(List<Account> accs) {
        for (Account a : accs) {
            if (a.Type == 'Participating Lender') {
                //WinningAccChecker checker = new WinningAccChecker(accs);
                //checker.checkWinningAccs();
            }
        }
    }
    
    public static void onBeforeUpdate(Map<Id, Account> oldAccs, Map<Id, Account> newAccs) {
        //WinningAccChecker checker = new WinningAccChecker(oldAccs, newAccs);
        //checker.checkWinningAccs();
    }

    public static void onBeforeDelete(List<Account> accs) {
        //WinningAccChecker checker = new WinningAccChecker(accs);
        //checker.checkWinningAccs();
    }

    public static void onAfterInsert(List<Account> accs) {
        //WinningAccChecker checker = new WinningAccChecker(accs);
        //checker.checkWinningAccs();
    }
    
    public static void onAfterUpdate(Map<Id, Account> oldAccs, Map<Id, Account> newAccs) {
        //WinningAccChecker checker = new WinningAccChecker(oldAccs, newAccs);
        //checker.checkWinningAccs();
    }

    public static void onAfterDelete(List<Account> accs) {
        //WinningAccChecker checker = new WinningAccChecker(accs);
        //checker.checkWinningAccs();
    }
}