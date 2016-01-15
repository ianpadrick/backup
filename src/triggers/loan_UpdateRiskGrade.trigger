Trigger loan_UpdateRiskGrade on LLC_BI__Annual_Review__c (after update) {
  
  for (LLC_BI__Annual_Review__c ar : Trigger.new) {
    if (ar.FinalRiskGradeCalc__c != null) {
      LLC_BI__Loan__c loan = new LLC_BI__Loan__c(Id = ar.LLC_BI__Loan__c);
        loan.Risk_Grade__c = ar.FinalRiskGradeCalc__c;
    
    upsert loan;
    }
  }
}
