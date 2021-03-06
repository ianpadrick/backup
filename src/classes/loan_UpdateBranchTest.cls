@isTest
private class UpdateBranch_Test {

    static testmethod void test_trigger(){

    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

    	//Create Branch Record
    	LLC_BI__Branch__c branch = new LLC_BI__Branch__c();
    	branch.name = 'Test branch';

    	insert branch;

    	//Create User Record
    	User loanOfficer = new User();
    	loanOfficer.Alias = 'newUser1';
        loanOfficer.Email = 'newUser1@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName1';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser1@testorg0.com';
        loanOfficer.Branch_ID__c = branch.ID;

       	insert loanOfficer;

    	//Create Account for loan
        account acct = new account();
        acct.name = 'test Acct';

        insert acct;

        //Create Loan
        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficer.ID;
        loan.LLC_BI__Account__c = acct.ID;
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';

		insert loan;
    }
}
