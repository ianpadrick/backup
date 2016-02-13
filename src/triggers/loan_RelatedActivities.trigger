Trigger loan_RelatedActivities on LLC_BI__Loan__c (after update) {

    Set<Id> loanIds = new Set<Id>();
    for (Integer i = 0 ; i < trigger.new.size(); i++) {
        if (trigger.isUpdate && (trigger.new[i].Update_Activity_History__c == true )) {
            loanIds.add(trigger.new[i].Id);
        }
    }
    
    List<LLC_BI__Loan__c> loanList = 
        [
            SELECT 
                Id,
                Update_Activity_History__c,	
                (
                    SELECT 
                        CreatedDate,
                        Subject,
                        CreatedBy.Name
                    FROM 
                        ActivityHistories
                    ORDER BY
                        CreatedDate LIMIT 5
                ) 
                FROM 
                    LLC_BI__Loan__c 
                WHERE 
                    Id
                IN 
                    :loanIds
        ];

    for (LLC_BI__Loan__c loan : loanList) {
        String activityNotes = '';
        if (loan.Update_Activity_History__c != false) {
            for (ActivityHistory memo : loan.ActivityHistories) {
            	DateTime dT = memo.CreatedDate;
				Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
				String sDate = String.ValueOf(myDate);
                if (sDate != null && memo.Subject != null && memo.CreatedBy.Name != null) {
                    activityNotes = activityNotes + sDate + ' - ' + memo.Subject + ' - ' + memo.CreatedBy.Name + '\n';
                }

            	loan.Activity_History_Notes__c = activityNotes;
            	loan.Update_Activity_History__c = false;
            }
        }
    }

    update loanList;
}
