@isTest
private class LoansDepositsServicesControllerTest {
    static testMethod void LoansDepositsServicesControllerTest() {

    // Select the test profile
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    //system.debug('*** Profile Id: ' + p.Id);

    // Create the test user
    User u = new User(
        FirstName = 'test', 
        LastName = 'user', 
        Alias = 'tuser', 
        Email='tuser@test.com', 
        Username = 'tuser@thisisatestuser.com', 
        CommunityNickname = 'tuser',
        EmailEncodingKey='UTF-8', 
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', 
        ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles');
    insert u;

        System.runAs(u) {
            Account account = new Account(
                Name = 'Test Account', 
                LLC_BI__Tax_Identification_Number__c = '12345123',
                Industry = 'Agriculture', 
                BillingStreet = '2605 Iron Gate Drive', 
                BillingCity = 'Wilmington', 
                BillingState = 'NC', 
                BillingPostalCode = '28412');
            insert account;

            LLC_BI__Loan__c loan = new LLC_BI__Loan__c(
                Name = 'Test Deal', 
                LLC_BI__Account__c = account.Id, 
                LLC_BI__CloseDate__c = System.Today(), 
                LLC_BI__Stage__c = '',
                LLC_BI__Status__c = 'Open',
                LLC_BI__Amount__c = 500000,
                LLC_BI__Product_Line__c = 'CAR',
                LLC_BI__Product_Type__c = 'CAR', 
                LLC_BI__Product__c = 'CAR');
            insert loan;

            LLC_BI__Deposit__c deposit = new LLC_BI__Deposit__c(
                LLC_BI__Account__c = account.Id,
                LLC_BI__Product__c = 'Test', 
                LLC_BI__Interest_Rate__c = 5);
            insert deposit;

            LLC_SM__Service__c service = new LLC_SM__Service__c(
                Name = 'Test Service');
            insert service;

            LLC_BI__Legal_Entities__c loanEnt = new LLC_BI__Legal_Entities__c(
                LLC_BI__Account__c = account.Id,
                LLC_BI__Loan__c = loan.Id,
                LLC_BI__Borrower_Type__c = 'Borrower');
            insert loanEnt;

            LLC_BI__Legal_Entities__c depEnt = new LLC_BI__Legal_Entities__c(
                LLC_BI__Account__c = account.Id,
                LLC_BI__Deposit__c = deposit.Id,
                LLC_BI__Borrower_Type__c = 'Borrower');
            insert depEnt;

            LLC_BI__Legal_Entities__c servEnt = new LLC_BI__Legal_Entities__c(
                LLC_BI__Account__c = account.Id,
                LLC_SM__Service__c = service.Id,
                LLC_BI__Borrower_Type__c = 'Borrower');
            insert servEnt;
      
            ApexPages.currentPage().getParameters().put('id', (string)account.Id);
            ApexPages.standardController controller = new ApexPages.standardController(account);

            LoansDepositsServicesController csClass = new LoansDepositsServicesController(controller);
            
            List<LLC_BI__Legal_Entities__c> l = csClass.loans;
            system.assertNotEquals(null, l);
            system.assertEquals(1, l.size());
            system.assertEquals('Borrower', l[0].LLC_BI__Borrower_Type__c);

            List<LLC_BI__Legal_Entities__c> d = csClass.deposits;
            system.assertNotEquals(null, d);
            system.assertEquals(1, d.size());
            system.assertEquals('Borrower', l[0].LLC_BI__Borrower_Type__c);

            List<LLC_BI__Legal_Entities__c> s = csClass.services;
            system.assertNotEquals(null, s);
            system.assertEquals(1, s.size());
            system.assertEquals('Borrower', l[0].LLC_BI__Borrower_Type__c);
        }
    }
}
