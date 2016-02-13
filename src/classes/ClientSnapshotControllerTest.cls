@isTest
private class TestClientSnapshotClass {
    static testMethod void TestClientSnapshotClass() {

    // Select the test profile
    Profile p = [SELECT Id FROM Profile WHERE Name='nCino Standard User'];
    //system.debug('*** Profile Id: ' + p.Id);

    // Create the test user
    User u = new User(FirstName = 'test', LastName = 'user', Alias = 'tuser', Email='tuser@test.com', Username = 'tuser@thisisatestuser.com', CommunityNickname = 'tuser',
                      EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles');
    insert u;

        System.runAs(u) {

            // Create the test region
            Region__c region = new Region__c(Name = 'Test Region');
            insert region;
                //system.debug('*** Region Id: ' + region.Id);

            // Create the test branch
            LLC_BI__Branch__c branch = new LLC_BI__Branch__c(Name = 'Test Branch', Region__c = region.Id);
            insert branch;
                //system.debug('*** Branch Id: ' + branch.Id);

            // CORRECT - Create the required test data needed for the test scenario.
            // In this case, I need to update an Account to have a BillingState='CA'
            // So I create that Account in my test method itself. 
            Account account = new Account(Name = 'Test Account', LLC_BI__Tax_Identification_Number__c = '12345123', LOOKUP_Region__c = region.Id, LLC_Branch__c = branch.Id, Industry = 'Agriculture', BillingStreet = '2605 Iron Gate Drive', BillingCity = 'Wilmington', BillingState = 'NC', BillingPostalCode = '28412');
            insert account;
            //List<Account> accList = [SELECT Id, Portfolio__c, LLC_BI__Tax_Identification_Number__c, LOOKUP_REGION__c, LOOKUP_REGION__r.Name, LLC_Branch__c, LLC_Branch__r.Name, Owner.Name, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE Id =: account.Id];
                    //system.debug('*** Account Id: ' + account.Id + '; Account Region: ' + account.LOOKUP_Region__c + '; Account Branch: ' + account.LLC_Branch__c);

            Relationship_Covenants__c relCov = new Relationship_Covenants__c(Name = 'Test Covenant', Relationship__c = account.Id);
            insert relCov;
                //system.debug('*** RelCov Id: ' + relCov.Id + '; RelCov Account: ' + relCov.Relationship__c);

            Relationship_Covenant_Compliance__c relCovComp = new Relationship_Covenant_Compliance__c(Relationship_Covenant__c = relCov.Id);
            insert relCovComp;
                //system.debug('*** RelCovComp Id: ' + relCovComp.Id + '; RelCovComp Covenant: ' + relCovComp.Relationship_Covenant__c);

            Aggregation_Tracking__c aggregation = new Aggregation_Tracking__c(Account__c = account.Id, Aggregated_Party__c = account.Id, Portfolio_Number__c = '12345', Total_Aggregated_Amount__c = 50000, Total_Committed__c = 10000);
            insert aggregation;
                //system.debug('*** Aggregation Id: ' + aggregation.Id + '; Aggregation Account: ' + aggregation.Account__c);

            Guarantor_Relationships__c guarantee = new Guarantor_Relationships__c(Guarantee_Account__c = account.Id, Guarantor_Portfolio__c = '654321');
            insert guarantee;
                //system.debug('*** Guarantee Id: ' + guarantee.Id + '; Guarantee Account: ' + guarantee.Guarantee_Account__c);

            Guarantor_Relationships__c guarantor = new Guarantor_Relationships__c(Guarantor_Account__c = account.Id, Guarantee_Portfolio__c = '123456');
            insert guarantor;
                //system.debug('*** Guarantor Id: ' + guarantor.Id + '; Guarantor Account: ' + guarantor.Guarantor_Account__c);

            LLC_BI__Loan__c deal = new LLC_BI__Loan__c(Name = 'Test Deal', LLC_BI__Account__c = account.Id, LLC_BI__CloseDate__c = System.Today(), LLC_BI__Stage__c = '1.0 Prospecting/Bus. Development',
                                                       LLC_BI__Status__c = 'Open', New_Business__c = 'New Business for New Customer', LLC_BI__Amount__c = 500000, Approval_Category__c = 'Term Sheet',
                                                       Approval_Type__c = 'Term Sheet', Action_Type__c = 'Term Sheet', Loan_Type__c = 'Deal Facility', LLC_BI__Product_Line__c = 'CAR',
                                                       LLC_BI__Product_Type__c = 'CAR', LLC_BI__Product__c = 'CAR', LLC_BI__Principal_Balance__c = 100);
            insert deal;
                //system.debug('*** Deal Id: ' + deal.Id + '; Deal Account: ' + deal.LLC_BI__Account__c);

            LLC_BI__Loan__c facility = new LLC_BI__Loan__c(Name = 'Test Facility', LLC_BI__Account__c = account.Id, LLC_BI__CloseDate__c = System.Today(), LLC_BI__Stage__c = '1.0 Prospecting/Bus. Development', 
                                                           LLC_BI__Status__c = 'Open', New_Business__c = 'New Business for New Customer', LLC_BI__Amount__c = 500000,Approval_Category__c = 'Term Sheet',
                                                           Approval_Type__c = 'Term Sheet', Action_Type__c = 'Term Sheet', Loan_Type__c = 'Facility', LLC_BI__Product_Line__c = 'CAR', LLC_BI__Product_Type__c = 'CAR', 
                                                           LLC_BI__Product__c = 'CAR', Section__c = '12', Limit_Type__c = '34', LLC_BI__Description__c = 'Test', LLC_BI__Principal_Balance__c = 100, 
                                                           ACBS_Facility__c = '56');
            insert facility;
                //system.debug('*** Facility Id: ' + facility.Id + '; Facility Account: ' + facility.LLC_BI__Account__c);

            LLC_BI__Loan__c balance = new LLC_BI__Loan__c(Name = 'Test Balance', LLC_BI__Account__c = account.Id, LLC_BI__CloseDate__c = System.Today(), LLC_BI__Stage__c = '1.0 Prospecting/Bus. Development',
                                                          LLC_BI__Status__c = 'Open', New_Business__c = 'New Business for New Customer', LLC_BI__Amount__c = 500000,Approval_Category__c = 'Term Sheet',
                                                          Approval_Type__c = 'Term Sheet', Action_Type__c = 'Term Sheet', Loan_Type__c = 'Loan Balance', LLC_BI__Product_Line__c = 'CAR', LLC_BI__Product_Type__c = 'CAR',
                                                          LLC_BI__Product__c = 'CAR',  ACBS_Facility__c = '12', ACBS_Loan__c = '34', LLC_BI__Total_Disbursed__c = 50, 
                                                          LLC_BI__Maturity_Date__c = System.Today());
            insert balance;
                //system.debug('*** Balance Id: ' + balance.Id + '; Balance Account: ' + balance.LLC_BI__Account__c);

            LLC_BI__Loan__c stucky = new LLC_BI__Loan__c(Name = 'Test Stucky', LLC_BI__Account__c = account.Id, LLC_BI__CloseDate__c = System.Today(), LLC_BI__Stage__c = '1.0 Prospecting/Bus. Development',
                                                          LLC_BI__Status__c = 'Open', New_Business__c = 'New Business for New Customer', LLC_BI__Amount__c = 500000,Approval_Category__c = 'Term Sheet',
                                                          Approval_Type__c = 'Term Sheet', Action_Type__c = 'Term Sheet', Loan_Type__c = 'Loan Balance', LLC_BI__Product_Line__c = 'CAR', LLC_BI__Product_Type__c = 'CAR',
                                                          LLC_BI__Product__c = 'CAR',  ACBS_Facility__c = '12', ACBS_Loan__c = '34', LLC_BI__Total_Disbursed__c = 50, 
                                                          LLC_BI__Maturity_Date__c = System.Today(),
                                                          Extract__c = 'Stucky', Stucky_Loan_Number__c = '12');
            insert stucky;
                //system.debug('*** Balance Id: ' + balance.Id + '; Balance Account: ' + balance.LLC_BI__Account__c);

            LLC_BI__Deposit__c deposit = new LLC_BI__Deposit__c(LLC_BI__Account__c = account.Id, Account_Number__c = '12345', LLC_BI__Product__c = 'Test', Current_Balance__c = 10000, LLC_BI__Interest_Rate__c = 5);
            insert deposit;
                //system.debug('*** Deposit Id: ' + deposit.Id + '; Deposit Account: ' + deposit.LLC_BI__Account__c);

            Participation_Tracking__c participation = new Participation_Tracking__c(Account__c = account.Id, Bank_Percentage__c = 50, Participant__c = 'Test', Participation_Amount__c = 100, Portfolio_Number__c = '12345', Total_Facility_Size__c = 1);
            insert participation;
                //system.debug('*** Participation Id: ' + participation.Id + '; Participation Account: ' + participation.Account__c);

      
            ApexPages.currentPage().getParameters().put('id', (string)account.Id);
            ApexPages.standardController controller = new ApexPages.standardController(account);

            ClientSnapshotClass csClass = new ClientSnapshotClass(controller);
            List<Account> acc = csClass.info;
            system.assertNotEquals(null, acc);
            system.assertEquals(1, acc.size());
            system.assertEquals(account.Id, acc[0].Id);
            system.assertNotEquals(null, acc[0].Portfolio__c);
            system.assertEquals('12345123', acc[0].LLC_BI__Tax_Identification_Number__c);
            system.assertEquals(region.Id, acc[0].LOOKUP_REGION__c);
            system.assertEquals(branch.Id, acc[0].LLC_Branch__c);
            system.assertNotEquals(null, acc[0].Owner);
            system.assertNotEquals(null, acc[0].Owner.Name);

            acc = csClass.address;
            system.assertNotEquals(null, acc);
            system.assertEquals(1, acc.size());
            system.assertEquals('2605 Iron Gate Drive', acc[0].BillingStreet);
            system.assertEquals('Wilmington', acc[0].BillingCity);
            system.assertEquals('NC', acc[0].BillingState);
            system.assertEquals('28412', acc[0].BillingPostalCode);

      // MISSING relCovs
      
            List<Relationship_Covenant_Compliance__c> rel = csClass.compliances;
            system.assertNotEquals(null, rel);
            system.assertEquals(1, rel.size());
            system.assertNotEquals(null, rel[0].CreatedDate);

      // MISSING covenants
      List<Relationship_Covenants__c> relCovs = csClass.Covenants;
      system.assertNotEquals(null, relCovs);
      system.assertEquals(1, relCovs.size());
      system.assertEquals('Test Covenant', relCovs[0].Name);
      
            List<Aggregation_Tracking__c> agg = csClass.aggregations;
            system.assertNotEquals(null, rel);
            system.assertEquals(1, rel.size());
            system.assertEquals(account.Id, agg[0].Account__c);
            system.assertEquals(account.Id, agg[0].Aggregated_Party__c);
            system.assertEquals('12345', agg[0].Portfolio_Number__c);
            system.assertEquals(50000, agg[0].Total_Aggregated_Amount__c);
            system.assertEquals(10000, agg[0].Total_Committed__c);
            
            List<Guarantor_Relationships__c> guar = csClass.guarantors;
            system.assertNotEquals(null, guar);
            system.assertEquals(1, guar.size());
            system.assertEquals(guarantee.Id, guar[0].Id);
            system.assertEquals('654321', guar[0].Guarantor_Portfolio__c);

            List<Guarantor_Relationships__c> gure = csClass.guarantees;
            system.assertNotEquals(null, gure);
            system.assertEquals(1, gure.size());
            system.assertEquals(guarantor.Id, gure[0].Id);
            system.assertEquals('123456', gure[0].Guarantee_Portfolio__c);

            List<LLC_BI__Loan__c> loanDeal = csClass.deals;
            system.assertNotEquals(null, loanDeal);
            system.assertEquals(0, loanDeal.size());
          /*system.assertEquals(account.Id, loanDeal[0].LLC_BI__Account__c);
            system.assertEquals(100, loanDeal[0].LLC_BI__Principal_Balance__c);
            system.assertEquals('Open', loanDeal[0].LLC_BI__Status__c);
            system.assertEquals(500000, loanDeal[0].LLC_BI__Amount__c);
            system.assertEquals('Deal Facility', loanDeal[0].Loan_Type__c);*/

            List<LLC_BI__Loan__c> fac = csClass.facilities;
            system.assertNotEquals(null, fac);
            system.assertEquals(1, fac.size());
            system.assertEquals(System.Today(), fac[0].LLC_BI__CloseDate__c);
            system.assertEquals(500000, fac[0].LLC_BI__Amount__c);
            system.assertEquals('12', fac[0].Section__c);
            system.assertEquals('34', fac[0].Limit_Type__c);
            system.assertEquals('Test', fac[0].LLC_BI__Description__c);
            system.assertEquals(100, fac[0].LLC_BI__Principal_Balance__c);
            system.assertEquals(System.Today(), fac[0].LLC_BI__CloseDate__c);
            system.assertEquals('56', fac[0].ACBS_Facility__c);

            List<LLC_BI__Loan__c> bal = csClass.balances;
            system.assertNotEquals(null, bal);
            system.assertEquals(1, bal.size());
            system.assertEquals(null, bal[0].Booked_Boarded_Date__c);
            /*system.assertEquals('12', bal[0].ACBS_Facility__c);
            system.assertEquals('34', bal[0].ACBS_Loan__c);
            system.assertEquals(50, bal[0].LLC_BI__Total_Disbursed__c);
            system.assertEquals(System.Today(), bal[0].LLC_BI__Maturity_Date__c);
            system.assertNotEquals(null, bal[0].CreatedDate);*/

      // MISSING ABL
      List<LLC_BI__Loan__c> abl = csClass.aBL;
            system.assertNotEquals(null, abl);
            system.assertEquals(1, abl.size());
            system.assertEquals('12', abl[0].Stucky_Loan_Number__c);
      
      
            List<LLC_BI__Deposit__c> depo = csClass.deposits;
            system.assertNotEquals(null, depo);
            system.assertEquals(1, depo.size());
            system.assertNotEquals(null, depo[0].CreatedDate);
            //system.assertEquals('Test Deposit', depo[0].Name);
            system.assertEquals(account.Id, depo[0].LLC_BI__Account__c);
            system.assertEquals('12345', depo[0].Account_Number__c);
            system.assertEquals('Test', depo[0].LLC_BI__Product__c);
            system.assertEquals(10000, depo[0].Current_Balance__c);
            system.assertEquals(5, depo[0].LLC_BI__Interest_Rate__c);

            List<Participation_Tracking__c> part = csClass.participations;
            system.assertNotEquals(null, part);
            system.assertEquals(1, part.size());
            system.assertEquals(account.Id, part[0].Account__c);
            system.assertEquals(50, part[0].Bank_Percentage__c);
            system.assertEquals('Test', part[0].Participant__c);
            system.assertEquals(100, part[0].Participation_Amount__c);
            system.assertEquals('12345', part[0].Portfolio_Number__c);
            system.assertEquals(1, part[0].Total_Facility_Size__c);
        }
    }
}
