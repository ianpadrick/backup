public with sharing class MapLocationController {
   
   public Id accountId           { get; set; }
   public Id leadId              { get; set; }
   public Id assetId             { get; set; }
   public String recordName      { get; set; }
   public String recordStreet    { get; set; }
   public String recordCity      { get; set; }
   public String recordZip       { get; set; }

   public MapLocationController(ApexPages.StandardController controller) {
      //String objId = String.ValueOf(ApexPages.currentPage().getParameters().get('id'));
      String objId = String.ValueOf(controller.getId());
      String sObjectType = String.ValueOf(controller.getRecord().getSObjectType());
      
      if (sObjectType == ACCOUNT) {
         Account a = [SELECT
            Name,
            BillingStreet,
            BillingCity,
            BillingPostalCode
         FROM
            Account
         WHERE
            Id =: objId];

         recordName = a.Name;
         recordStreet = a.BillingStreet;
         recordCity = a.BillingCity;
         recordZip = a.BillingPostalCode;

      //} else if (sObjectType == ASSET) {
      //   Asset__c a = [SELECT
      //      Name,
      //      Street__c,
      //      City__c,
      //      Postal_Code__c
      //   FROM
      //      Asset__c
      //   WHERE
      //      Id =: objId];

      //   recordName = a.Name;
      //   recordStreet = a.Street__c;
      //   recordCity = a.City__c;
      //   recordZip = a.Postal_Code__c;
      } else if (sObjectType == LEAD) {
         Lead l = [SELECT
            Name,
            Street,
            City,
            PostalCode
         FROM
            Lead
         WHERE
            Id =: objId];

         recordName = l.Name;
         recordStreet = l.Street;
         recordCity = l.City;
         recordZip = l.PostalCode;
      }
   }

   private static final String ACCOUNT = 'Account';
   private static final String COLLATERAL = 'Asset__c';
   private static final String LEAD = 'Lead';
}