Trigger loan_PendingFacility on LLC_BI__Loan__c (after insert, after update) {
    
    private static final String STAGE = 'Pending Work Package Approval';
    Set<Id> loanIds = new Set<Id>();
    
    for (Integer i = 0 ; i < trigger.new.size(); i++) {
        if ((trigger.isUpdate && (trigger.new[i].LLC_BI__Stage__c != trigger.old[i].LLC_BI__Stage__c)) ||
            (trigger.isInsert)) 
        {
            loanIds.add(trigger.new[i].LLC_CDS__Deal_Facility__c);
        }
    }
    
    List<LLC_CDS__Deal_Facility__c> loanList = 
        [
            SELECT 
                Id, 
                Name, 
                Facility_Pending_Review__c, 
                (
                    SELECT 
                        Id, 
                        LLC_BI__Stage__c 
                    FROM 
                        LLC_CDS__Loan_Facilities__r
                ) 
                FROM 
                    LLC_CDS__Deal_Facility__c 
                WHERE 
                    Id 
                IN 
                    :loanIds
        ];

    for (LLC_CDS__Deal_Facility__c loan : loanList) {
        Boolean criteriaValue = false;
        for (LLC_BI__Loan__c memo : loan.LLC_CDS__Loan_Facilities__r) {
            if ((criteriaValue != true) && (memo.LLC_BI__Stage__c != STAGE)) {
                criteriaValue = true;
            }
        }
        loan.Facility_Pending_Review__c = criteriaValue;
    }

    update loanList;
    
}
