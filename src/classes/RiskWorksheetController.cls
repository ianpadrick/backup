public class RiskWorksheetController {
    Id recordId = ApexPages.currentPage().getParameters().get('id');
    ApexPages.StandardController stdController;
    public Boolean refreshPage {get; set;}

    public RiskWorksheetController(ApexPages.StandardController controller) {
      stdController = controller;
      refreshPage = false;
    }

    public PageReference SaveRecord() {
      LLC_BI__Annual_Review__c rev = (LLC_BI__Annual_Review__c)stdController.getRecord();
      // Venture Banking Record Type
      if (rev.RecordTypeId == '012f00000000KqC' && rev.Entirely_Cash_Secured__c == 'Yes') {
        rev.Venture_Banking_Final_Risk_Grade__c = 10;
        // Venture Banking Record Type
      } else if (rev.RecordTypeId == '012f00000000KqC' && rev.Entirely_Cash_Secured__c != 'Yes' || rev.RecordTypeId == '012i0000001AO27' && rev.Entirely_Cash_Secured__c != 'Yes') {
        rev.Venture_Banking_Final_Risk_Grade__c = math.MAX(3.0, rev.Liquid_Net_Gross_Calc__c + rev.Top_Bottom_Calc__c + rev.Financial_Calc__c + rev.Investor_Reserves_Funding_Debt_Calc__c + rev.Coll_Type_Coverage_Facility_Calc__c + rev.Confirmed_Guarantor_Capacity_RG__c + rev.Analyst_Adjustment__c);
        // VCS Fund Record Type
      } else if (rev.RecordTypeId == '012f00000000MTP' || rev.RecordTypeId == '012i0000001AO24') {
        rev.Venture_Banking_Final_Risk_Grade__c = (rev.Uncalled_Capital_Fair_Market_FUND_Calc__c + rev.Size_FUND_Calc__c + rev.Firm_Fund_LP_Retention_FUND_Calc__c + rev.Quality_Management_FUND_Calc__c + rev.Out_of_Instit_LP_Defa_Quality_FUND_Calc__c + rev.Collateral_FUND_Calc__c + rev.Analyst_Adjustment__c).setScale(1);
        // VCS Mgmt Co Record Type
      } else if (rev.RecordTypeId == '012f00000000MTK' || rev.RecordTypeId == '012i0000001AO25') {
        rev.Venture_Banking_Final_Risk_Grade__c = (rev.Annual_Mgmt_Uncalled_MGMT_Calc__c + rev.Size_Mgmt_Calc__c + rev.Firm_LP_Retention_MGMT_Calc__c + rev.Quality_of_Mgmt_and_Experience_MGMT_Calc__c + rev.Out_Debt_Instit_LP_Defa_Quali_MGMT_Calc__c + rev.Collateral_MGMT_Calc__c + rev.Analyst_Adjustment__c).setScale(1);
      }
      // calling standard save() method
      stdController.save();
      // return 'null' to stay on same page
      PageReference pageRef = new PageReference('/' + recordId);

      return pageRef;
    }

    public PageReference SaveRecordComments() {
      // calling standard save() method
      stdController.save();
      // return 'null' to stay on same page
      PageReference pageRef = new PageReference('/' + recordId);

      return pageRef;
    }
}
