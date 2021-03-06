trigger loan_UpdateBranch on LLC_BI__Loan__c (after insert, after update) {
    
  Set<Id> loanIds = new Set<Id>();
  
  for (Integer i = 0 ; i < trigger.new.size(); i++) {
    if ((trigger.isUpdate && (trigger.new[i].LLC_BI__Loan_Officer__c != trigger.old[i].LLC_BI__Loan_Officer__c)) || (trigger.isInsert)) {
      loanIds.add(trigger.new[i].Id);
    }
  }
  
  List<LLC_BI__Loan__c> loanList = 
    [
      SELECT 
        Id,
        LLC_BI__Loan_Officer__c,
        LLC_BI__Branch__c,
        LLC_BI__Loan_Officer__r.Branch_ID__c
     FROM 
        LLC_BI__Loan__c 
      WHERE 
        Id 
      IN : loanIds
    ];

  for (LLC_BI__Loan__c loan : loanList) {
    if ((loan.LLC_BI__Loan_Officer__c != null) && (loan.LLC_BI__Loan_Officer__r.Branch_ID__c != null)) {
      loan.LLC_BI__Branch__c = loan.LLC_BI__Loan_Officer__r.Branch_ID__c;
    }
  }

  update loanList;
}
