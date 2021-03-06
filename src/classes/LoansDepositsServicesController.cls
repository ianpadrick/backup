public class LoansDepositsServicesController {

    public List<LLC_BI__Legal_Entities__c> loans {get; private set;}
    public List<LLC_BI__Legal_Entities__c> deposits {get; private set;}
    public List<LLC_BI__Legal_Entities__c> services {get; private set;}
    private Id objId = null;

    public String newLoanLink {get; set;}
    public String newDepositLink {get; set;}
    public String newServiceLink {get; set;}
    
    //Constructor for the Standard Controller
    public LoansDepositsServicesController(ApexPages.StandardController controller) {
        this.objId = ApexPages.currentPage().getParameters().get('id');
        this.newLoanLink = 'https://llc-bi.na11.visual.force.com/apex/loanproducts';
        this.newDepositLink = 'https://llc-bi.na11.visual.force.com/apex/depositproducts';
        this.newServiceLink = 'https://na11.salesforce.com/a24/e';
        
        this.loans = [SELECT Id, LLC_BI__Loan__c, LLC_BI__Loan__r.Name, LLC_BI__Loan__r.LLC_BI__Product_Line__c, LLC_BI__Loan__r.LLC_BI__Product_Type__c, LLC_BI__Borrower_Type__c, LLC_BI__Loan__r.LLC_BI__lookupKey__c, LLC_BI__Loan__r.LLC_BI__Stage__c, LLC_BI__Loan__r.LLC_BI__Status__c, LLC_BI__Loan__r.LLC_BI__Product__c, LLC_BI__Loan__r.LLC_BI__Amount__c, LLC_BI__Loan__r.LLC_BI__Principal_Balance__c, LLC_BI__Loan__r.LLC_BI__InterestRate__c, LLC_BI__Loan__r.LLC_BI__Loan_Officer__r.Name, LLC_BI__Loan__r.LLC_BI__Maturity_Date__c FROM LLC_BI__Legal_Entities__c WHERE LLC_BI__Account__r.Id =: objId AND LLC_BI__Loan__c != null ORDER BY LLC_BI__Loan__r.LLC_BI__Stage__c];
        this.deposits = [SELECT Id, LLC_BI__Deposit__c, LLC_BI__Deposit__r.Name, LLC_BI__Deposit__r.LLC_BI__Product_Type__c, LLC_BI__Deposit__r.LLC_BI__Open_Date__c, LLC_BI__Deposit__r.LLC_BI__Initial_Deposit__c, LLC_BI__Deposit__r.LLC_BI__Amount__c, LLC_BI__Deposit__r.LLC_BI__Interest_Rate__c, LLC_BI__Deposit__r.LLC_BI__Maturity_Date__c, LLC_BI__Deposit__r.Account_Ledger_Balance__c, LLC_BI__Deposit__r.YTD_Ledger_Balance__c FROM LLC_BI__Legal_Entities__c  WHERE LLC_BI__Account__r.Id =: objId AND LLC_BI__Deposit__c != null ORDER BY LLC_BI__Deposit__r.LLC_BI__Open_Date__c];
        this.services = [SELECT Id, LLC_SM__Service__r.LLC_SM__Existing_Daily_Limit__c, LLC_SM__Service__c, LLC_SM__Service__r.Name, LLC_SM__Service__r.LLC_SM__Product_Line__c, LLC_SM__Service__r.LLC_SM__Product_Type__c, LLC_SM__Service__r.LLC_SM__Product__c, LLC_SM__Service__r.LLC_SM__lookupKey__c, LLC_SM__Service__r.LLC_SM__Stage__c, LLC_SM__Service__r.LLC_SM__Status__c FROM LLC_BI__Legal_Entities__c WHERE LLC_BI__Account__r.Id =: objId AND LLC_SM__Service__c != null ORDER BY LLC_SM__Service__r.LLC_SM__Stage__c];
    }
}
