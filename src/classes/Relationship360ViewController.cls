public class Relationship360View{
        
    public String relCode {set;get;}
    public final Account acct;
    public list<AggregateResult> lstAR3 = new list<AggregateResult>();
    public list<AggregateResult> lstAR = new list<AggregateResult>(); 
    public list<AggregateResult> lstAR2 = new list<AggregateResult>();
    
    //Constructor for the Standard Controller
    public Relationship360View(ApexPages.StandardController controller) {

        //String relCode Stores the Relationship code of the current page in a String relCode for later use in soql query
        //Achieves this by using the currentPage() and getParameters() methods to obtain the current page's ID from the URL
        relCode = [SELECT Relationship_Code__c FROM Account WHERE Relationship_Code__c != null AND Id =: ApexPages.currentPage().getParameters().get('id')].Relationship_Code__c;
        lstAR=[SELECT SUM(Total_ExposureCM__c) totRelExp FROM Account WHERE  Exclude_From_Relationship__c=:false AND Relationship_Code__c =: relCode];
        lstAR3=[SELECT SUM(LLC_BI__Amount__c) totRelDeposits FROM LLC_BI__Deposit__c WHERE  LLC_BI__Account__r.Exclude_From_Relationship__c=:false AND LLC_BI__Account__r.Relationship_Code__c =: relCode];
        lstAR2=[SELECT SUM(LLC_BI__Amount__c) totRelLoans FROM LLC_BI__Loan__c WHERE  LLC_BI__Account__r.Exclude_From_Relationship__c=:false AND LLC_BI__Account__r.Relationship_Code__c =: relCode];
    }

        public List<LLC_BI__Deposit__c> getDeposits(){       
       
            List<LLC_BI__Deposit__c> deposits = [SELECT Name, Id, LLC_BI__Amount__c, LLC_BI__Deposit__c.LLC_BI__Account__r.Name, LLC_BI__Account__r.Has_Preferred_Credit__c, LLC_BI__Stage__c, LLC_BI__Deposit__c.LLC_BI__Account__r.Id FROM LLC_BI__Deposit__c WHERE LLC_BI__Account__r.Exclude_From_Relationship__c=:false AND LLC_BI__Account__r.Relationship_Code__c =:relCode];

            return deposits;     
        }
        
        public List<LLC_BI__Loan__c> getLoans(){       
        
            List<LLC_BI__Loan__c> loans = [SELECT Id, LLC_BI__Amount__c, LLC_BI__Loan__c.LLC_BI__Account__r.Name, LLC_BI__CloseDate__c, LLC_BI__Loan__c.LLC_BI__Account__r.Id, Name FROM LLC_BI__Loan__c Where LLC_BI__Account__r.Exclude_From_Relationship__c=:false AND LLC_BI__Account__r.Relationship_Code__c =:relCode];

            return loans;     
        }
        
        public List<Account> getAccounts(){       
        
            List<Account> accounts = [SELECT Id, Name, Relationship_Code__c, Total_ExposureCM__c FROM Account WHERE Exclude_From_Relationship__c=:false AND Relationship_Code__c =: relCode];

            return accounts;     
        }

    public list<accRelSummary> getResults()
    {  
    list<accRelSummary> lstResult = new list<accRelSummary>();
    for (AggregateResult ar : lstAR)
    {
    accRelSummary objaccRelSummary = new accRelSummary(ar);
    lstResult.add(objaccRelSummary);
    }
    return lstResult;
    
    }
    
    //Wrapper class initializes a decimal variable to hold the result from the query and then assigns the result to that variable casting as a Decimal type
    class accRelSummary
    {
    public Decimal totRelExp
    {get; set; }
    
    public accRelSummary(AggregateResult ar)
    {
    totRelExp = (Decimal)ar.get('totRelExp');
    }
  }
        public list<accRelSummary2> getResults2()
    {
    list<accRelSummary2> lstResult2 = new list<accRelSummary2>();
    for (AggregateResult ar2 : lstAR2)
    {
    accRelSummary2 objaccRelSummary2 = new accRelSummary2(ar2);
    lstResult2.add(objaccRelSummary2);
    }
    return lstResult2;
    }
    
    //Wrapper class sets a decimal variable to hold the result from the above query then assigns the result to the variable casting as a Decimal type
    class accRelSummary2
    {
    public Decimal totRelLoans
    {get; set; }
    
    public accRelSummary2(AggregateResult ar2)
    {
    totRelLoans = (Decimal)ar2.get('totRelLoans');
    }
    
  }
    //Stores the Aggregate results in a new list using a for loop to traverse through the AggregateResult list
    public list<accRelSummary3> getResults3()
    {
    list<accRelSummary3> lstResult3 = new list<accRelSummary3>();
    for (AggregateResult ar3 : lstAR3)
    {
    accRelSummary3 objaccRelSummary3 = new accRelSummary3(ar3);
    lstResult3.add(objaccRelSummary3);
    }
    return lstResult3;
    }
    
    //Wrapper class sets a decimal variable to hold the result from the query then assigns the result to the variable casting as a Decimal type
    class accRelSummary3
    {
    public Decimal totRelDeposits
    {get; set; }
    
    public accRelSummary3(AggregateResult ar3)
    {
    totRelDeposits = (Decimal)ar3.get('totRelDeposits');
    }
    
  }
}
