public class VCFirmSnapshot{
    public List<VCRelatedAccount> borrowers {get; private set;}
    public List<VCRelatedAccount> depositors {get; private set;}
    public List<VCRelatedAccount> pipelineBorrowers {get; private set;}
    public List<VCRelatedAccount> pipelineNonBorrowers {get; private set;}
    public List<VCRelatedAccount> lostLoans {get; private set;}
    public List<VCRelatedAccount> lostDeposits {get; private set;}
    public List<nRE__Referral__c> referrals {get; private set;}
    public Decimal borrowerTotalCommitments {get; private set;}
    public Decimal borrowerTotalOutstandings {get; private set;}
    public Decimal borrowerTotalDeposits {get; private set;}
    public Decimal borrowerTotalReserves {get; private set;}
    public Decimal depositorTotalDeposits {get; private set;}
    public String accountId {get; private set;}
    
    private final Account account;
    private Map<Id, Fund_Investment__c> investmentMap;
    private List<Account> fundAccounts;
    private List<VC_Partner__c> VCPartners;
    private List<Account> relatedAccounts;
    private Set<Id> relatedAccountIds;

    public VCFirmSnapshot(ApexPages.StandardController controller) {
        this.account = (Account)controller.getRecord();
        this.accountId = this.account.Id;
        this.borrowers = new List<VCRelatedAccount>();
        this.depositors = new List<VCRelatedAccount>();
        this.pipelineBorrowers = new List<VCRelatedAccount>();
        this.pipelineNonBorrowers = new List<VCRelatedAccount>();
        this.lostLoans = new List<VCRelatedAccount>();
        this.lostDeposits = new List<VCRelatedAccount>();
        this.referrals = new List<nRE__Referral__c>();
        this.borrowerTotalCommitments = 0;
        this.borrowerTotalOutstandings = 0;
        this.borrowerTotalDeposits = 0;
        this.borrowerTotalReserves = 0;
        this.depositorTotalDeposits = 0;

        getVCPartners();
        getFundAccounts();

        this.relatedAccountIds = new Set<Id>();
        for(VC_Partner__c partner : this.VCPartners){
            this.relatedAccountIds.add(partner.Account__c);
        }
        for(Account fund : this.fundAccounts){
            this.relatedAccountIds.add(fund.Id);
        }

        if(this.relatedAccountIds.size() > 0){
            getFundInvestments();
            getRelatedAccounts();
            getBorrowersAndDepositors();
            calculateBorrowerTotals();
            calculateDepositorTotals();
            getOtherReportPopulations();
            this.pipelineBorrowers.sort();
            this.pipelineNonBorrowers.sort();
        }
        getReferrals();
        this.referrals.sort();
    }
    private void getVCPartners(){
        this.VCPartners = [
            SELECT
                Id,
                Name,
                (SELECT
                    Id,
                    Name,
                    Account__c
                FROM
                    Partnered_Account__r
                WHERE
                    (Account_Status__c != null AND Account_Status__c =: CUSTOMER_ACCOUNT_STATUS))
            FROM
                Account
            WHERE
                Id =: this.account.Id].Partnered_Account__r;
    }
    private void getFundAccounts(){
        this.fundAccounts = [
            SELECT
                Id,
                Name
            FROM
                Account
            WHERE
                RecordTypeId = :FUND_RECORD_TYPE_ID
            AND
                (Account_Status__c != null AND Account_Status__c =: CUSTOMER_ACCOUNT_STATUS)
            AND
                (VC_Firm__c != null AND VC_Firm__c =: this.account.Id)];
    }
    private void getFundInvestments(){
        List<Fund_Investment__c> investments = [
            SELECT
                Id,
                Account__c,
                Account__r.Name,
                Account_Invested_In__c,
                Account_Invested_In__r.Name,
                Reserves__c,
                Fund__c,
                Fund__r.Name
            FROM
                Fund_Investment__c
            WHERE
                (Account__c != null AND Account__c =: this.account.Id)
            AND
                (
                    (Fund__c != null AND Fund__c IN: this.relatedAccountIds)
                OR
                    (Account_Invested_In__c != null AND Account_Invested_In__c IN: this.relatedAccountIds)
                )
            AND
                Reserves__c != null];

        this.investmentMap = new Map<Id, Fund_Investment__c>();
        for(Fund_Investment__c investment : investments){
            this.investmentMap.put(investment.Account_Invested_In__c, investment);
        }
    }
    private void getBorrowersAndDepositors(){
        Boolean hasSORLoan;

        for(Account acc : this.relatedAccounts){
            hasSORLoan = false;
            if(acc.LLC_BI__Loans__r.size() > 0){

                Decimal depositTotal = 0;
                for(LLC_BI__Deposit__c deposit : acc.LLC_BI__Deposits__r){
                    if(deposit.Current_Balance__c != null){
                        depositTotal += deposit.Current_Balance__c;
                    }
                }

                Decimal reserves = 0;
                if(investmentMap.get(acc.Id) != null){
                    reserves = investmentMap.get(acc.Id).Reserves__c;
                }

                for(LLC_BI__Loan__c loan : acc.LLC_BI__Loans__r){
                    if(loan.RecordTypeId == SOR_RECORD_TYPE_ID
                        && loan.LLC_BI__Status__c == LOAN_STATUS_OPEN
                        && loan.Deal_Facility__c == null){
                        
                        Decimal loanReserves = 0; // default reserves to zero
                        if(loan.Loan_Type__c == LOAN_TYPE_DEAL){
                            loanReserves = reserves;
                        }
                        //found Borrower
                        hasSORLoan = true;
                        VCRelatedAccount related = new VCRelatedAccount(acc.Id, acc.Name, acc.Owner.Name);
                        related.setBorrowerFields(
                            loan.LLC_BI__Description__c,
                            loan.LLC_BI__Amount__c,
                            loan.LLC_BI__Total_Disbursed__c,
                            depositTotal,
                            loanReserves,
                            loan.LLC_BI__Risk_Grade__c,
                            loan.Deal_Facility__c);
                        this.borrowers.add(related);
                    }else if(loan.RecordTypeId == CAR_RECORD_TYPE_ID
                             && PIPELINE_STAGES.contains(loan.LLC_BI__Stage__c)
                             && (PIPELINE_ACTION_TYPES.contains(loan.Action_Type__c)|| loan.New_Est_Outstandings__c != null)){
                        //found Pipeline Borrower
                        VCRelatedAccount related = new VCRelatedAccount(acc.Id, acc.Name, acc.Owner.Name);
                        related.setPipelineBorrowerFields(
                            loan.Action_Type__c,
                            loan.LLC_BI__Stage__c,
                            loan.Approval_Date__c,
                            loan.LLC_BI__Amount__c,
                            loan.New_Est_Outstandings__c,
                            loan.New_Total_Deposits__c);
                        this.pipelineBorrowers.add(related);
                    }
                }
            }

            if(!hasSORLoan && acc.LLC_BI__Deposits__r.size() > 0){
                for(LLC_BI__Deposit__c deposit : acc.LLC_BI__Deposits__r){
                    if(deposit.LLC_BI__Status__c == LOAN_STATUS_OPEN){
                        //found Depositor
                        VCRelatedAccount related = new VCRelatedAccount(acc.Id, acc.Name, acc.Owner.Name);
                        related.setDepositorFields(
                            deposit.Collected_Balance__c,
                            deposit.Average_Balance_This_Year__c);
                        this.depositors.add(related);
                    }
                }
            }
        }
    }
    private void getRelatedAccounts(){
        this.relatedAccounts = [
            SELECT
                Id,
                Name,
                Owner.Id,
                Owner.Name,
                (SELECT
                    Id,
                    Name,
                    LLC_BI__Description__c,
                    LLC_BI__Amount__c,
                    LLC_BI__Total_Disbursed__c,
                    LLC_BI__Closed_Date__c,
                    Total_Deposits__c,
                    Deal_Facility__c,
                    RecordTypeId,
                    LLC_BI__Status__c,
                    LLC_BI__Stage__c,
                    LLC_BI__Risk_Grade__c,
                    Lost_To__c,
                    Reasons_Lost__c,
                    Approval_Date__c,
                    Action_Type__c,
                    CAR__c,
                    New_Est_Outstandings__c,
                    New_Total_Deposits__c,
                    Loan_Type__c
                FROM
                    LLC_BI__Loans__r
                ),
                (SELECT
                    Id,
                    Name,
                    LLC_BI__Amount__c,
                    Current_Balance__c,
                    Average_Balance_This_Year__c,
                    Collected_Balance__c,
                    LLC_BI__Status__c
                FROM
                    LLC_BI__Deposits__r
                ),
                (SELECT
                    Id,
                    Name,
                    Type,
                    StageName,
                    CloseDate,
                    Total_Deposits__c,
                    Estimated_Yearly_Revenue__c,
                    Reasons_Lost__c
                FROM
                    Opportunities
                )
            FROM
                 Account
            WHERE
                Id IN: this.relatedAccountIds
            ORDER BY
                Name];
    }
    private void calculateBorrowerTotals(){
        for(VCRelatedAccount borrower : this.borrowers){
            if(borrower.totalCommitments != null){
                this.borrowerTotalCommitments += borrower.totalCommitments;
            }
            if(borrower.totalOutstandings != null){
                this.borrowerTotalOutstandings += borrower.totalOutstandings;
            }

            if(borrower.totalDepositAmt != null){
                this.borrowerTotalDeposits += borrower.totalDepositAmt;
            }

            if(borrower.reserves != null){
                this.borrowerTotalReserves += borrower.reserves;
            }
        }
    }
    private void calculateDepositorTotals(){
        for(VCRelatedAccount depositor : this.depositors){
            if(depositor.collectedBalance != null){
                this.depositorTotalDeposits += depositor.collectedBalance;
            }
        }
    }
    private void getOtherReportPopulations(){
        for(Account acc : this.relatedAccounts){

            if(acc.Opportunities.size() > 0){
                for(Opportunity opp : acc.Opportunities){
                    if(opp.stageName != OPPORUTNITY_WON_STAGE && opp.stageName != OPPORTUNITY_LOST_STAGE){
                        VCRelatedAccount related = new VCRelatedAccount(acc.Id, acc.Name, acc.Owner.Name);
                        related.setPipelineNonBorrowerFields(
                            opp.Type,
                            opp.StageName,
                            opp.CloseDate,
                            opp.Total_Deposits__c,
                            opp.Estimated_Yearly_Revenue__c);
                        this.pipelineNonBorrowers.add(related);
                    } else if(opp.stageName == OPPORTUNITY_LOST_STAGE){
                        VCRelatedAccount related = new VCRelatedAccount(acc.Id, acc.Name, acc.Owner.Name);
                        related.setLostDepositFields(
                            opp.Type,
                            opp.CloseDate,
                            opp.Reasons_Lost__c);
                        this.lostDeposits.add(related);
                    }
                }
            }

            if(acc.LLC_BI__Loans__r.size() > 0){
                for(LLC_BI__Loan__c loan : acc.LLC_BI__Loans__r){
                    if(loan.RecordTypeId == CAR_RECORD_TYPE_ID && LOST_LOAN_STATUSES.contains(loan.LLC_BI__Status__c)){
                        VCRelatedAccount related = new VCRelatedAccount(acc.Id, acc.Name, acc.Owner.Name);
                        related.setLostLoanFields(
                            loan.Name,
                            loan.LLC_BI__Status__c,
                            loan.LLC_BI__Closed_Date__c,
                            loan.Lost_To__c,
                            loan.Reasons_Lost__c);
                        this.lostLoans.add(related);
                    }
                }
            }
        }
    }
    private void getReferrals(){
        this.referrals = [
            SELECT
                Account_Name__c,
                Account_Name__r.Name,
                Referred_By_Company__c,
                Referred_By__c,
                Referred_To__c,
                nRE__Referral_Status__c,
                Loan_Commitment_Amount__c,
                Total_Deposits__c,
                nRE__Referral_Details__c
            FROM
                nRE__Referral__c
            WHERE
                Referred_By_Company__c != null AND Referred_By_Company__c =: this.account.Name];
    }
    public class VCRelatedAccount implements Comparable{
        public Id accountId {get; set;}
        public String accountName {get;set;}
        public String accountOfficer {get;set;}
        public String facilityType {get;set;}
        public Decimal totalCommitments {get;set;}
        public Decimal totalOutstandings {get;set;}
        public Decimal totalDepositAmt {get;set;}
        public Decimal reserves {get;set;}
        public String CRR {get;set;}
        public Decimal collectedBalance {get; set;}
        public Decimal averageBalance {get; set;}
        public String actionType {get; set;}
        public String stage {get; set;}
        public Date dateApproved {get; set;}
        public Decimal TPL {get; set;}
        public Decimal newEstOutstandings {get; set;}
        public Decimal newTotalDeposits {get; set;}
        public String loanName {get; set;}
        public String status {get; set;}
        public Date closeDate {get; set;}
        public String lostTo {get; set;}
        public String reasonsLost {get; set;}
        public String type {get; set;}
        public Decimal estimatedYearlyRevenue {get; set;}
        public String dealFacility {get; set;}

        public VCRelatedAccount(
            Id accountId,
            String accountName,
            String accountOfficer) {

            this.accountId = accountId;
            this.accountName = accountName;
            this.accountOfficer = accountOfficer;
        }
        private void setBorrowerFields(
            String facilityType,
            Decimal totalCommitments,
            Decimal totalOutstandings,
            Decimal totalDepositAmt,
            Decimal reserves,
            String CRR,
            String dealFacility){

            this.facilityType = facilityType;
            this.totalCommitments = totalCommitments;
            this.totalOutstandings = totalOutstandings;
            this.totalDepositAmt = totalDepositAmt;
            this.reserves = reserves;
            this.CRR = CRR;
            this.dealFacility = dealFacility;
        }
        private void setDepositorFields(
            Decimal collectedBalance,
            Decimal averageBalance){

            this.collectedBalance = collectedBalance;
            this.averageBalance = averageBalance;
        }
        private void setPipelineBorrowerFields(
            String actionType,
            String stage,
            Date dateApproved,
            Decimal TPL,
            Decimal newEstOutstandings,
            Decimal newTotalDeposits){

            this.actionType = actionType;
            this.stage = stage;
            this.dateApproved = dateApproved;
            this.TPL = TPL;
            this.newEstOutstandings = newEstOutstandings;
            this.newTotalDeposits = newTotalDeposits;
        }
        private void setPipelineNonBorrowerFields(
            String type,
            String stage,
            Date closeDate,
            Decimal totalDeposits,
            Decimal estimatedYearlyRevenue){

            this.type = type;
            this.stage = stage;
            this.closeDate = closeDate;
            this.totalDepositAmt = totalDeposits;
            this.estimatedYearlyRevenue = estimatedYearlyRevenue;
        }
        private void setLostLoanFields(
            String loanName,
            String status,
            Date closeDate,
            String lostTo,
            String reasonsLost){

            this.loanName = loanName;
            this.status = status;
            this.closeDate = closeDate;
            this.lostTo = lostTo;
            this.reasonsLost = reasonsLost;
        }
        private void setLostDepositFields(
            String type,
            Date closeDate,
            String reasonsLost){

            this.type = type;
            this.closeDate = closeDate;
            this.reasonsLost = reasonsLost;
        }
        public Integer compareTo(Object compareTo){
            VCRelatedAccount compareToRelatedAccount = (VCRelatedAccount)compareTo;

            Integer returnValue = 0;
            if(this.stage > compareToRelatedAccount.stage){
                returnValue = 1;
            } else if(this.stage < compareToRelatedAccount.stage){
                returnValue = -1;
            }
            return returnValue;
        }
    }
    private static final String CUSTOMER_ACCOUNT_STATUS = 'Customer';
    private static final String LOAN_STATUS_OPEN = 'Open';
    private static final Id FUND_RECORD_TYPE_ID = 
        Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Fund').getRecordTypeId();
    private static final Id SOR_RECORD_TYPE_ID = 
        LLC_BI__Loan__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('SOR Record Type').getRecordTypeId();
    private static final Id CAR_RECORD_TYPE_ID = 
        LLC_BI__Loan__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('CAR Record Type').getRecordTypeId();
    private static final Set<String> PIPELINE_STAGES = 
        new Set<String>{
            '1.0 Prospecting/Bus. Development',
            '2.0 Initial Deal Review',
            '3.0 Underwriting',
            '4.0 Post Approval Processing',
            '5.0 Closing'
        };
    private static final Set<String> PIPELINE_ACTION_TYPES = new Set<String>{'EOI', 'Term Sheet', 'New Credit'};
    private static final Set<String> LOST_LOAN_STATUSES = new Set<String>{'Withdrawn', 'Declined', 'Lost'};
    private static final String OPPORTUNITY_LOST_STAGE = 'Closed/Lost';
    private static final String OPPORUTNITY_WON_STAGE = 'Closed/Won';
    private static final String LOAN_TYPE_DEAL = 'Deal';
}
