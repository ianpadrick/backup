public class CreditGradeController {

    Boolean evidenceValue = false;
    String dateFounded = null;
    Decimal yearsInBusiness = 0;
    String strScore = '0';
    String ofac = '';
    Decimal trade = 0;
    Integer score = 0;
    Decimal ficoScore = 0;
    Decimal revDebtAvailable = 0;
    Decimal revDebtBalance = 0;
    Decimal revDebtAvailability = 0;
    Integer ccsScore = 0;    
    Integer paydexScore = 0;
    

    /*******************
        CBC Variables
    ********************/

    String scoreValue = '';
    Integer intScoreValue = 0;


    Id recordId = ApexPages.currentPage().getParameters().get('id');
    
    ApexPages.StandardController stdController;
    public Boolean refreshPage {get; set;}

    public CreditGradeController(ApexPages.StandardController controller) {
      stdController = controller;
      refreshPage=false;
    }

    public PageReference SaveRecord() {

      // Pull back the current Credit Risk Grade record
      Credit_Risk_Grade__c credit = [
        SELECT 
          Id, 
          Relationship__c, 
          //Evidence_of_Suits_Judgements_Liens__c, 
          Relationship__r.Average__c,
          Relationship__r.Average_Loan_Balance__c,
          Relationship__r.NSF_s_or_OD_s__c,
          Relationship__r.Account_Type__c
        FROM 
          Credit_Risk_Grade__c 
        WHERE 
          Id =: recordId];


    /******************
        D&B Queries 
    *******************/

      // Retrieve and set the Trade Experiences Reported field
      List<nBCR__Business_Credit_Report__c> credRepList = [
                SELECT
                    Id,
                    nDNB__Trade_Experiences_Reported__c,
                    nDNB__Annual_Sales__c
                FROM
                    nBCR__Business_Credit_Report__c
                WHERE
                    nBCR__Account__c =: credit.Relationship__c
                ORDER BY
                    CreatedDate Desc limit 1];

      for (nBCR__Business_Credit_Report__c b : credRepList) {
          if (b.nDNB__Trade_Experiences_Reported__c > 0) {
            trade = b.nDNB__Trade_Experiences_Reported__c;
          } else {
            trade = 0;
          }

        update credRepList;
      }

      // Retrieve and set the Evidence of Judgements, Liens, and Suits field
      List<nBCR__Business_Credit_Report__c> bizReportList = [
                SELECT
                    Id,
                    (
                      SELECT
                          Id,
                          nDNB__Judgment_Count__c,
                          nDNB__Lien_Count__c,
                          nDNB__Suit_Found__c
                      FROM 
                          nDNB__Business_Judgments__r
                      ORDER BY
                          CreatedDate Desc limit 1
                    )
                FROM
                    nBCR__Business_Credit_Report__c
                WHERE
                    nBCR__Account__c =: credit.Relationship__c
                ORDER BY
                    CreatedDate Desc limit 1];

      for (nBCR__Business_Credit_Report__c bcr : bizReportList) {
        for (nDNB__Business_Credit_Judgment__c judge : bcr.nDNB__Business_Judgments__r) {
          if (judge.nDNB__Judgment_Count__c > 0 || judge.nDNB__Lien_Count__c > 0 || judge.nDNB__Suit_Found__c == True) {
            evidenceValue = True;
          } else {
            evidenceValue = False;
          }
        }

        update bizReportList;
      }

      // Retrieve and set the Time in Business and Date Established fields
      List<nBCR__Business_Credit_Report__c> bizList = [
                SELECT
                    Id,
                    (
                      SELECT
                          Id,
                          nBCR__Years_In_Business__c,
                          nBCR__Date_Founded__c,
                          nBCR__Incorporation_Year__c
                      FROM 
                          nBCR__Business_Demographics__r
                      ORDER BY
                          CreatedDate Desc limit 1
                    )
                FROM
                    nBCR__Business_Credit_Report__c
                WHERE
                    nBCR__Account__c =: credit.Relationship__c
                ORDER BY
                    CreatedDate Desc limit 1];

      for (nBCR__Business_Credit_Report__c bizCred : bizList) {
        for (nBCR__Business_Credit_Demographics__c j : bizCred.nBCR__Business_Demographics__r) {
          if (j.nBCR__Years_In_Business__c > 0) {
            yearsInBusiness = j.nBCR__Years_In_Business__c;
          } else {
            yearsInBusiness = 0;
          }

          if (j.nBCR__Date_Founded__c != null) {
            dateFounded = String.valueOf(j.nBCR__Date_Founded__c);
          } else if(j.nBCR__Incorporation_Year__c != null) {
            dateFounded = j.nBCR__Incorporation_Year__c;
          } else{
            dateFounded = null;
          }
        }

        update bizList;
      }

        //Query for DnB Score Types and set score field
        List<nBCR__Business_Credit_Score__c> bizCredList = [
                SELECT 
                    Id, 
                    nBCR__Score__c, nBCR__Score_Rating__c, 
                    nBCR__Score_Description__c, nBCR__Score_Code__c 
                FROM 
                    nBCR__Business_Credit_Score__c 
                WHERE 
                    nBCR__Business_Credit_Report__r.nBCR__Account__c =: credit.Relationship__c ];

        for (nBCR__Business_Credit_Score__c biz : bizCredList) {
           
           if (biz.nBCR__Score_Description__c == 'Commercial Credit Score') {
              score = Integer.valueOf(biz.nBCR__Score_Rating__c);
           } else if (biz.nBCR__Score_Description__c == 'Commercial Credit Score Percentile') {
              ccsScore = Integer.valueOf(biz.nBCR__Score_Rating__c);
           } else if (biz.nBCR__Score_Description__c.containsIgnoreCase('Paydex')) {
              paydexScore = Integer.valueOf(biz.nBCR__Score_Rating__c);
           }


        }
        update bizCredList;

    /******************
        CBC Queries 
    *******************/

      List<Contact> contList = [
                SELECT
                    Id,
                    (
                      SELECT
                          Id,
                          nCBC__FICO_Score__c,
                          nCBC__OFAC__c
                      FROM
                          nCBC__Credit_Reports__r
                      ORDER BY
                          CreatedDate Desc limit 1
                    )
                FROM
                    Contact
                WHERE
                    AccountId =: credit.Relationship__c 
                AND 
                    LLC_BI__Primary_Contact__c = true
                ORDER BY
                    CreatedDate Desc limit 1];

      for (Contact con : contList) {
        for (nCBC__Credit_Report__c cRec : con.nCBC__Credit_Reports__r) {

          system.debug('*** Fico Score: ' + cRec.nCBC__FICO_Score__c);

          if (cRec.nCBC__FICO_Score__c > 0) {
            ficoScore = cRec.nCBC__FICO_Score__c;
          } else {
            ficoScore = null;
          }

          if (cRec.nCBC__OFAC__c != '') {
            ofac = cRec.nCBC__OFAC__c;
          } else {
            ofac = '';
          }
        }

        update contList;
      }


      // Retrieve and set the D&B Score field
      List<nCBC__Credit_Report__c> reportList = [
                SELECT
                    Id,
                    (
                      SELECT
                          Id,
                          nCBC__scoreValue__c
                      FROM 
                          nCBC__Credit_Records1__r
                      WHERE
                         nCBC__scoreValue__c != null
                    )
                FROM
                    nCBC__Credit_Report__c
                WHERE
                    nCBC__Contact__r.AccountId =: credit.Relationship__c
                ORDER BY
                    CreatedDate Desc limit 1];

      for (nCBC__Credit_Report__c cred : reportList) {
        for (nCBC__Credit_Record__c rec : cred.nCBC__Credit_Records1__r) {

          system.debug('*** Score Value: ' + rec.nCBC__scoreValue__c);

          if (rec.nCBC__scoreValue__c != null) {
            scoreValue = rec.nCBC__scoreValue__c;
            Integer scoreValueINTEGER = Integer.ValueOf(scoreValue);
            intScoreValue = scoreValueINTEGER;
          } else {
            scoreValue = '0';
            Integer scoreValueINTEGER = Integer.ValueOf(scoreValue);
            intScoreValue = scoreValueINTEGER;
          }

        update reportList;
        }
      }

      //Summations of Delinquincy types
      Integer counter1 = [ 
                      SELECT
                          COUNT()
                      FROM 
                          nCBC__Credit_Record__c
                      WHERE
                        nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                      AND
                        nCBC__delinqOver30Days__c != null];

      if (counter1 == null) {
        counter1 = 0;
      }

      Integer counter2 = [ 
                      SELECT
                          COUNT()
                      FROM 
                          nCBC__Credit_Record__c
                      WHERE
                        nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                      AND
                        nCBC__delinqOver60Days__c != null];

      if (counter2 == null) {
        counter2 = 0;
      }

      Integer counter3 = [ 
                      SELECT
                          COUNT()
                      FROM 
                          nCBC__Credit_Record__c
                      WHERE
                        nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                      AND
                        nCBC__delinqOver90Days__c != null];

      if (counter3 == null) {
        counter3 = 0;
      }

      //Summation of Chargeoffs
      Integer chargeOffs = [ 
                      SELECT
                          COUNT()
                      FROM 
                          nCBC__Credit_Record__c
                      WHERE
                        nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                      AND
                        nCBC__status__c = 'Collections'];

      if (chargeOffs == null) {
        chargeOffs = 0;
      }

      //Summation of Mortgages
      Integer ownsHome = [ 
                      SELECT
                          COUNT()
                      FROM 
                          nCBC__Credit_Record__c
                      WHERE
                        nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                      AND
                        nCBC__creditType__c = 'Mortgage'];

      if (ownsHome == null) {
        ownsHome = 0;
      }

      //Summation of Bankruptcys
      Integer bankruptcy = [ 
                      SELECT
                          COUNT()
                      FROM 
                          nCBC__Credit_Record__c
                      WHERE
                        nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                      AND
                        nCBC__bankruptLiabAmt__c > 0];

      if (bankruptcy == null) {
        bankruptcy = 0;
      }

      //Summations of Debt Available and Balances
      Decimal debtAvailable = (Decimal) [SELECT SUM(nCBC__creditLimit__c)total FROM nCBC__Credit_Record__c 
                                         WHERE nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                                         AND (nCBC__creditType__c = 'Revolving' AND nCBC__status__c = 'Open')][0].get('total');

      Decimal debtBalance = (Decimal) [SELECT SUM(nCBC__balance__c)total FROM nCBC__Credit_Record__c 
                                         WHERE nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credit.Relationship__c
                                         AND (nCBC__creditType__c = 'Revolving' AND nCBC__status__c = 'Open')][0].get('total');

      //Calculate Revolving Debt Availability Percentage
      if(debtBalance != null){
        Decimal revDebtAvailability = debtBalance/debtAvailable;
      }else{
        Decimal revDebtAvailability = 0;
      }

      // Get the current Credit Risk Grade record
      Credit_Risk_Grade__c c = (Credit_Risk_Grade__c)stdController.getRecord();

      Map<String, Schema.RecordTypeInfo> creditGradeTypeInfo = Schema.Credit_Risk_Grade__c.SObjectType.getDescribe().getRecordTypeInfosByName();
      
      Decimal busCS = 0, perCS = 0, tcCS = 0, bankCS = 0, finCS = 0, creditScore = 0;

      c.Evidence_of_Suits_Judgements_Liens__c = evidenceValue;
      c.Date_Established2__c = dateFounded;
      c.Time_in_business__c = yearsInBusiness;
      c.D_B_Score__c = score;
      c.Number_of_Trade_Experiences_PG__c = trade;
      c.FICO_Score_PG__c = ficoScore;
      c.OFAC_Status__c = ofac;
      c.FICO_Score_Range__c = intScoreValue;
      c.Slow_Pays__c = counter1 + counter2 + counter3;
      c.Charge_Offs__c = chargeOffs;
      c.Owns_Home_Property__c = ownsHome;
      c.Bankruptcy__c = bankruptcy;
      c.Revolving_Debt_Balance__c = debtBalance;
      c.D_B_CCS_Score__c = ccsScore;
      c.Paydex_D_B_Score__c = paydexScore;
      c.Debt_Availability__c = revDebtAvailability * 100;
      c.Final_Risk_Grade__c = 0;
      
      // Personal Guarantee Record Type
      if (c.RecordTypeId == creditGradeTypeInfo.get('Personal Guarantee').getRecordTypeId()) {

        /******************
          BUSINESS SECTION
        ********************/

        // Time in Business
        if (c.Time_in_business__c < 23) {
          busCS += 0;
          c.Time_in_Business_Pts__c = 0;
        }
        else if (c.Time_in_business__c >= 23 && c.Time_in_business__c < 36) {
          busCS += 2;
          c.Time_in_Business_Pts__c = 2;
        }
        else if (c.Time_in_business__c >= 36 && c.Time_in_business__c < 60) {
          busCS += 5;
          c.Time_in_Business_Pts__c = 5;
        }
        else if (c.Time_in_business__c >= 60) {
          busCS += 10;
          c.Time_in_Business_Pts__c = 10;
        }

        // Paydex score
        if (c.Paydex_D_B_Score__c < 67) {
          busCS += 0;
          c.Paydex_D_B_Score_Pts__c = 0;
        }
        else if (c.Paydex_D_B_Score__c >= 67 && c.Paydex_D_B_Score__c < 75) {
          busCS += 10;
          c.Paydex_D_B_Score_Pts__c = 10;
        }
        else if (c.Paydex_D_B_Score__c >= 75) {
          busCS += 20;
          c.Paydex_D_B_Score_Pts__c = 20;
        }

        // Number of Trade Experiences
        if (c.Number_of_Trade_Experiences_PG__c >= 5 && c.Number_of_Trade_Experiences_PG__c < 999) {
          busCS +=3;
          c.of_Trade_Experiences_Pts__c = 3;
        }
        else if (c.Number_of_Trade_Experiences_PG__c >= 1000) {
          busCS += 15;
          c.of_Trade_Experiences_Pts__c = 15;
        }

        // DnB Score
        if (c.D_B_Score__c >= 400 && c.D_B_Score__c < 475) {
          busCS += 2;
          c.D_B_Score_Pts__c = 2;
        }
        else if (c.D_B_Score__c >= 475 && c.D_B_Score__c < 525) {
          busCS += 10;
          c.D_B_Score_Pts__c = 10;
        }
        else if (c.D_B_Score__c >= 525) {
          busCS += 20;
          c.D_B_Score_Pts__c = 20;
        }

        /******************
          PERSONAL SECTION
        ********************/

        // FICO Score
        if (c.FICO_Score_Range__c >= 640 && c.FICO_Score_Range__c < 680) {
          perCS += 10;
          c.FICO_Score_Range_Pts__c = 10;
        }
        if(c.FICO_Score_Range__c >= 680 && c.FICO_Score_Range__c < 726) {
          perCS += 30;
          c.FICO_Score_Range_Pts__c = 30;
        }
        if(c.FICO_Score_Range__c >= 726) {
          perCS += 40;
          c.FICO_Score_Range_Pts__c = 40;
        }

        // Revolving debt available
        if (c.Debt_Availability__c >= 30 && c.Debt_Availability__c <= 60) {
          perCS += 2;
          c.Revolving_Debt_Available_Pts__c = 2;
        }
        else if (c.Debt_Availability__c >= 61 && c.Debt_Availability__c <= 99) {
          perCS += 7;
          c.Revolving_Debt_Available_Pts__c = 7;
        }
        else if (c.Debt_Availability__c == 100) {
          perCS += 10;
          c.Revolving_Debt_Available_Pts__c = 10;
        }

        // Owns home property
        if (c.Owns_Home_Property__c < 1) {
          perCS += 0;
          c.Owns_Home_Property_Pts__c = 0;
        }
        else if (c.Owns_Home_Property__c >=1 && c.Owns_Home_Property__c < 5) {
          perCS += 1;
          c.Owns_Home_Property_Pts__c = 1;
        }
        else if (c.Owns_Home_Property__c > 5) {
          perCS += 2;
          c.Owns_Home_Property_Pts__c = 2;
        }

        // Slow pays 
        if (c.Slow_Pays__c >= 2) {
          perCS += 0;
          c.Slow_Pays_Pts__c = 0;
        }
        else if (c.Slow_Pays__c == 1) {
          perCS += 5;
          c.Slow_Pays_Pts__c = 5;
        }
        else if (c.Slow_Pays__c == 0) {
          perCS += 6;
          c.Slow_Pays_Pts__c = 6;
        }

        // Charge offs
        if (c.Charge_Offs__c == 0) {
          perCS += 4;
          c.Charge_Offs_Pts__c = 4;
        }
        else if (c.Charge_Offs__c == 1) {
          perCS += 2;
          c.Charge_Offs_Pts__c = 2;
        }
        else if (c.Charge_Offs__c >= 2) {
          perCS += 0;
          c.Charge_Offs_Pts__c = 0;
        }

        // Bankruptcy
        if (c.Bankruptcy__c == 0) {
          perCS += 5;
          c.Bankruptcy_Pts__c = 5;
        }
        else if (c.Bankruptcy__c >= 1 && c.Bankruptcy__c < 5) {
          perCS +=3;
          c.Bankruptcy_Pts__c = 3;
        }
        else if (c.Bankruptcy__c>=5) {
          perCS +=0;
          c.Bankruptcy_Pts__c = 0;
        }

        /*********************
          COLLATERAL SECTION
        **********************/

        // New or Used Collateral
        if (c.New_Used__c == 'Used')
          tcCS += 0;
        else if (c.New_Used__c == 'New')
          tcCS += 2;

        // Useful Life
        if (c.Useful_Life__c == '1-4 Years')
          tcCS += 0;
        else if (c.Useful_Life__c == '5-7 Years')
          tcCS += 1;
        else if (c.Useful_Life__c == '7+ Years')
          tcCS += 2;

        // Revenue Generating Essential
        if (c.Revenue_Generating_Essential_Use__c == 'Y - IM')
          tcCS += 2;
        else if (c.Revenue_Generating_Essential_Use__c == 'Y - CR')
          tcCS += 3;
        else if (c.Revenue_Generating_Essential_Use__c == 'No')
          tcCS += 0;

        // Down Payment
        if (c.Down_Payment__c < 10)
          tcCS += 0;
        else if (c.Down_Payment__c >= 10 && c.Down_Payment__c < 15)
          tcCS += 2;
        else if (c.Down_Payment__c >= 15)
          tcCS += 3;

        // Other Collateral
        if (c.Other_Collateral__c == 'None')
          tcCS += 0;
        else if (c.Other_Collateral__c == 'Blanket')
          tcCS += 2;
        else if (c.Other_Collateral__c == 'Real') 
          tcCS += 7; 

        /*************************
          BANK REFERENCE SECTION
        **************************/

        // Account Type
        if (credit.Relationship__r.Account_Type__c == 'Loan')
          bankCS += 1;
        else if (credit.Relationship__r.Account_Type__c == 'Deposit')
          bankCS += 1;
        else if (credit.Relationship__r.Account_Type__c == 'Both')
          bankCS += 2;

        // Average Deposit Balance
        if (credit.Relationship__r.Average__c == 'Low 4 - Mod 4')
          bankCS += 0;
        else if (credit.Relationship__r.Average__c == 'High 4 - Mod 5')
          bankCS += 1;
        else if (credit.Relationship__r.Average__c == 'High 5+')
          bankCS += 2;

        // Average Loan Balance
        if (credit.Relationship__r.Average_Loan_Balance__c == '0 - Low 5')
          bankCS += 0;
        else if (credit.Relationship__r.Average_Loan_Balance__c == 'Low 5 - Low 6')
          bankCS += 1;
        else if (credit.Relationship__r.Average_Loan_Balance__c == 'Mod 6+')
          bankCS += 2;

        // NSF's or OD's
        if (credit.Relationship__r.NSF_s_or_OD_s__c == '0')
          bankCS += 2;
        else if (credit.Relationship__r.NSF_s_or_OD_s__c == '1-2')
          bankCS += 0;
        else if (credit.Relationship__r.NSF_s_or_OD_s__c == '3-5')
          bankCS -= 5;

        //Calculate Overall Score and set variables
        creditScore = busCS+perCS+tcCS+bankCS;
        c.Business_Score__c = busCS;
        c.Personal_Score__c = perCS;
        c.Total_Collateral_Score__c = tcCS;
        c.Bank_Score__c = bankCS;

        c.Overall_Credit_Score__c = creditScore;

        if (creditScore <= 59)
          c.Final_Risk_Grade__c = 7;
        else if (creditScore >= 60 && creditScore <= 79)
          c.Final_Risk_Grade__c = 6;
        else if (creditScore >= 80 && creditScore <= 94)
          c.Final_Risk_Grade__c = 5;
        else if (creditScore >= 95 && creditScore <= 124)
          c.Final_Risk_Grade__c = 4;
        else if (creditScore >= 125)
          c.Final_Risk_Grade__c = 3;

        // Medical Record Type
      } else if (c.RecordTypeId == creditGradeTypeInfo.get('Medical').getRecordTypeId()) {

        /******************
          BUSINESS SECTION
        ********************/

        // Years Licensed
        if (c.Years_Licensed__c < 3){
          busCS += 13;
          c.Years_Licensed_Pts__c = 13;
        }
        else if (c.Years_Licensed__c >= 3 && c.Years_Licensed__c <= 4) {
          busCS += 22;
          c.Years_Licensed_Pts__c = 22;
        }
        else if (c.Years_Licensed__c > 4) {
          busCS += 32;
          c.Years_Licensed_Pts__c = 32;
        }

        //Practice Type
        if (c.Practice_Type__c == 'Chiro'){
          busCS += 7;
          c.Practice_Type_Pts__c = 7;
        }
        else if (c.Practice_Type__c == 'MD') {
          busCS += 10;
          c.Practice_Type_Pts__c = 10;
        }
        else if (c.Practice_Type__c =='Spec') {
          busCS += 15;
          c.Practice_Type_Pts__c = 15;
        }

        // Paydex score
        if (c.Paydex_D_B_Score__c < 67) {
          busCS += 0;
          c.Paydex_D_B_Score_Pts__c = 0;
        }
        else if (c.Paydex_D_B_Score__c >= 67 && c.Paydex_D_B_Score__c < 75) {
          busCS += 10;
          c.Paydex_D_B_Score_Pts__c = 10;
        }
        else if (c.Paydex_D_B_Score__c >= 75) {
          busCS += 20;
          c.Paydex_D_B_Score_Pts__c = 20;
        }

      
        /******************
          PERSONAL SECTION
        ********************/

        // FICO Score
        if (c.FICO_Score_Range__c >= 640 && c.FICO_Score_Range__c < 680) {
          perCS += 10;
          c.FICO_Score_Range_Pts__c = 10;
        }
        if(c.FICO_Score_Range__c >= 680 && c.FICO_Score_Range__c < 726) {
          perCS += 30;
          c.FICO_Score_Range_Pts__c = 30;
        }
        if(c.FICO_Score_Range__c >= 726) {
          perCS += 40;
          c.FICO_Score_Range_Pts__c = 40;
        }

        // Revolving debt available
        if (c.Debt_Availability__c >= 30 && c.Debt_Availability__c <= 60) {
          perCS += 2;
          c.Revolving_Debt_Available_Pts__c = 2;
        }
        else if (c.Debt_Availability__c >= 61 && c.Debt_Availability__c <= 99) {
          perCS += 7;
          c.Revolving_Debt_Available_Pts__c = 7;
        }
        else if(c.Debt_Availability__c == 100){
          perCS += 10;
          c.Revolving_Debt_Available_Pts__c = 10;
        }

        // Owns home property
        if (c.Owns_Home_Property__c < 1) {
          perCS += 0;
          c.Owns_Home_Property_Pts__c = 0;
        }
        else if (c.Owns_Home_Property__c >=1 && c.Owns_Home_Property__c < 5) {
          perCS += 1;
          c.Owns_Home_Property_Pts__c = 1;
        }
        else if (c.Owns_Home_Property__c > 5) {
          perCS += 2;
          c.Owns_Home_Property_Pts__c = 2;
        }

        // Slow pays 
        if (c.Slow_Pays__c >= 2) {
          perCS += 0;
          c.Slow_Pays_Pts__c = 0;
        }
        else if (c.Slow_Pays__c == 1) {
          perCS += 5;
          c.Slow_Pays_Pts__c = 5;
        }
        else if (c.Slow_Pays__c == 0) {
          perCS += 6;
          c.Slow_Pays_Pts__c = 6;
        }

        // Charge offs
        if (c.Charge_Offs__c == 0) {
          perCS += 4;
          c.Charge_Offs_Pts__c = 4;
        }
        else if (c.Charge_Offs__c == 1) {
          perCS += 2;
          c.Charge_Offs_Pts__c = 2;
        }
        else if (c.Charge_Offs__c >= 2) {
          perCS += 0;
          c.Charge_Offs_Pts__c = 0;
        }

        // Bankruptcy
        if (c.Bankruptcy__c == 0) {
          perCS += 5;
          c.Bankruptcy_Pts__c = 5;
        }
        else if (c.Bankruptcy__c >= 1 && c.Bankruptcy__c < 5) {
          perCS +=3;
          c.Bankruptcy_Pts__c = 3;
        }
        else if (c.Bankruptcy__c>=5) {
          perCS +=0;
          c.Bankruptcy_Pts__c = 0;
        }

        /*********************
          COLLATERAL SECTION
        **********************/

        // New/Used Collateral
        if (c.New_Used__c == 'Used')
          tcCS += 0;
        else if (c.New_Used__c == 'New')
          tcCS += 2;

        // Useful Life
        if (c.Useful_Life__c == '1-4 Years')
          tcCS += 0;
        else if (c.Useful_Life__c == '5-7 Years')
          tcCS += 1;
        else if (c.Useful_Life__c == '7+ Years')
          tcCS += 2;

        // Revenuve Generating Essential
        if (c.Revenue_Generating_Essential_Use__c == 'Y - IM')
          tcCS += 2;
        else if (c.Revenue_Generating_Essential_Use__c == 'Y - CR')
          tcCS += 3;
        else if (c.Revenue_Generating_Essential_Use__c == 'No')
          tcCS += 0;

        // Down Payment
        if (c.Down_Payment__c < 10)
          tcCS += 0;
        else if (c.Down_Payment__c >= 10 && c.Down_Payment__c < 15)
          tcCS += 2;
        else if (c.Down_Payment__c >= 15)
          tcCS += 3;

        // Other Collateral
        if (c.Other_Collateral__c == 'None')
          tcCS += 0;
        else if (c.Other_Collateral__c == 'Blanket')
          tcCS += 2;
        else if (c.Other_Collateral__c == 'Real') 
          tcCS += 7; 

        /*************************
          BANK REFERENCE SECTION
        **************************/

        // Account Type
        if (credit.Relationship__r.Account_Type__c == 'Loan')
          bankCS += 1;
        else if (credit.Relationship__r.Account_Type__c == 'Deposit')
          bankCS += 1;
        else if (credit.Relationship__r.Account_Type__c == 'Both')
          bankCS += 2;

        // Average Deposit Balance
        if (credit.Relationship__r.Average__c == 'Low 4 - Mod 4')
          bankCS += 0;
        else if (credit.Relationship__r.Average__c == 'High 4 - Mod 5')
          bankCS += 1;
        else if (credit.Relationship__r.Average__c == 'High 5+')
          bankCS += 2;

        // Average Loan Balance
        if (credit.Relationship__r.Average_Loan_Balance__c == '0 - Low 5')
          bankCS += 0;
        else if (credit.Relationship__r.Average_Loan_Balance__c == 'Low 5 - Low 6')
          bankCS += 1;
        else if (credit.Relationship__r.Average_Loan_Balance__c == 'Mod 6+')
          bankCS += 2;

        // NSF's or OD's
        if (credit.Relationship__r.NSF_s_or_OD_s__c == '0')
          bankCS += 2;
        else if (credit.Relationship__r.NSF_s_or_OD_s__c == '1-2')
          bankCS += 0;
        else if (credit.Relationship__r.NSF_s_or_OD_s__c == '3-5')
          bankCS -= 5;

        //Calculate Overall Score and set variables
        creditScore = busCS+perCS+tcCS+bankCS;
        c.Business_Score__c = busCS;
        c.Personal_Score__c = perCS;
        c.Total_Collateral_Score__c = tcCS;
        c.Bank_Score__c = bankCS;

        c.Overall_Credit_Score__c = creditScore;

        if (creditScore <= 59)
          c.Final_Risk_Grade__c = 7;
        else if (creditScore >= 60 && creditScore <= 79)
          c.Final_Risk_Grade__c = 6;
        else if (creditScore >= 80 && creditScore <= 94)
          c.Final_Risk_Grade__c = 5;
        else if (creditScore >= 95 && creditScore <= 124)
          c.Final_Risk_Grade__c = 4;
        else if (creditScore >= 125)
          c.Final_Risk_Grade__c = 3;


        // Corporate Record Type
      } else if (c.RecordTypeId == creditGradeTypeInfo.get('Corporate').getRecordTypeId()) {
        
        /******************
          BUSINESS SECTION
        ********************/

        // Time in Business
        if (c.Time_in_business__c < 23) {
          busCS += 0;
          c.Time_in_Business_Pts__c =  0;
        }
        else if (c.Time_in_business__c >= 23 && c.Time_in_business__c < 36)  {
          busCS += 2;
          c.Time_in_Business_Pts__c =  2;
        }
        else if (c.Time_in_business__c >= 36 && c.Time_in_business__c < 83)  {
          busCS += 15;
          c.Time_in_Business_Pts__c = 15;
        }
        else if (c.Time_in_business__c >= 83)  {
          busCS += 30;
          c.Time_in_Business_Pts__c = 30;
        }

        // Paydex score
        if (c.Paydex_D_B_Score__c < 67) {
          busCS += 0;
          c.Paydex_D_B_Score_Pts__c = 0;
        }
        else if (c.Paydex_D_B_Score__c >= 67 && c.Paydex_D_B_Score__c < 75) {
          busCS += 10;
          c.Paydex_D_B_Score_Pts__c = 10;
        }
        else if (c.Paydex_D_B_Score__c >= 75) {
          busCS += 20;
          c.Paydex_D_B_Score_Pts__c = 20;
        }

        // Number of Trade Experiences
        if (c.Number_of_Trade_Experiences_PG__c >= 5 && c.Number_of_Trade_Experiences_PG__c < 999) {
          busCS +=5;
          c.of_Trade_Experiences_Pts__c = 5;
        }
        else if (c.Number_of_Trade_Experiences_PG__c >= 1000) {
          busCS += 10;
          c.of_Trade_Experiences_Pts__c = 10;
        }

        // DnB Score
        if (c.D_B_Score__c >= 400 && c.D_B_Score__c < 475) {
          busCS += 5;
          c.D_B_Score_Pts__c =  5;
        }
        else if (c.D_B_Score__c >= 475 && c.D_B_Score__c < 525) {
          busCS += 15;
          c.D_B_Score_Pts__c = 15;
        }
        else if (c.D_B_Score__c >= 525) {
          busCS += 25;
          c.D_B_Score_Pts__c = 25;
        }
      
        /**************************
          FINANCIAL SCORE SECTION
        ***************************/

        // Net Income
        if (c.Net_Income__c == 'Loss')  {
          finCS -= 20;
          c.Net_Income_Pts__c = 20;
        }
        else if (c.Net_Income__c == 'Profit') {
          finCS += 5;
          c.Net_Income_Pts__c =  5;
        }
        else if (c.Net_Income__c == 'Profit3') {
          finCS += 10;
          c.Net_Income_Pts__c = 10;
        }

        // Annual Sales Volume
        if (c.Annual_Sales_Volume_CP__c == 'Less than $3mm') {
          finCS += 2;
          c.Annual_Sales_Volume_Pts__c =  2;
        }
        else if (c.Annual_Sales_Volume_CP__c == '$3mm to $7mm') {
          finCS += 5;
          c.Annual_Sales_Volume_Pts__c =  5;
        }
        else if (c.Annual_Sales_Volume_CP__c == '$7mm+') {
          finCS += 10;
          c.Annual_Sales_Volume_Pts__c = 10;
        }

        /*********************
          COLLATERAL SECTION
        **********************/

        // New/Used Collateral
        if (c.New_Used__c == 'Used')
          tcCS += 0;
        else if (c.New_Used__c == 'New')
          tcCS += 2;

        // Useful Life
        if (c.Useful_Life__c == '1-4 Years')
          tcCS += 0;
        else if (c.Useful_Life__c == '5-7 Years')
          tcCS += 1;
        else if (c.Useful_Life__c == '7+ Years')
          tcCS += 2;

        // Revenue Generating Essential
        if (c.Revenue_Generating_Essential_Use__c == 'Y - IM')
          tcCS += 2;
        else if (c.Revenue_Generating_Essential_Use__c == 'Y - CR')
          tcCS += 3;
        else if (c.Revenue_Generating_Essential_Use__c == 'No')
          tcCS += 0;

        // Down Payment
        if (c.Down_Payment__c < 10)
          tcCS += 0;
        else if (c.Down_Payment__c >= 10 && c.Down_Payment__c < 15)
          tcCS += 2;
        else if (c.Down_Payment__c >= 15)
          tcCS += 3;

        // Other Collateral
        if (c.Other_Collateral__c == 'None')
          tcCS += 0;
        else if (c.Other_Collateral__c == 'Blanket')
          tcCS += 2;
        else if (c.Other_Collateral__c == 'Real') 
          tcCS += 7; 

        /*************************
          BANK REFERENCE SECTION
        **************************/

        // Account Type
        if (credit.Relationship__r.Account_Type__c == 'Loan')
          bankCS += 1;
        else if (credit.Relationship__r.Account_Type__c == 'Deposit')
          bankCS += 1;
        else if (credit.Relationship__r.Account_Type__c == 'Both')
          bankCS += 2;

        // Average Deposit Balance
        if (credit.Relationship__r.Average__c == 'Low 4 - Mod 4')
          bankCS += 0;
        else if (credit.Relationship__r.Average__c == 'High 4 - Mod 5')
          bankCS += 1;
        else if (credit.Relationship__r.Average__c == 'High 5+')
          bankCS += 2;

        // Average Loan Balance
        if (credit.Relationship__r.Average_Loan_Balance__c == '0 - Low 5')
          bankCS += 0;
        else if (credit.Relationship__r.Average_Loan_Balance__c == 'Low 5 - Low 6')
          bankCS += 1;
        else if (credit.Relationship__r.Average_Loan_Balance__c == 'Mod 6+')
          bankCS += 2;

        // NSF's or OD's
        if (credit.Relationship__r.NSF_s_or_OD_s__c == '0')
          bankCS += 2;
        else if (credit.Relationship__r.NSF_s_or_OD_s__c == '1-2')
          bankCS += 0;
        else if (credit.Relationship__r.NSF_s_or_OD_s__c == '3-5')
          bankCS -= 5;

        //Calculate Overall Score and set variables
        creditScore = busCS+finCS+tcCS+bankCS;
        c.Business_Score__c = busCS;
        c.Financial_Score__c = finCS;
        c.Total_Collateral_Score__c = tcCS;
        c.Bank_Score__c = bankCS;

        c.Overall_Credit_Score__c = creditScore;

        if (creditScore <= 59)
          c.Final_Risk_Grade__c = 7;
        else if (creditScore >= 60 && creditScore <= 79)
          c.Final_Risk_Grade__c = 6;
        else if (creditScore >= 80 && creditScore <= 94)
          c.Final_Risk_Grade__c = 5;
        else if (creditScore >= 95 && creditScore <= 124)
          c.Final_Risk_Grade__c = 4;
        else if (creditScore >= 125)
          c.Final_Risk_Grade__c = 3;

      }

      update credit;

      // calling standard save() method
      stdController.save();
      // return 'null' to stay on same page
      PageReference pageRef = new PageReference('/' + recordId);

      return pageRef;
    }
}
