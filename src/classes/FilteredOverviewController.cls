global with sharing class FilteredOverviewController {
  private static final String WITHDRAWN = 'Withdrawn';
  public String stageCountJson {get; set;}
  public String stagesJson {get; set;}
  public List<VCS_Overview__c> stages {get; set;}
  
  // variable to hold selections from list
  public String selectedOption {get; set;}
  public String selectedBranch {get; set;}
  
  public PageReference save() {

    if(selectedOption == null) {
      selectedOption = '--None--';
    }

    if(selectedBranch == null) {
      selectedBranch = '--None--';
    }
    return null;
  }

  // This constructor is here for the test drivers
  public VentureBankingOverview() {
    setupData();
  }

    public VentureBankingOverview(ApexPages.StandardController stdController) {
      setupData();
      setupDataBranch();
    }


    public void setupData() {
      List<String> stageNames = new List<String>();
      Map<String, Integer> stageCount = new Map<String, Integer>();
      stages = getSLDConfig();

    for(VCS_Overview__c c : stages){
      stageNames.add(c.Stage__c);
      stageCount.put(+c.Stage__c, 0);
    }

    List<aggregateResult> results = [
      SELECT 
        count(Id) counter, 
        LLC_BI__Stage__c stage 
      FROM 
        LLC_BI__Loan__c 
      WHERE 
        (((LLC_BI__Stage__c !=: WITHDRAWN) AND (LLC_BI__Lost_To__c = null) AND (Loan_Type__c = 'CAR'))
        OR 
        ((LLC_BI__Stage__c =: WITHDRAWN) AND (LLC_BI__Lost_To__c != null)))
      AND
        LLC_BI__Account__r.LOOKUP_REGION__c =: selectedOption
      GROUP BY 
        LLC_BI__Stage__c];
    
    for (AggregateResult ar : results) {
      stageCount.put((String)ar.get('stage'), (Integer)ar.get('counter'));
    }
        
    stageCountJson = JSON.serialize(stageCount);
    stagesJson = JSON.serialize(stages);
      if (selectedBranch != null) {
        selectedBranch = '--None--';
      }
    }

    private VCS_Overview__c[] getSLDConfig(){
      return [
        SELECT 
          Name, 
          Stage__c, 
          Custom_Label_Key__c, 
          Link_URL__c, 
          IconImageName__c, 
          IconStyleClass__c, 
          Flow_Setting__c, 
          StaticResourceName__c
        FROM 
          VCS_Overview__c
        WHERE 
          Active__c = true
        ORDER BY 
          Active__c, 
          Display_Order__c
        ];
    }
    
    public void setupDataBranch() {
      List<String> stageNames = new List<String>();
      Map<String, Integer> stageCount = new Map<String, Integer>();
    stages = getSBLConfig();

    for(VCS_Overview__c c : stages){
      stageNames.add(c.Stage__c);
      stageCount.put(+c.Stage__c, 0);
    }

    List<aggregateResult> results = [
      SELECT
        count(Id) counter, 
        LLC_BI__Stage__c stage 
      FROM 
        LLC_BI__Loan__c 
      WHERE 
        (((LLC_BI__Stage__c !=: WITHDRAWN) AND (LLC_BI__Lost_To__c = null) AND (Loan_Type__c = 'CAR'))
        OR 
        ((LLC_BI__Stage__c =: WITHDRAWN) AND (LLC_BI__Lost_To__c != null)))
      AND
        LLC_BI__Account__r.LLC_Branch__c =: selectedBranch
      GROUP BY 
        LLC_BI__Stage__c];
    
    for (AggregateResult ar : results) {
      stageCount.put((String)ar.get('stage'), (Integer)ar.get('counter'));
    }
        
    stageCountJson = JSON.serialize(stageCount);
    stagesJson = JSON.serialize(stages);
      if (selectedOption  != null) {
        selectedOption = '--None--';
      }
    }

    private VCS_Overview__c[] getSBLConfig(){
      return [
        SELECT 
          Name, 
          Stage__c, 
          Custom_Label_Key__c, 
          Link_URL__c, 
          IconImageName__c, 
          IconStyleClass__c, 
          Flow_Setting__c, 
          StaticResourceName__c
        FROM 
          VCS_Overview__c
        WHERE 
          Active__c = true
        ORDER BY 
          Active__c, 
          Display_Order__c
        ];
    }
}
