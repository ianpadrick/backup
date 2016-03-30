public with sharing class OpportunityHistoryCreatorTriggerHandler {
   
   public void createHistories(Id opp, String oldStageName, String newStageName) {

      List<Opportunity_History__c> historyList = [SELECT
            Id,
            Opportunity__c,
            Stage_Name__c,
            Start_Time__c,
            Start_Date__c,
            End_Time__c,
            End_Date__c
         FROM
            Opportunity_History__c
         WHERE
            Opportunity__c =: opp
         AND
            ((Start_Date__c != null) AND (End_Date__c = null))
         ORDER BY
            CreatedDate DESC];
      
      if (historyList.size() > 0) {
         List<Opportunity_History__c> oppUpdates = new List<Opportunity_History__c>();
         for (Opportunity_History__c h : historyList) {
            h.End_Time__c = System.Now();
            h.End_Date__c = System.Today();
            oppUpdates.add(h);
         }

         Opportunity_History__c oppHistory = new Opportunity_History__c();
         oppHistory.Stage_Name__c = newStageName;
         oppHistory.Start_Time__c = System.Now();
         oppHistory.Start_Date__c = System.Today();
         oppHistory.Opportunity__c = opp;
         try {
            update oppUpdates;
            insert oppHistory;
         } catch(DmlException e) {
            System.debug('*** In the existing list, the following exception has occurred: ' + e.getMessage());
         }
      } else {
         Opportunity_History__c oppHistory = new Opportunity_History__c();
         oppHistory.Stage_Name__c = oldStageName;
         oppHistory.Start_Time__c = System.Now();
         oppHistory.Start_Date__c = System.Today();
         oppHistory.Opportunity__c = opp;
         try {
            insert oppHistory;
         } catch(DmlException e) {
            System.debug('*** The following exception has occurred for the first record: ' + e.getMessage());
         }
      }
   }
}