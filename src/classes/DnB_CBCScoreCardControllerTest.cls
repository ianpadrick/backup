@isTest
private class DnB_CBCScoreCardControllerTest {
    
    @isTest static void test_method_one() {
        PageReference pref; 

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

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

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'High 4 - Mod 5';
        acct.Average_Loan_Balance__c = 'Low 5 - Low 6';
        acct.NSF_s_or_OD_s__c = '0';
        acct.Account_Type__c = 'Loan';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 650;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '650';
        creditRec.nCBC__status__c = 'Collections';
        creditRec.nCBC__creditType__c = 'Mortgage';
        creditRec.nCBC__bankruptLiabAmt__c = 6;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec2 = new nCBC__Credit_Record__c();
        creditRec2.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec2.nCBC__ContactId__c = contResult.getId();
        creditRec2.Name = 'Test Record';
        creditRec2.nCBC__scoreValue__c = '726';
        creditRec2.nCBC__status__c = 'Open';
        creditRec2.nCBC__creditType__c = 'Revolving';
        creditRec2.nCBC__creditLimit__c = 50000;
        Database.upsertResult creditRec2Result = Database.upsert(creditRec2);

        nCBC__Credit_Record__c creditRec3 = new nCBC__Credit_Record__c();
        creditRec3.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec3.nCBC__ContactId__c = contResult.getId();
        creditRec3.Name = 'Test Record';
        creditRec3.nCBC__scoreValue__c = '650';
        creditRec3.nCBC__status__c = 'Open';
        creditRec3.nCBC__creditType__c = 'Revolving';
        creditRec3.nCBC__balance__c = 5000;
        Database.upsertResult creditRec3Result = Database.upsert(creditRec3);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 700;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 34;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'DB-Paydex';
        busScore.nBCR__Score_Rating__c = '76';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        nBCR__Business_Credit_Score__c busScore2 = new nBCR__Business_Credit_Score__c();
        busScore2.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore2.nBCR__Score_Description__c = 'Commercial Credit Score';
        busScore2.nBCR__Score_Rating__c = '550';
        Database.upsertResult busScore2Result = Database.upsert(busScore2);

        nBCR__Business_Credit_Score__c busScore3 = new nBCR__Business_Credit_Score__c();
        busScore3.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore3.nBCR__Score_Description__c = 'Commercial Credit Score Percentile';
        busScore3.nBCR__Score_Rating__c = '700';
        Database.upsertResult busScore3Result = Database.upsert(busScore3);

        nDNB__Business_Credit_Judgment__c credJudge = new nDNB__Business_Credit_Judgment__c();
        credJudge.nDNB__Business_Credit_Report__c = busCreditResult.getId();
        credJudge.nDNB__Judgment_Count__c = 1;
        Database.upsertResult credJudgeResult = Database.upsert(credJudge);


        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Personal Guarantee' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.New_Used__c = 'New';
        riskGrade.Useful_Life__c = '5-7 Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'Y - IM';
        riskGrade.Down_Payment__c = 15;
        riskGrade.Other_Collateral__c = 'Blanket';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();
    }

    @isTest static void test_method_two() {
        PageReference pref; 

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser7';
        loanOfficer.Email = 'newUser7@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName7';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser7@testorg0.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'Low 4 - Mod 4';
        acct.Average_Loan_Balance__c = '0 - Low 5';
        acct.NSF_s_or_OD_s__c = '3-5';
        acct.Account_Type__c = 'Both';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 650;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '650';
        creditRec.nCBC__status__c = 'Collections';
        creditRec.nCBC__creditType__c = 'Mortgage';
        creditRec.nCBC__bankruptLiabAmt__c = 6;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec2 = new nCBC__Credit_Record__c();
        creditRec2.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec2.nCBC__ContactId__c = contResult.getId();
        creditRec2.Name = 'Test Record';
        creditRec2.nCBC__scoreValue__c = '726';
        creditRec2.nCBC__status__c = 'Open';
        creditRec2.nCBC__creditType__c = 'Revolving';
        creditRec2.nCBC__creditLimit__c = 50000;
        Database.upsertResult creditRec2Result = Database.upsert(creditRec2);

        nCBC__Credit_Record__c creditRec3 = new nCBC__Credit_Record__c();
        creditRec3.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec3.nCBC__ContactId__c = contResult.getId();
        creditRec3.Name = 'Test Record';
        creditRec3.nCBC__scoreValue__c = '650';
        creditRec3.nCBC__status__c = 'Open';
        creditRec3.nCBC__creditType__c = 'Revolving';
        creditRec3.nCBC__balance__c = 5000;
        Database.upsertResult creditRec3Result = Database.upsert(creditRec3);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 700;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 1;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'DB-Paydex';
        busScore.nBCR__Score_Rating__c = '70';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        nBCR__Business_Credit_Score__c busScore2 = new nBCR__Business_Credit_Score__c();
        busScore2.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore2.nBCR__Score_Description__c = 'Commercial Credit Score';
        busScore2.nBCR__Score_Rating__c = '400';
        Database.upsertResult busScore2Result = Database.upsert(busScore2);

        nBCR__Business_Credit_Score__c busScore3 = new nBCR__Business_Credit_Score__c();
        busScore3.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore3.nBCR__Score_Description__c = 'Commercial Credit Score Percentile';
        busScore3.nBCR__Score_Rating__c = '700';
        Database.upsertResult busScore3Result = Database.upsert(busScore3);

        nDNB__Business_Credit_Judgment__c credJudge = new nDNB__Business_Credit_Judgment__c();
        credJudge.nDNB__Business_Credit_Report__c = busCreditResult.getId();
        credJudge.nDNB__Judgment_Count__c = 1;
        Database.upsertResult credJudgeResult = Database.upsert(credJudge);


        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Personal Guarantee' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.New_Used__c = 'New';
        riskGrade.Useful_Life__c = '1-4 Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'No';
        riskGrade.Down_Payment__c = 5;
        riskGrade.Other_Collateral__c = 'None';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();
    }


        @isTest static void test_method_three() {
        PageReference pref; 

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser2';
        loanOfficer.Email = 'newUser2@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName2';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser2@testorg1.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'High 5+';
        acct.Average_Loan_Balance__c = 'Mod 6+';
        acct.NSF_s_or_OD_s__c = '1-2';
        acct.Account_Type__c = 'Deposit';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep2 = new nCBC__Credit_Report__c();
        creditRep2.nCBC__Contact__c = contResult.getId();
        creditRep2.nCBC__FICO_Score__c = 726;
        Database.upsertResult creditRep2Result = Database.upsert(creditRep2);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRep2Result.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '726';
        creditRec.nCBC__status__c = 'Open';
        creditRec.nCBC__creditType__c = 'Revolving';
        creditRec.nCBC__creditLimit__c = 40000;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec4 = new nCBC__Credit_Record__c();
        creditRec4.nCBC__CreditReport__c = creditRep2Result.getId();
        creditRec4.nCBC__ContactId__c = contResult.getId();
        creditRec4.Name = 'Test Record';
        creditRec4.nCBC__scoreValue__c = '650';
        creditRec4.nCBC__status__c = 'Collections';
        creditRec4.nCBC__creditType__c = 'Mortgage';
        creditRec4.nCBC__bankruptLiabAmt__c = 3;
        Database.upsertResult creditRec4Result = Database.upsert(creditRec4);

        nCBC__Credit_Record__c creditRec5 = new nCBC__Credit_Record__c();
        creditRec5.nCBC__CreditReport__c = creditRep2Result.getId();
        creditRec5.nCBC__ContactId__c = contResult.getId();
        creditRec5.Name = 'Test Record';
        creditRec5.nCBC__scoreValue__c = '650';
        creditRec5.nCBC__status__c = 'Open';
        creditRec5.nCBC__creditType__c = 'Revolving';
        creditRec5.nCBC__balance__c = 5000;
        Database.upsertResult creditRec5Result = Database.upsert(creditRec5);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 1000;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 2;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'Commercial Credit Score';
        busScore.nBCR__Score_Rating__c = '500';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Personal Guarantee' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.New_Used__c = 'Used';
        riskGrade.Useful_Life__c = '7+ Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'Y - CR';
        riskGrade.Down_Payment__c = 11;
        riskGrade.Other_Collateral__c = 'Real';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();
    }
    
    @isTest static void test_method_four() {
                PageReference pref; 
                date myDate = date.today();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser8';
        loanOfficer.Email = 'newUser8@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName8';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser8@testorg2.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'High 5+';
        acct.Average_Loan_Balance__c = 'Mod 6+';
        acct.NSF_s_or_OD_s__c = '3-5';
        acct.Account_Type__c = 'Both';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 650;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '650';
        creditRec.nCBC__status__c = 'Collections';
        creditRec.nCBC__creditType__c = 'Mortgage';
        creditRec.nCBC__bankruptLiabAmt__c = 3;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec10 = new nCBC__Credit_Record__c();
        creditRec10.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec10.nCBC__ContactId__c = contResult.getId();
        creditRec10.Name = 'Test Record';
        creditRec10.nCBC__scoreValue__c = '726';
        creditRec10.nCBC__status__c = 'Open';
        creditRec10.nCBC__creditType__c = 'Revolving';
        creditRec10.nCBC__creditLimit__c = 100000;
        Database.upsertResult creditRec10Result = Database.upsert(creditRec10);

        nCBC__Credit_Record__c creditRec11 = new nCBC__Credit_Record__c();
        creditRec11.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec11.nCBC__ContactId__c = contResult.getId();
        creditRec11.Name = 'Test Record';
        creditRec11.nCBC__scoreValue__c = '690';
        creditRec11.nCBC__status__c = 'Open';
        creditRec11.nCBC__creditType__c = 'Revolving';
        creditRec11.nCBC__balance__c = 5000;
        Database.upsertResult creditRec11Result = Database.upsert(creditRec11);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 700;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 0;
        busDemo.nBCR__Date_Founded__c = myDate;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'DB-Paydex';
        busScore.nBCR__Score_Rating__c = '70';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Medical' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.Years_Licensed__c = 1;
        riskGrade.Practice_Type__c = 'Spec';
        riskGrade.New_Used__c = 'New';
        riskGrade.Useful_Life__c = '1-4 Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'No';
        riskGrade.Down_Payment__c = 5;
        riskGrade.Other_Collateral__c = 'None';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();
    }

    @isTest static void test_method_five() {
                PageReference pref; 
                date myDate = date.today();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser3';
        loanOfficer.Email = 'newUser3@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName3';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser3@testorg2.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'Low 4 - Mod 4';
        acct.Average_Loan_Balance__c = '0 - Low 5';
        acct.NSF_s_or_OD_s__c = '0';
        acct.Account_Type__c = 'Loan';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 650;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '650';
        creditRec.nCBC__status__c = 'Collections';
        creditRec.nCBC__creditType__c = 'Mortgage';
        creditRec.nCBC__bankruptLiabAmt__c = 3;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec10 = new nCBC__Credit_Record__c();
        creditRec10.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec10.nCBC__ContactId__c = contResult.getId();
        creditRec10.Name = 'Test Record';
        creditRec10.nCBC__scoreValue__c = '726';
        creditRec10.nCBC__status__c = 'Open';
        creditRec10.nCBC__creditType__c = 'Revolving';
        creditRec10.nCBC__creditLimit__c = 100000;
        Database.upsertResult creditRec10Result = Database.upsert(creditRec10);

        nCBC__Credit_Record__c creditRec11 = new nCBC__Credit_Record__c();
        creditRec11.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec11.nCBC__ContactId__c = contResult.getId();
        creditRec11.Name = 'Test Record';
        creditRec11.nCBC__scoreValue__c = '690';
        creditRec11.nCBC__status__c = 'Open';
        creditRec11.nCBC__creditType__c = 'Revolving';
        creditRec11.nCBC__balance__c = 5000;
        Database.upsertResult creditRec11Result = Database.upsert(creditRec11);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 700;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 0;
        busDemo.nBCR__Date_Founded__c = myDate;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'DB-Paydex';
        busScore.nBCR__Score_Rating__c = '75';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Medical' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.Years_Licensed__c = 16;
        riskGrade.Practice_Type__c = 'MD';
        riskGrade.New_Used__c = 'New';
        riskGrade.Useful_Life__c = '5-7 Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'Y - IM';
        riskGrade.Down_Payment__c = 15;
        riskGrade.Other_Collateral__c = 'Blanket';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();
    }    

    @isTest static void test_method_six() {
                PageReference pref; 

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser4';
        loanOfficer.Email = 'newUser4@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName4';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser4@testorg.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'High 4 - Mod 5';
        acct.Average_Loan_Balance__c = 'Low 5 - Low 6';
        acct.NSF_s_or_OD_s__c = '1-2';
        acct.Account_Type__c = 'Deposit';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 750;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '750';
        creditRec.nCBC__status__c = 'Open';
        creditRec.nCBC__creditType__c = 'Revolving';
        creditRec.nCBC__creditLimit__c = 400000;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec6 = new nCBC__Credit_Record__c();
        creditRec6.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec6.nCBC__ContactId__c = contResult.getId();
        creditRec6.Name = 'Test Record';
        creditRec6.nCBC__scoreValue__c = '650';
        creditRec6.nCBC__status__c = 'Collections';
        creditRec6.nCBC__creditType__c = 'Mortgage';
        creditRec6.nCBC__bankruptLiabAmt__c = 3;
        Database.upsertResult creditRec6Result = Database.upsert(creditRec6);

        nCBC__Credit_Record__c creditRec7 = new nCBC__Credit_Record__c();
        creditRec7.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec7.nCBC__ContactId__c = contResult.getId();
        creditRec7.Name = 'Test Record';
        creditRec7.nCBC__scoreValue__c = '690';
        creditRec7.nCBC__status__c = 'Open';
        creditRec7.nCBC__creditType__c = 'Revolving';
        creditRec7.nCBC__balance__c = 5000;
        Database.upsertResult creditRec7Result = Database.upsert(creditRec7);

        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Medical' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.Years_Licensed__c = 4;
        riskGrade.Practice_Type__c = 'chiro';
        riskGrade.New_Used__c = 'Used';
        riskGrade.Useful_Life__c = '7+ Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'Y - CR';
        riskGrade.Down_Payment__c = 13;
        riskGrade.Other_Collateral__c = 'Real';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();
    }

    @isTest static void test_method_seven() {
                PageReference pref; 

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser5';
        loanOfficer.Email = 'newUser5@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName5';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser5@testorg.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'Low 4 - Mod 4';
        acct.Average_Loan_Balance__c = '0 - Low 5';
        acct.NSF_s_or_OD_s__c = '0';
        acct.Account_Type__c = 'Loan';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 650;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '650';
        creditRec.nCBC__status__c = 'Open';
        creditRec.nCBC__creditType__c = 'Revolving';
        creditRec.nCBC__creditLimit__c = 100000;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec8 = new nCBC__Credit_Record__c();
        creditRec8.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec8.nCBC__ContactId__c = contResult.getId();
        creditRec8.Name = 'Test Record';
        creditRec8.nCBC__scoreValue__c = '750';
        creditRec8.nCBC__status__c = 'Open';
        creditRec8.nCBC__creditType__c = 'Revolving';
        creditRec8.nCBC__balance__c = 5000;
        Database.upsertResult creditRec8Result = Database.upsert(creditRec8);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 700;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 4;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'DB-Paydex';
        busScore.nBCR__Score_Rating__c = '76';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        nBCR__Business_Credit_Score__c busScore2 = new nBCR__Business_Credit_Score__c();
        busScore2.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore2.nBCR__Score_Description__c = 'Commercial Credit Score';
        busScore2.nBCR__Score_Rating__c = '550';
        Database.upsertResult busScore2Result = Database.upsert(busScore2);

        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Corporate' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.Net_Income__c = 'Profit';
        riskGrade.Annual_Sales_Volume_CP__c = '$7mm+';
        riskGrade.New_Used__c = 'New';
        riskGrade.Useful_Life__c = '5-7 Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'Y - IM';
        riskGrade.Down_Payment__c = 15;
        riskGrade.Other_Collateral__c = 'Blanket';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();        

    }

    @isTest static void test_method_eight() {
                PageReference pref; 

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser6';
        loanOfficer.Email = 'newUser6@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName6';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser6@testorg.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'High 4 - Mod 5';
        acct.Average_Loan_Balance__c = 'Low 5 - Low 6';
        acct.NSF_s_or_OD_s__c = '1-2';
        acct.Account_Type__c = 'Deposit';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 650;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '650';
        creditRec.nCBC__status__c = 'Open';
        creditRec.nCBC__creditType__c = 'Revolving';
        creditRec.nCBC__creditLimit__c = 100000;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec9 = new nCBC__Credit_Record__c();
        creditRec9.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec9.nCBC__ContactId__c = contResult.getId();
        creditRec9.Name = 'Test Record';
        creditRec9.nCBC__scoreValue__c = '750';
        creditRec9.nCBC__status__c = 'Open';
        creditRec9.nCBC__creditType__c = 'Revolving';
        creditRec9.nCBC__balance__c = 5000;
        Database.upsertResult creditRec9Result = Database.upsert(creditRec9);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 1000;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 1;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'Commercial Credit Score';
        busScore.nBCR__Score_Rating__c = '500';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        nBCR__Business_Credit_Score__c busScore2 = new nBCR__Business_Credit_Score__c();
        busScore2.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore2.nBCR__Score_Description__c = 'Paydex';
        busScore2.nBCR__Score_Rating__c = '70';
        Database.upsertResult busScore2Result = Database.upsert(busScore2);

        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Corporate' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.Net_Income__c = 'Profit3';
        riskGrade.Annual_Sales_Volume_CP__c = '$3mm to $7mm';
        riskGrade.New_Used__c = 'Used';
        riskGrade.Useful_Life__c = '7+ Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'Y - CR';
        riskGrade.Down_Payment__c = 14;
        riskGrade.Other_Collateral__c = 'Real';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();        

    }

    @isTest static void test_method_nine() {
                PageReference pref; 

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User loanOfficer = new User();
        loanOfficer.Alias = 'newUser9';
        loanOfficer.Email = 'newUser9@testorg.com';
        loanOfficer.EmailEncodingKey = 'UTF-8';
        loanOfficer.LastName = 'lastName9';
        loanOfficer.LanguageLocaleKey = 'en_US';
        loanOfficer.LocaleSidKey = 'en_US';
        loanOfficer.ProfileId = p.Id;
        loanOfficer.TimeZoneSidKey = 'America/Los_Angeles';
        loanOfficer.UserName = 'newUser9@testorg.com';

        Database.upsertResult loanOfficerResult = Database.upsert(loanOfficer);
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Average__c = 'High 5+';
        acct.Average_Loan_Balance__c = 'Mod 6+';
        acct.NSF_s_or_OD_s__c = '3-5';
        acct.Account_Type__c = 'Both';
        Database.upsertResult accountResult = Database.upsert(acct);

        LLC_BI__Loan__c loan = new LLC_BI__Loan__c();
        loan.LLC_BI__Loan_Officer__c = loanOfficerResult.getId();
        loan.LLC_BI__Account__c = accountResult.getId();
        loan.LLC_BI__Amount__c = 10000;
        loan.Name = 'Banana Loan';
        Database.upsertResult loanResult = Database.upsert(loan);

        Contact cont = new Contact();
        cont.FirstName = 'Banana';
        cont.LastName = 'Rama';
        cont.AccountId = accountResult.getId();
        cont.LLC_BI__Primary_Contact__c = true;
        Database.upsertResult contResult = Database.upsert(cont);

        nCBC__Credit_Report__c creditRep = new nCBC__Credit_Report__c();
        creditRep.nCBC__Contact__c = contResult.getId();
        creditRep.nCBC__FICO_Score__c = 650;
        Database.upsertResult creditRepResult = Database.upsert(creditRep);

        nCBC__Credit_Record__c creditRec = new nCBC__Credit_Record__c();
        creditRec.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec.nCBC__ContactId__c = contResult.getId();
        creditRec.Name = 'Test Record';
        creditRec.nCBC__scoreValue__c = '650';
        creditRec.nCBC__status__c = 'Open';
        creditRec.nCBC__creditType__c = 'Revolving';
        creditRec.nCBC__creditLimit__c = 100000;
        Database.upsertResult creditRecResult = Database.upsert(creditRec);

        nCBC__Credit_Record__c creditRec9 = new nCBC__Credit_Record__c();
        creditRec9.nCBC__CreditReport__c = creditRepResult.getId();
        creditRec9.nCBC__ContactId__c = contResult.getId();
        creditRec9.Name = 'Test Record';
        creditRec9.nCBC__scoreValue__c = '750';
        creditRec9.nCBC__status__c = 'Open';
        creditRec9.nCBC__creditType__c = 'Revolving';
        creditRec9.nCBC__balance__c = 5000;
        Database.upsertResult creditRec9Result = Database.upsert(creditRec9);

        nBCR__Business_Credit_Report__c busCredit = new nBCR__Business_Credit_Report__c();
        busCredit.nBCR__Account__c = accountResult.getId();
        busCredit.nDNB__Trade_Experiences_Reported__c = 1000;
        Database.upsertResult busCreditResult = Database.upsert(busCredit);

        nBCR__Business_Credit_Demographics__c busDemo = new nBCR__Business_Credit_Demographics__c();
        busDemo.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busDemo.nBCR__Years_In_Business__c = 2;
        Database.upsertResult busDemoResult = Database.upsert(busDemo);

        nBCR__Business_Credit_Score__c busScore = new nBCR__Business_Credit_Score__c();
        busScore.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore.nBCR__Score_Description__c = 'Commercial Credit Score';
        busScore.nBCR__Score_Rating__c = '450';
        Database.upsertResult busScoreResult = Database.upsert(busScore);

        nBCR__Business_Credit_Score__c busScore2 = new nBCR__Business_Credit_Score__c();
        busScore2.nBCR__Business_Credit_Report__c = busCreditResult.getId();
        busScore2.nBCR__Score_Description__c = 'Paydex';
        busScore2.nBCR__Score_Rating__c = '60';
        Database.upsertResult busScore2Result = Database.upsert(busScore2);

        RecordType pg = [select id from RecordType where SobjectType='Credit_Risk_Grade__c' and Name='Corporate' Limit 1];

        // Implement test code
        Credit_Risk_Grade__c riskGrade = new Credit_Risk_Grade__c();
        riskGrade.Relationship__c = accountResult.getId();
        riskGrade.Loan_Name__c = loanResult.getId();
        riskGrade.RecordTypeId = pg.Id;
        riskGrade.Net_Income__c = 'Loss';
        riskGrade.Annual_Sales_Volume_CP__c = 'Less than $3mm';
        riskGrade.New_Used__c = 'Used';
        riskGrade.Useful_Life__c = '1-4 Years';
        riskGrade.Revenue_Generating_Essential_Use__c = 'No';
        riskGrade.Down_Payment__c = 5;
        riskGrade.Other_Collateral__c = 'None';
        Database.upsertResult riskgradeResult = Database.upsert(riskGrade);

        pref = Page.CreditGradePGPage;
        pref.getParameters().put('id',riskGrade.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController sc = new ApexPages.StandardController(riskGrade);

        CreditGradeController cgc = new CreditGradeController(sc);        

        cgc.SaveRecord();        

    }    
