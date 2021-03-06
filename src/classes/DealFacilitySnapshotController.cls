public class DealFacilitySnapshotController {

    public List<LLC_CDS__Deal_Facility__c> info {get; private set;}
    public List<LLC_BI__Loan__c> facilities  {get; private set;}
    public List<Participation_Syndication__c> participations {get; private set;}
    public Decimal totalFacAmt {get; set;}
    public Decimal totalBalanceAmt {get; set;}
    public Decimal totalNewMoneyAmt {get; set;}
    private Id objId = null;
    
    //Constructor for the Standard Controller
    public DealFacilitySnapshotController(ApexPages.StandardController controller) {
        this.objId = ApexPages.currentPage().getParameters().get('id');
        
        this.info = [SELECT Id, Name, LLC_CDS__Description__c FROM LLC_CDS__Deal_Facility__c WHERE Id =: objId limit 1];
        this.facilities = [SELECT Id, Name, LLC_BI__Stage__c, LLC_BI__Loan_Class__c, LLC_BI__Product__c, LLC_BI__InterestRate__c, LLC_BI__Amount__c, LLC_BI__Principal_Balance__c, New_Money__c, LLC_BI__CloseDate__c FROM LLC_BI__Loan__c WHERE LLC_CDS__Deal_Facility__c =: objId];
        this.participations = [SELECT Id, Name, Request_Id__c, Bank__c, Acting_As__c, Participation_Amount__c, SNC__c, Special_Instructions__c FROM Participation_Syndication__c WHERE Request_Id__c IN : this.facilities];
        
        totalFacAmt = 0;
        totalBalanceAmt = 0;
        totalNewMoneyAmt = 0;
        for (LLC_BI__Loan__c fac : this.facilities) {
            if (fac.LLC_BI__Amount__c != null) {
                totalFacAmt += fac.LLC_BI__Amount__c;
            }

            if (fac.LLC_BI__Principal_Balance__c != null) {
                totalBalanceAmt += fac.LLC_BI__Principal_Balance__c;
            }

            if (fac.New_Money__c != null) {
                totalNewMoneyAmt += fac.New_Money__c;
            }
        }
    }      
}
