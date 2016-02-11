public class CreditRiskGradeController {

    /*******************
      Public Variables
    ********************/
    public ApexPages.StandardController stdController;
    public Id accId;
    public String loanName;
    public Id recTypeId;
    public String recTypeName;
    public Id recordId;
    public Decimal overridePoints = 0;

    /*******************
        D&B Variables
    ********************/
    public Decimal trade = 0;
    public Boolean evidenceValue = false;
    public Decimal yearsInBusiness = 0;
    public String dateFounded = '';
    public Integer score = 0;
    public Integer ccsPercent = 0;
    public Integer paydexScore = 0;

    /*******************
        CBC Variables
    ********************/
    public Decimal ficoScore = 0;
    public String ofac = '';
    public Integer scoreValue = 0;
    public String bankruptcies = 'No';
    public Decimal revDebtAvailability = 0;

    public CreditRiskGradeController(ApexPages.StandardController controller) {
        stdController = controller;

        Credit_Risk_Grade__c c = [SELECT 
                Id, 
                Relationship__c,
                Loan_Name__c,
                RecordTypeId,
                RecordType.DeveloperName
            FROM 
                Credit_Risk_Grade__c 
            WHERE 
                Id =: ApexPages.currentPage().getParameters().get('id')];
        
        recordId = c.Id;
        accId = c.Relationship__c;
        loanName = c.Loan_Name__c;
        recTypeId = c.RecordTypeId;
        recTypeName = c.RecordType.DeveloperName;
    }

    public PageReference queryDNBRecords() {
        List<nBCR__Business_Credit_Report__c> credRepList = [SELECT
                Id,
                nBCR__Account__c,
                nDNB__Trade_Experiences_Reported__c
            FROM
                nBCR__Business_Credit_Report__c
            WHERE
                nBCR__Account__c =: accId
            ORDER BY
                CreatedDate Desc LIMIT 1];

        Id bizReportId;
        if (credRepList.size() > 0) {
            bizReportId = credRepList[0].Id;
        }

        for (nBCR__Business_Credit_Report__c b : credRepList) {
            if (b.nDNB__Trade_Experiences_Reported__c > 0) {
                trade = b.nDNB__Trade_Experiences_Reported__c;
            }
        }

        List<nDNB__Business_Credit_Judgment__c> judgeList = [SELECT
                Id,
                nDNB__Judgment_Count__c,
                nDNB__Lien_Count__c,
                nDNB__Suit_Found__c
            FROM 
                nDNB__Business_Credit_Judgment__c
            WHERE
                nDNB__Business_Credit_Report__c =: bizReportId
            AND
                nDNB__Business_Credit_Report__r.nBCR__Account__c =: accId
            ORDER BY
                CreatedDate Desc limit 1];
        for (nDNB__Business_Credit_Judgment__c j : judgeList) {
            if (j.nDNB__Judgment_Count__c > 0 || j.nDNB__Lien_Count__c > 0 || j.nDNB__Suit_Found__c == true) {
                evidenceValue = true;
            }
        }

        List<nBCR__Business_Credit_Demographics__c> demoList = [SELECT
                Id,
                nBCR__Years_In_Business__c,
                nBCR__Date_Founded__c,
                nBCR__Incorporation_Year__c
            FROM 
                nBCR__Business_Credit_Demographics__c
            WHERE
                nBCR__Business_Credit_Report__c =: bizReportId
            AND
                nBCR__Business_Credit_Report__r.nBCR__Account__c =: accId
            ORDER BY
                CreatedDate Desc limit 1];
        for (nBCR__Business_Credit_Demographics__c d : demoList) {
            if (d.nBCR__Years_In_Business__c > 0) {
                yearsInBusiness = d.nBCR__Years_In_Business__c;
            }

            if (d.nBCR__Date_Founded__c != null) {
                dateFounded = String.valueOf(d.nBCR__Date_Founded__c);
            } else if (d.nBCR__Incorporation_Year__c != null) {
                dateFounded = d.nBCR__Incorporation_Year__c;
            }
        }

        List<nBCR__Business_Credit_Score__c> scoreList = [SELECT
                Id,
                nBCR__Score__c,
                nBCR__Score_Rating__c,
                nBCR__Score_Description__c,
                nBCR__Score_Code__c
            FROM 
                nBCR__Business_Credit_Score__c
            WHERE
                nBCR__Business_Credit_Report__c =: bizReportId
            AND
                nBCR__Business_Credit_Report__r.nBCR__Account__c =: accId
            ORDER BY
                CreatedDate Desc limit 1];
        for (nBCR__Business_Credit_Score__c s : scoreList) {
            if (s.nBCR__Score_Description__c == 'Commercial Credit Score') {
                score = Integer.ValueOf(s.nBCR__Score_Rating__c);
            } else if (s.nBCR__Score_Description__c == 'Commercial Credit Score Percentile') {
                ccsPercent = Integer.ValueOf(s.nBCR__Score_Rating__c);
            } else if (s.nBCR__Score_Description__c.containsIgnoreCase('Paydex')) {
                paydexScore = Integer.ValueOf(s.nBCR__Score_Rating__c);
            }
        }

        Credit_Risk_Grade__c c = (Credit_Risk_Grade__c)stdController.getRecord();
        c.Number_of_Trade_Experiences_PG__c = trade;
        c.Evidence_of_Suits_Judgements_Liens__c = evidenceValue;
        c.Time_in_business__c = yearsInBusiness * 12;
        c.Date_Established2__c = dateFounded;
        c.D_B_Score__c = score;
        c.D_B_CCS_Score__c = ccsPercent;
        c.Paydex_D_B_Score__c = paydexScore;
        
        update c;

        if (recTypeName == RT_PERSONAL || recTypeName == RT_PERSONAL_ADMIN || recTypeName == RT_MEDICAL || recTypeName == RT_MEDICAL_ADMIN) {
            return queryCBCRecords();
        } else {
            return save();
        }
    }

    public PageReference queryCBCRecords() {
        
        Set<Id> entAccIds = new Set<Id>();
        List<LLC_BI__Legal_Entities__c> entList = [SELECT
                Id,
                LLC_BI__Account__c,
                LLC_BI__Borrower_Type__c,
                LLC_BI__Loan__c
            FROM
                LLC_BI__Legal_Entities__c
            WHERE
                LLC_BI__Borrower_Type__c =: GUARANTOR
            AND
                LLC_BI__Loan__c =: loanName];
        for (LLC_BI__Legal_Entities__c e : entList) {
            entAccIds.add(e.LLC_BI__Account__c);
        }

        List<nCBC__Credit_Report__c> reportList = [SELECT
                Id,
                nCBC__FICO_Score__c,
                nCBC__OFAC__c,
                nCBC__Contact__r.AccountId
            FROM
                nCBC__Credit_Report__c
            WHERE
                nCBC__Contact__r.AccountId IN: entAccIds
            AND
                nCBC__Contact__r.LLC_BI__Primary_Contact__c = true 
            ORDER BY
                nCBC__FICO_Score__c DESC LIMIT 1];        
        Id credReportId = reportList[0].Id;
        Id credReportAccId = reportList[0].nCBC__Contact__r.AccountId;
        for (nCBC__Credit_Report__c r : reportList) {
            if (r.nCBC__FICO_Score__c > 0) {
                ficoscore = r.nCBC__FICO_Score__c;
            } if (r.nCBC__OFAC__c != null) {
                ofac = r.nCBC__OFAC__C;
            }
        }
        
        List<nCBC__Credit_Record__c> credRecList = [SELECT
                Id,
                nCBC__scoreValue__c,
                nCBC__modelName__c
            FROM
                nCBC__Credit_Record__c
            WHERE
                nCBC__CreditReport__c =: credReportId
            AND
                ((nCBC__scoreValue__c != null) AND (nCBC__modelName__c LIKE 'Experian%'))];
        for (nCBC__Credit_Record__c c : credRecList) {
            if (c.nCBC__scoreValue__c != null) {
                scoreValue = Integer.ValueOf(c.nCBC__scoreValue__c);
            }
        }

        Integer counter30Days = [SELECT
                COUNT()
            FROM 
                nCBC__Credit_Record__c
            WHERE
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND
                nCBC__delinqOver30Days__c != null];
        if (counter30Days == null) {
            counter30Days = 0;
        }

        Integer counter60Days = [SELECT
                COUNT()
            FROM 
                nCBC__Credit_Record__c
            WHERE
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND
                nCBC__delinqOver60Days__c != null];
        if (counter60Days == null) {
            counter60Days = 0;
        }

        Integer counter90Days = [SELECT
                COUNT()
            FROM 
                nCBC__Credit_Record__c
            WHERE
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND
                nCBC__delinqOver90Days__c != null];
        if (counter90Days == null) {
            counter90Days = 0;
        }

        Integer chargeOffs = [SELECT
                COUNT()
            FROM 
                nCBC__Credit_Record__c
            WHERE
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND
                nCBC__status__c =: COLLECTIONS];
        if (chargeOffs == null) {
            chargeOffs = 0;
        }

        Integer ownsHome = [SELECT
                COUNT()
            FROM 
                nCBC__Credit_Record__c
            WHERE
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND
                nCBC__creditType__c =: MORTGAGE];
        if (ownsHome == null) {
            ownsHome = 0;
        }

        Integer bankruptcy = [SELECT
                COUNT()
            FROM 
                nCBC__Credit_Record__c
            WHERE
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND
                nCBC__RecordType__c LIKE 'Bankruptcy%'];
        if (bankruptcy >= 1) {
          bankruptcies = 'Yes';
        } else {
            bankruptcy = 0;
        }

        Decimal debtAvailable = (Decimal) [SELECT 
                SUM(nCBC__creditLimit__c)total
            FROM
                nCBC__Credit_Record__c 
            WHERE 
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND 
                (nCBC__creditType__c =: REVOLVING AND nCBC__status__c =: OPEN)][0].get('total');

        Decimal debtBalance = (Decimal) [SELECT 
                SUM(nCBC__balance__c)total
            FROM 
                nCBC__Credit_Record__c 
            WHERE 
                nCBC__CreditReport__r.nCBC__Contact__r.AccountId =: credReportAccId
            AND 
                (nCBC__creditType__c =: REVOLVING AND nCBC__status__c =: OPEN)][0].get('total');

        if (debtBalance > 0 && debtAvailable > 0) {
          revDebtAvailability = (debtBalance / debtAvailable) * 100;
        }

        Credit_Risk_Grade__c c = (Credit_Risk_Grade__c)stdController.getRecord();
        c.FICO_Score_PG__c = ficoScore;
        c.OFAC_Status__c = ofac;
        c.FICO_Score_Range__c = scoreValue;
        c.Slow_Pays__c = counter30Days + counter60Days + counter90Days;
        c.Charge_Offs__c = chargeOffs;
        c.Owns_Home_Property__c = ownsHome;
        c.Bankruptcies__c = bankruptcies;
        c.Bankruptcy__c = bankruptcy;
        c.Revolving_Debt_Balance__c = debtBalance;
        c.Debt_Availability__c = revDebtAvailability;
        update c;

        return save();
    }

    public PageReference Save() {

        Credit_Risk_Grade__c credit = [SELECT 
                Id, 
                FM_Time_in_Business__c,
                FM_Paydex_Score__c,
                FM_Trade_Experiences__c,
                FM_D_B_Score__c,
                TFM_Business_Pers_Corp__c,
                FM_Fico_Score__c,
                FM_Revolving_Debt_Available__c,
                FM_Owns_Home_Property__c,
                FM_Slow_Pays__c,
                FM_Charge_Offs__c,
                FM_Bankruptcy__c,
                TFM_Personal_Pers_Med__c,
                FM_New_Used_Collateral__c,
                FM_Useful_Life__c,
                FM_Revenue_Generating_Essential__c,
                FM_Down_Payment__c,
                FM_Other_Collateral__c,
                TFM_Collateral_Pers_Corp_Med__c,
                FM_Bank_Account_Type__c,
                FM_Average_Deposit_Balance__c,
                FM_Average_Loan_Balance__c,
                FM_NSFs_or_ODs__c,
                TFM_Bank_Reference_Pers_Corp_Med__c,
                Override_Points__c,
                Overall_Credit_Score__c,
                Final_Credit_Score__c,
                TFM_Financial_Corp__c,
                TFM_Business_Med__c
            FROM 
                Credit_Risk_Grade__c 
            WHERE 
                Id =: recordId];

        if (credit.Override_Points__c > 0) {
            overridePoints = credit.Override_Points__c;
        }
        
        if (recTypeName == RT_PERSONAL || recTypeName == RT_PERSONAL_ADMIN) {
            Decimal persBizTotal = 0;
            Decimal persPersTotal = 0;
            Decimal persCollTotal = 0;
            Decimal persBankTotal = 0;

            if (credit.TFM_Business_Pers_Corp__c != null) {
                persBizTotal = credit.TFM_Business_Pers_Corp__c;
            } if (credit.TFM_Personal_Pers_Med__c != null) {
                persPersTotal = credit.TFM_Personal_Pers_Med__c;
            } if (credit.TFM_Collateral_Pers_Corp_Med__c != null) {
                persCollTotal = credit.TFM_Collateral_Pers_Corp_Med__c;
            } if (credit.TFM_Bank_Reference_Pers_Corp_Med__c != null) {
                persBankTotal = credit.TFM_Bank_Reference_Pers_Corp_Med__c;
            }
            
            Decimal persTotal = persBizTotal + persPersTotal + persCollTotal + persBankTotal;
            credit.Overall_Credit_Score__c = persTotal;
            credit.Final_Credit_Score__c = persTotal + overridePoints;
        } else if (recTypeName == RT_MEDICAL || recTypeName == RT_MEDICAL_ADMIN) {
            Decimal medBizTotal = 0;
            Decimal medPersTotal = 0;
            Decimal medCollTotal = 0;
            Decimal medBankTotal = 0;

            if (credit.TFM_Business_Med__c != null) {
                medBizTotal = credit.TFM_Business_Med__c;
            } if (credit.TFM_Personal_Pers_Med__c != null) {
                medPersTotal = credit.TFM_Personal_Pers_Med__c;
            } if (credit.TFM_Collateral_Pers_Corp_Med__c != null) {
                medCollTotal = credit.TFM_Collateral_Pers_Corp_Med__c;
            } if (credit.TFM_Bank_Reference_Pers_Corp_Med__c != null) {
                medBankTotal = credit.TFM_Bank_Reference_Pers_Corp_Med__c;
            }
            
            Decimal medTotal = medBizTotal + medPersTotal + medCollTotal + medBankTotal;
            credit.Overall_Credit_Score__c = medTotal;
            credit.Final_Credit_Score__c = medTotal + overridePoints;
        } else if (recTypeName == RT_CORPORATE || recTypeName == RT_CORPORATE_ADMIN) {
            Decimal corpBizTotal = 0;
            Decimal corpFinTotal = 0;
            Decimal corpCollTotal = 0;
            Decimal corpBankTotal = 0;

            if (credit.TFM_Business_Pers_Corp__c != null) {
                corpBizTotal = credit.TFM_Business_Pers_Corp__c;
            } if (credit.TFM_Financial_Corp__c != null) {
                corpFinTotal = credit.TFM_Financial_Corp__c;
            } if (credit.TFM_Collateral_Pers_Corp_Med__c != null) {
                corpCollTotal = credit.TFM_Collateral_Pers_Corp_Med__c;
            } if (credit.TFM_Bank_Reference_Pers_Corp_Med__c != null) {
                corpBankTotal = credit.TFM_Bank_Reference_Pers_Corp_Med__c;
            }
            
            Decimal corpTotal = corpBizTotal + corpFinTotal + corpCollTotal + corpBankTotal;
            credit.Overall_Credit_Score__c = corpTotal;
            credit.Final_Credit_Score__c = corpTotal + overridePoints;
        }

        if (credit.Final_Credit_Score__c <= 69) {
            credit.Final_Risk_Grade__c = 7;
        } else if (credit.Final_Credit_Score__c >= 70 && credit.Final_Credit_Score__c <= 79) {
            credit.Final_Risk_Grade__c = 6;
        } else if (credit.Final_Credit_Score__c >= 80 && credit.Final_Credit_Score__c <= 104) {
            credit.Final_Risk_Grade__c = 5;
        } else if (credit.Final_Credit_Score__c >= 105 && credit.Final_Credit_Score__c <= 124) {
            credit.Final_Risk_Grade__c = 4;
        } else if (credit.Final_Credit_Score__c >= 125) {
            credit.Final_Risk_Grade__c = 3;
        }
        
        update credit;
        return new PageReference('/' + recordId);
    }

    private static final String GUARANTOR = 'Guarantor';
    private static final String RT_PERSONAL = 'Personal';
    private static final String RT_CORPORATE = 'Corporate';
    private static final String RT_MEDICAL = 'Medical';
    private static final String RT_PERSONAL_ADMIN = 'Personal_Admin';
    private static final String RT_CORPORATE_ADMIN = 'Corporate_Admin';
    private static final String RT_MEDICAL_ADMIN = 'Medical_Admin';
    private static final String COLLECTIONS = 'Collections';
    private static final String MORTGAGE = 'Mortgage';
    private static final String REVOLVING = 'Revolving';
    private static final String OPEN = 'Open';
}
