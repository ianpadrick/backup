@isTest
private class RiskWorksheetControllerTest {
    static testMethod void TestSaveAndRedirect() {

    LLC_BI.CompositeFieldsDataProvider provider = new LLC_BI.CompositeFieldsDataProvider();
        provider.run(false);
    LLC_BI.LifeCycleDao dao = new LLC_BI.LifeCycleDao(provider);
        dao.performAllDml();

    Region__c region = new Region__c(Name = 'Test Region');
    insert region;
        system.debug('*** Region Id: ' + region.Id);

    LLC_BI__Branch__c branch = new LLC_BI__Branch__c(Name = 'Test Branch', Region__c = region.Id);
    insert branch;
        system.debug('*** Branch Id: ' + branch.Id);

    Account account = new Account(Name = 'Test Account', LLC_BI__Tax_Identification_Number__c = '12345123', LOOKUP_Region__c = region.Id, LLC_Branch__c = branch.Id, Industry = 'Agriculture', BillingStreet = '2605 Iron Gate Drive', BillingCity = 'Wilmington', BillingState = 'NC', BillingPostalCode = '28412');
    insert account;
        system.debug('*** Account Id: ' + account.Id);

    LLC_BI__Loan__c loan = new LLC_BI__Loan__c(Name = 'Test Deal', LLC_BI__Account__c = account.Id, LLC_BI__CloseDate__c = System.Today(), LLC_BI__Stage__c = '1.0 Prospecting/Bus. Development',
                                               LLC_BI__Status__c = 'Open', New_Business__c = 'New Business for New Customer', LLC_BI__Amount__c = 500000, Approval_Category__c = 'Term Sheet',
                                               Approval_Type__c = 'Term Sheet', Action_Type__c = 'Term Sheet', Loan_Type__c = 'Deal Facility', LLC_BI__Product_Line__c = 'CAR',
                                               LLC_BI__Product_Type__c = 'CAR', LLC_BI__Product__c = 'CAR');
    insert loan;
        system.debug('*** Loan Id: ' + loan.Id);

    LLC_BI__Risk_Grade_Template__c template = new LLC_BI__Risk_Grade_Template__c(Name = 'Test', LLC_BI__Template_Object_Type__c = 'Account');
    insert template;
        system.debug('*** Template Id: ' + template.Id);

    LLC_BI__Annual_Review__c annual = new LLC_BI__Annual_Review__c(LLC_BI__Account__c = account.Id, LLC_BI__Loan__c = loan.Id, LLC_BI__Risk_Grade_Template__c = template.Id);
    insert annual;
        system.debug('*** Annual Id: ' + annual.Id);

    ApexPages.currentPage().getParameters().put('id', (string)annual.Id);
    ApexPages.standardController controller = new ApexPages.standardController(annual);

    RiskWorksheetController rExt = new RiskWorksheetController(controller);
    system.assertEquals(false, rExt.refreshPage);
    rExt.refreshPage = true;
    system.assertEquals(true, rExt.refreshPage);
    system.assertEquals(null, annual.LLC_BI__Overridden_Risk_Grade_Value__c);
    system.assertEquals(null, annual.LLC_BI__Comments__c);

    annual.LLC_BI__Overridden_Risk_Grade_Value__c = 3;
    annual.LLC_BI__Comments__c = 'Test';

    PageReference page = rExt.saveRecord();
    system.assertNotEquals(null, page);
    system.assertEquals('/' + annual.Id, page.getUrl());

    LLC_BI__Annual_Review__c aRev = [SELECT Id, LLC_BI__Overridden_Risk_Grade_Value__c, LLC_BI__Comments__c, LLC_BI__Risk_Grade_Template__c FROM LLC_BI__Annual_Review__c WHERE Id =: annual.Id];
    system.assertEquals(3, aRev.LLC_BI__Overridden_Risk_Grade_Value__c);
    system.assertEquals('Test', aRev.LLC_BI__Comments__c);
    system.assertEquals(template.Id, aRev.LLC_BI__Risk_Grade_Template__c);
    }
}
