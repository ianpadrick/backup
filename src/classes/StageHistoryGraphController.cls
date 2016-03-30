public with sharing class StageHistoryGraphController {
    
    public String repId   { get; set; }
    public Id oppId       { get; set; }
    public String oppName { get; set; }

    public StageHistoryGraphController(ApexPages.StandardController stdController) {
        Opportunity o = (Opportunity)stdController.getRecord();
        oppId = o.Id;
        
        Report r = [SELECT Id FROM Report WHERE DeveloperName = 'Opportunity_History'];
        
        repId = String.ValueOf(r.Id);
    }
}