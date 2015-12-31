public with sharing class CreditMemoDeleter {
   public class PageReference deleteMemos() {
      public Boolean noCreditMemos = false;

      Set<Id> loanIds = new Set<Id>();
      List<LLC_BI__Loan__c> loanList = [SELECT
            Id,
            LLC_BI__Credit_Memo__c
         FROM
            LLC_BI__Loan
         WHERE
            LLC_BI__Credit_Memo__c != null];

      for (LLC_BI__Loan__c l : loanList) {
         loanIds.add(l.LLC_BI__Credit_Memo__c);
      }

      Set<Id> packageIds = new Set<Id>();
      List<LLC_BI__Product_Package__c> packageList = [SELECT
            Id,
            LLC_BI__Credit_Memo__c
         FROM
            LLC_BI__Product_Package__c
         WHERE
            LLC_BI__Credit_Memo__c != null];
      for (LLC_BI__Product_Package__c p : packageList) {
         packageIds.add(l.LLC_BI__Credit_Memo__c);
      }

      Set<Id> screenIds = new Set<Id>();
      List<LLC_BI__Credit_Memo__c> memoList = [SELECT
            Id,
            LLC_BI__Screen__c
         FROM
            LLC_BI__Credit_Memo__c
         WHERE
            LLC_BI__Is_Template__c = false
         AND
            (Id NOT IN : loanIds && Id NOT IN : packageIds)];

      for (LLC_BI__Credit_Memo__c c : memoList) {
         screenIds.add(c.LLC_BI__Screen__c);
      }

      List<nDESIGN__Screen__c> screenList = [SELECT
            Id
         FROM
            nDESIGN__Screen__c
         WHERE
            Id IN : screenIds];

      List<nDESIGN__Screen_Section__c> sectionList = [SELECT
            Id
         FROM
            nDESIGN__Screen_Section__c
         WHERE
            nDESIGN__Screen__c IN : screenList];

      //system.debug('*** section: ' + section.Id);

      List<nDESIGN__Screen__c> screen = [SELECT
              Id
      FROM
              nDESIGN__Screen__c
      WHERE
              Id =: section.nDESIGN__Screen__c];

      //system.debug('*** screen: ' + screen.Id);

      List<LLC_BI__Credit_Memo__c> memo = [SELECT
              Id
      FROM
              LLC_BI__Credit_Memo__c
      WHERE
              LLC_BI__Screen__c ];
   }
}