public with sharing class FinancialAccountsController {
    
    public List<Obligor__c> loans       { get; set; }
    public List<Obligor__c> deposits    { get; set; }
    public List<Obligor__c> treasury    { get; set; }
    public List<Obligor__c> wealth      { get; set; }
    public List<Obligor__c> insurance   { get; set; }
    public List<Opportunity> oppList;
    public Id objId = ApexPages.currentPage().getParameters().get('id');
    private final Account acct;

    public FinancialAccountsController() {
    	Account a = [SELECT
                Name
            FROM
                Account
            WHERE
                Id =: objId];

        oppList = [SELECT
        		Id
        	FROM
        		Opportunity
        	WHERE
        		AccountId =: a.Id];

        this.loans = getLoans();
        this.deposits = getDeposits();
        this.treasury = getTreasuries();
        this.wealth = getWealths();
        this.insurance = getInsurances();
    }

    public FinancialAccountsController(ApexPages.StandardController controller) {
        this.acct = (Account)controller.getRecord();

        Account a = [SELECT
                Name
            FROM
                Account
            WHERE
                Id =: objId];

        oppList = [SELECT
        		Id
        	FROM
        		Opportunity
        	WHERE
        		AccountId =: a.Id];

        this.loans = getLoans();
        this.deposits = getDeposits();
        this.treasury = getTreasuries();
        this.wealth = getWealths();
        this.insurance = getInsurances();
    }

    public List<Schema.FieldSetMember> getLoanFields() {
        return SObjectType.Financial_Product__c.FieldSets.Financial_Product_Loans.getFields();
    }

    public List<Schema.FieldSetMember> getDepositFields() {
        return SObjectType.Financial_Product__c.FieldSets.Financial_Product_Deposits.getFields();
    }

    public List<Schema.FieldSetMember> getTreasuryFields() {
        return SObjectType.Financial_Product__c.FieldSets.Financial_Product_Treasury.getFields();
    }

    public List<Schema.FieldSetMember> getWealthFields() {
        return SObjectType.Financial_Product__c.FieldSets.Financial_Product_Wealth.getFields();
    }

    public List<Schema.FieldSetMember> getInsuranceFields() {
        return SObjectType.Financial_Product__c.FieldSets.Financial_Product_Insurance.getFields();
    }

    public List<Obligor__c> getLoans() {
        String soql = 'SELECT ';

        for(Schema.FieldSetMember f : this.getLoanFields()) {
            soql += f.getFieldPath() + ',';
        }

        soql = soql.substring(0, soql.length() - 1);
        soql = soql + ' FROM ' + FINANCIAL_ACCOUNT + 
                      ' WHERE Opportunity__c IN : oppList' +
					  ' AND ' + PRODUCT +  ' =: LOAN_PRODUCT';
        return Database.query(soql);
	}

    public List<Obligor__c> getDeposits() {
        String soql = 'SELECT ';

        for(Schema.FieldSetMember f : this.getDepositFields()) {
            soql += f.getFieldPath() + ',';
        }

        soql = soql.substring(0, soql.length() - 1);
        soql = soql + ' FROM ' + FINANCIAL_ACCOUNT + 
                      ' WHERE Opportunity__c IN : oppList' +
					  ' AND ' + PRODUCT +  ' =: DEPOSIT_PRODUCT';
        return Database.query(soql);
    }

    public List<Obligor__c> getTreasuries() {
        String soql = 'SELECT ';

        for(Schema.FieldSetMember f : this.getTreasuryFields()) {
            soql += f.getFieldPath() + ',';
        }

        soql = soql.substring(0, soql.length() - 1);
        soql = soql + ' FROM ' + FINANCIAL_ACCOUNT + 
                      ' WHERE Opportunity__c IN : oppList' +
					  ' AND ' + PRODUCT +  ' =: TREASURY_PRODUCT';
        return Database.query(soql);
    }

    public List<Obligor__c> getWealths() {
        String soql = 'SELECT ';

        for(Schema.FieldSetMember f : this.getWealthFields()) {
            soql += f.getFieldPath() + ',';
        }

        soql = soql.substring(0, soql.length() - 1);
        soql = soql + ' FROM ' + FINANCIAL_ACCOUNT + 
                      ' WHERE Opportunity__c IN : oppList' +
					  ' AND ' + PRODUCT +  ' =: WEALTH_PRODUCT';
        return Database.query(soql);
    }

    public List<Obligor__c> getInsurances() {
        String soql = 'SELECT ';

        for(Schema.FieldSetMember f : this.getInsuranceFields()) {
            soql += f.getFieldPath() + ',';
        }

        soql = soql.substring(0, soql.length() - 1);
        soql = soql + ' FROM ' + FINANCIAL_ACCOUNT + 
                      ' WHERE Opportunity__c IN : oppList' +
					  ' AND ' + PRODUCT +  ' =: INSURANCE_PRODUCT';
        return Database.query(soql);
    }

    private static final String FINANCIAL_ACCOUNT = 'Financial_Product__c';
    private static final String PRODUCT = 'Product_Family__c';
    private static final String LOAN_PRODUCT = 'Loans / Credit';
    private static final String DEPOSIT_PRODUCT = 'Deposits';
    private static final String WEALTH_PRODUCT = 'Investments / Wealth Management';
    private static final String TREASURY_PRODUCT = 'Treasury Management';
    private static final String INSURANCE_PRODUCT = 'Insurance';
}