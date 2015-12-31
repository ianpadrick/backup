public class ClientSnapshotClass {
    /* This class is amazing */
    public List<Account> info {get; private set;}
    public List<Account> address {get; private set;}
    public List<Account> relCovs {get; private set;}
    public List<Relationship_Covenant_Compliance__c> compliances {get; private set;}
    public List<Relationship_Covenants__c> covenants {get; private set;}
    public List<Aggregation_Tracking__c> aggregations {get; private set;}
    public List<Guarantor_Relationships__c> guarantors {get; private set;}
    public List<Guarantor_Relationships__c> guarantees {get; private set;}
    public List<LLC_BI__Loan__c> deals {get; private set;}
    public List<LLC_BI__Loan__c> facilities {get; private set;}
    public List<LLC_BI__Loan__c> balances {get; private set;}
    public List<LLC_BI__Loan__c> aBL {get; private set;}
    public List<LLC_BI__Deposit__c> deposits {get; private set;}
    public List<Participation_Tracking__c> participations {get; private set;}
    public String accountId {get; private set;}
    public Date Today { get; private set;}
    
    public Decimal ABL_Total_Commitment {get; private set;}
    public Decimal ABL_Total_Out {get; private set;}
    public Decimal ABL_Total_Avail {get; private set;}
    public Decimal Dep_Total_Bal {get; private set;}
    public Decimal Agg_Total {get; private set;}
    public Decimal Ptp_Total {get; private set;}
    public Decimal Ptp_Fac_Total {get; private set;}
    public Decimal Fac_Comm_Total {get;private set;}
    public Decimal Fac_Out_Total {get;private set;}
    public Decimal Deal_Total {get;private set;}
    public Decimal Deal_Disp_Total {get;private set;}
    public Decimal Loan_Total {get;private set;}
    
    private Id objId = null;
    
    //Constructor for the Standard Controller
    public ClientSnapshotClass(ApexPages.StandardController controller) {
        this.Today = Date.today();
        this.objId = ApexPages.currentPage().getParameters().get('id');
        this.accountId = this.objId;
        
        this.info = [SELECT Id, Portfolio__c, LLC_BI__Tax_Identification_Number__c, LOOKUP_REGION__c, LOOKUP_REGION__r.Name, LLC_Branch__c, LLC_Branch__r.Name, Owner.Name FROM Account WHERE Id =: objId limit 1];
        this.address = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE Id =: objId limit 1];
        this.relCovs = [SELECT Id, CreatedDate, Rel_Cov_Financial_In_Compliance__c, Rel_Cov_Reporting_In_Compliance__c FROM Account WHERE Id =: objId limit 1];
        this.compliances = [SELECT Id, CreatedDate FROM Relationship_Covenant_Compliance__c WHERE Relationship_Covenant__r.Relationship__c =: objId];
        this.covenants = [SELECT Id, Name, Covenant_Complies__c, Covenant_Type__c FROM Relationship_Covenants__c WHERE Relationship__c =: objId];
        this.aggregations = [SELECT Id,  Account__c, Account__r.Id, Account__r.Name, Aggregated_Party__c, Portfolio_Number__c, Total_Aggregated_Amount__c, Total_Committed__c FROM Aggregation_Tracking__c WHERE Account__c =: objId];
        this.guarantors = [SELECT Id, Guarantor_Account__c, Guarantor_Account__r.Id, Guarantor_Account__r.Name, Guarantor_Portfolio__c FROM Guarantor_Relationships__c WHERE Guarantee_Account__c =: objId];
        this.guarantees = [SELECT Id, Guarantee_Account__c, Guarantee_Account__r.Id, Guarantee_Account__r.Name, Guarantee_Portfolio__c FROM Guarantor_Relationships__c WHERE Guarantor_Account__c =: objId];
        this.deals = [SELECT Id, LLC_BI__Total_Disbursed__c, Facility_Status__c, ACBS_Facility__c, Loan_Type__c, LLC_BI__Amount__c, LLC_BI__Account__c, LLC_BI__Principal_Balance__c, LLC_BI__Status__c FROM  LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Extract__c != 'Stucky' AND LLC_BI__Status__c = 'Open' AND Loan_Type__c = 'Deal'];
        this.facilities = [SELECT Id, LLC_BI__Status__c, LLC_BI__Total_Disbursed__c, LLC_BI__Product__c, Section__c, Limit_Type__c, LLC_BI__Description__c, LLC_BI__Amount__c, LLC_BI__Principal_Balance__c, Facility_Status__c, LastModifiedDate, LLC_BI__CloseDate__c, ACBS_Facility__c FROM LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Loan_Type__c = 'Facility' AND LLC_BI__Status__c = 'Open' AND Extract__c != 'Stucky' ORDER BY LLC_BI__Status__c Desc];
        this.balances = [SELECT Id, Product_Group__c, Booked_Boarded_Date__c, VB_Risk_Grade__c, CreatedDate, LastModifiedDate, LLC_BI__Status__c, ACBS_Facility__c, ACBS_Loan__c, LLC_BI__CloseDate__c, LLC_BI__Total_Disbursed__c, LLC_BI__Maturity_Date__c FROM LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Extract__c != 'Stucky' AND LLC_BI__Status__c = 'Open' AND Loan_Type__c = 'Facility'];
        this.aBL = [SELECT Id, Stucky_Loan_Number__c, LLC_BI__Product__c, LLC_BI__Status__c, LLC_BI__Maturity_Date__c, LLC_BI__Amount__c, LLC_BI__AmountOutstanding__c, Stucky_Loan_Availability__c, LastModifiedDate FROM LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Extract__c = 'Stucky' AND LLC_BI__Status__c = 'Open'];
        this.deposits = [SELECT LLC_BI__Open_Date__c, As_Of__c, LLC_BI__Account__c, LLC_BI__Account__r.Name, Account_Number__c, LLC_BI__Product__c, Current_Balance__c, LLC_BI__Interest_Rate__c, CreatedDate, LastModifiedDate FROM LLC_BI__Deposit__c WHERE LLC_BI__Account__c =: objId];
        this.participations = [SELECT Account__c, Account__r.Name, Bank_Percentage__c, Participant__c, Participation_Amount__c, Portfolio_Number__c, Total_Facility_Size__c FROM Participation_Tracking__c WHERE Account__c =: objId];

    // Aggregation totals
    Agg_Total = 0.00;
        for(Aggregation_Tracking__c a:this.aggregations){
            Agg_Total += checkForNull(a.Total_Aggregated_Amount__c);
        }
        
        // Deal totals
        Deal_Total = 0.00;
        Deal_Disp_Total = 0.00;
        for(LLC_BI__Loan__c d:this.deals){
            Deal_Total += checkForNull(d.LLC_BI__Amount__c);
            Deal_Disp_Total += checkForNull(d.LLC_BI__Total_Disbursed__c);
        }
        
        // Facility totals
        Fac_Comm_Total = 0.00;
        Fac_Out_Total = 0.00;
        for(LLC_BI__Loan__c df:this.facilities){
            Fac_Comm_Total += checkForNull(df.LLC_BI__Amount__c);
            Fac_Out_Total += checkForNull(df.LLC_BI__Total_Disbursed__c);
        }
        
        Loan_Total = 0.00;
        for(LLC_BI__Loan__c l:this.balances){
            Loan_Total += checkForNull(l.LLC_BI__Total_Disbursed__c);
        }
        
        // SFG Loan Balances totals
        ABL_Total_Commitment = 0.00;
        ABL_Total_Out = 0.00;
        ABL_Total_Avail = 0.00;
        for(LLC_BI__Loan__c l:this.aBL){
            ABL_Total_Commitment+= checkForNull(l.LLC_BI__Amount__c);
            ABL_Total_Out += checkForNull(l.LLC_BI__AmountOutstanding__c);
            ABL_Total_Avail += checkForNull(l.Stucky_Loan_Availability__c);
        }
        
        // Deposit Totals
        Dep_Total_Bal = 0.00;
        for(LLC_BI__Deposit__c d:this.deposits){
            Dep_Total_Bal += checkForNull(d.Current_Balance__c);
        }
        
        // Participation Totals 
        Ptp_Total = 0.00;
        Ptp_Fac_Total = 0.00;
        for(Participation_Tracking__c pt:this.participations){
            Ptp_Total += checkForNull(pt.Participation_Amount__c);
          Ptp_Fac_Total += checkForNull(pt.Total_Facility_Size__c);
        }
    }
    
    private Decimal checkForNull(Decimal val){
        if(val == null) return 0.00; 
        return val;
    }
    
/*
    public Date Today { get { return Date.today(); }}
    //Set Id of current Account
    Id objId = ApexPages.currentPage().getParameters().get('id');

        //Find General Info for Account
        public List<Account> getInfo() {

            List<Account> info = [SELECT Id, Portfolio__c, LLC_BI__Tax_Identification_Number__c, LOOKUP_REGION__c, LOOKUP_REGION__r.Name, LLC_Branch__c, LLC_Branch__r.Name, Owner.Name FROM Account WHERE Id =: objId limit 1];
            return info;     
        }

        //Find Address for Account
        public List<Account> getAddress() {

            List<Account> address = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE Id =: objId limit 1];
            return address;     
        }

        //Find Relationship Covenant fields for Account
        public List<Account> getRelCovs() {

            List<Account> relcovs = [SELECT Id, CreatedDate, Rel_Cov_Financial_In_Compliance__c, Rel_Cov_Reporting_In_Compliance__c FROM Account WHERE Id =: objId limit 1];
            return relcovs;     
        }
        
        //Find Relationship Covenant Compliance Records for Account
        public List<Relationship_Covenant_Compliance__c> getCompliances() {

            List<Relationship_Covenant_Compliance__c> compliances = [SELECT Id, CreatedDate FROM Relationship_Covenant_Compliance__c WHERE Relationship_Covenant__r.Relationship__c =: objId];
            return compliances;     
        }

        //Find Relationship Covenant Records for Account
        public List<Relationship_Covenants__c> getCovenants() {

            List<Relationship_Covenants__c> covenants = [SELECT Id, Name, Covenant_Complies__c, Covenant_Type__c FROM Relationship_Covenants__c WHERE Relationship__c =: objId];
            return covenants;
        }
        
        //Find Aggregation Records for Account
        public List<Aggregation_Tracking__c> getAggregations() {

            List<Aggregation_Tracking__c> aggregation = [SELECT Id,  Account__c, Account__r.Id, Account__r.Name, Aggregated_Party__c, Portfolio_Number__c, Total_Aggregated_Amount__c, Total_Committed__c FROM Aggregation_Tracking__c WHERE Account__c =: objId];
            return aggregation;
        }
        
        //Find Guarantor records for Account
        public List<Guarantor_Relationships__c> getGuarantors() {

            List<Guarantor_Relationships__c> guarantors = [SELECT Id, Guarantor_Account__c, Guarantor_Account__r.Id, Guarantor_Account__r.Name, Guarantor_Portfolio__c FROM Guarantor_Relationships__c WHERE Guarantee_Account__c =: objId];
            return guarantors ;     
        }
        
        //Find Gurantee records for Account
        public List<Guarantor_Relationships__c> getGuarantees() {

            List<Guarantor_Relationships__c> guarantees = [SELECT Id, Guarantee_Account__c, Guarantee_Account__r.Id, Guarantee_Account__r.Name, Guarantee_Portfolio__c FROM Guarantor_Relationships__c WHERE Guarantor_Account__c =: objId];
            return guarantees;     
        }
        
        //Find Loan records for Account where Loan Type = Deal 
        public List<LLC_BI__Loan__c> getDeals() {

            List<LLC_BI__Loan__c> deals = [SELECT Id, LLC_BI__Total_Disbursed__c, Facility_Status__c, ACBS_Facility__c, Loan_Type__c, LLC_BI__Amount__c, LLC_BI__Account__c, LLC_BI__Principal_Balance__c, LLC_BI__Status__c FROM  LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Extract__c != 'Stucky' AND LLC_BI__Status__c = 'Open' AND Loan_Type__c = 'Deal'];
            return deals;     
        }
        
        //Find Loan records for Account where Loan Type = Facility
        public List<LLC_BI__Loan__c> getFacilities() {       
        
            List<LLC_BI__Loan__c> facilities = [SELECT Id, LLC_BI__Status__c, LLC_BI__Total_Disbursed__c, LLC_BI__Product__c, Section__c, Limit_Type__c, LLC_BI__Description__c, LLC_BI__Amount__c, LLC_BI__Principal_Balance__c, Facility_Status__c, LastModifiedDate, LLC_BI__CloseDate__c, ACBS_Facility__c FROM LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Loan_Type__c = 'Facility' AND LLC_BI__Status__c = 'Open' AND Extract__c != 'Stucky' ORDER BY LLC_BI__Status__c Desc];
            return facilities;    
            // Sort by Status - Open first, Boarded next 
        }

        //Find Loan Disbursement records for Account
        public List<LLC_BI__Loan__c> getBalances() {       
        
            List<LLC_BI__Loan__c> balances = [SELECT Id, Product_Group__c, Booked_Boarded_Date__c, VB_Risk_Grade__c, CreatedDate, LastModifiedDate, LLC_BI__Status__c, ACBS_Facility__c, ACBS_Loan__c, LLC_BI__CloseDate__c, LLC_BI__Total_Disbursed__c, LLC_BI__Maturity_Date__c FROM LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Extract__c != 'Stucky' AND LLC_BI__Status__c = 'Open' AND Loan_Type__c = 'Facility'];
            return balances;     
        }

        public List<LLC_BI__Loan__c> getABL() {
            List<LLC_BI__Loan__c> abl = [SELECT Id, Stucky_Loan_Number__c, LLC_BI__Product__c, LLC_BI__Status__c, LLC_BI__Maturity_Date__c, LLC_BI__Amount__c, LLC_BI__AmountOutstanding__c, Stucky_Loan_Availability__c, LastModifiedDate FROM LLC_BI__Loan__c WHERE LLC_BI__Account__c =: objId AND Extract__c = 'Stucky' AND LLC_BI__Status__c = 'Open'];
            return abl;
        }

        //Find Deposits records for Account
        public List<LLC_BI__Deposit__c> getDeposits() {

            List<LLC_BI__Deposit__c> deposits = [SELECT LLC_BI__Open_Date__c, As_Of__c, LLC_BI__Account__c, LLC_BI__Account__r.Name, Account_Number__c, LLC_BI__Product__c, Current_Balance__c, LLC_BI__Interest_Rate__c, CreatedDate, LastModifiedDate FROM LLC_BI__Deposit__c WHERE LLC_BI__Account__c =: objId];
            return deposits;     
        }

        //Find Participation records for Account
        public List<Participation_Tracking__c> getParticipations() {

            List<Participation_Tracking__c> participations = [SELECT Account__c, Account__r.Name, Bank_Percentage__c, Participant__c, Participation_Amount__c, Portfolio_Number__c, Total_Facility_Size__c FROM Participation_Tracking__c WHERE Account__c =: objId];
            return participations;     
        }
*/        
}
