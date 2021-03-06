@isTest
private class Relationship360ViewControllerTest {

  @isTest
    static void myUnitTest() {
        Account newAccount = new Account(name = 'Test Account 123', Relationship_Code__c='RC12378');
        insert newAccount;
    Account newAccount2 = new Account(name = 'Test Account 456', Relationship_Code__c='RC12378');
        insert newAccount2;    
    
   LLC_BI__Loan__c newLoan = new LLC_BI__Loan__c(name='Test Loan', LLC_BI__Account__c=newAccount.Id);
        insert newLoan;
   LLC_BI__Loan__c newLoan2 = new LLC_BI__Loan__c(name='Test Loan2', LLC_BI__Account__c=newAccount2.Id);
        insert newLoan2;
        
   LLC_BI__Deposit__c newDeposit = new LLC_BI__Deposit__c(Name='Test Deposit', LLC_BI__Account__c= newAccount.Id);
        insert newDeposit;
   LLC_BI__Deposit__c newDeposit2 = new LLC_BI__Deposit__c(Name='Test Deposit2', LLC_BI__Account__c= newAccount2.Id);
        insert newDeposit2;
    
   ApexPages.standardController controller = new ApexPages.standardController(newAccount);
   ApexPages.currentPage().getParameters().put('id', newAccount.Id);
   Relationship360View rel360View = new Relationship360View(controller); 
  
 
             List<LLC_BI__Deposit__c> Deposits = rel360View.getDeposits();
              system.assertEquals(2,Deposits.size());
 
             List<LLC_BI__Loan__C> Loans = rel360View.getLoans();
              system.assertEquals(2,Loans.size());
             
             List<Account> Accounts = rel360View.getAccounts();    
              system.assertEquals(2,Accounts.size());
              
             rel360View.getResults();
             rel360View.getResults2();
             rel360View.getResults3();
 }   
}
