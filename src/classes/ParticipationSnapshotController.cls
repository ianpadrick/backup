public class ParticipationSnapshotController {

    public List<LLC_CDS__Deal_Facility__c> info {get; private set;}
    public List<LLC_BI__Loan__c> facilities  {get; private set;}
    public Map<Id, Decimal> participationTotals {get; private set;}
    public Map<Id, Boolean> participationTotalsHasValue {get; private set;}
    public List<Participation_Syndication__c> participations {get; private set;}
    public List<AggregateResult> amount;
    public List<AggregateResult> results;
    public Decimal totalPartAmt {get; set;}

    public Date Today { get; private set;}
    private Id objId = null;
    
    //Constructor for the Standard Controller
    public ParticipationSnapshotController(ApexPages.StandardController controller) {
        this.Today = Date.today();
        this.objId = ApexPages.currentPage().getParameters().get('id');
        participationTotals = new Map<Id, Decimal>();
        participationTotalsHasValue = new Map<Id,Boolean>();
        
        this.info = [SELECT Id, Name, LLC_CDS__Description__c FROM LLC_CDS__Deal_Facility__c WHERE Id =: objId limit 1];
        this.facilities = [SELECT Id, Name, LLC_BI__Amount__c, LLC_BI__CloseDate__c FROM LLC_BI__Loan__c WHERE LLC_CDS__Deal_Facility__c =: objId];
        Set<Id> facilityIds = new Map<Id, LLC_BI__Loan__c>(this.facilities).keySet();
        this.participations = [SELECT Id, Name, Request_Id__c, Bank__c, Bank__r.Name, Acting_As__c, Participation_Amount__c, SNC__c, Special_Instructions__c FROM Participation_Syndication__c WHERE Request_Id__c IN : facilityIds];

        for (Participation_Syndication__c part : this.participations) {
            Decimal partValue = participationTotals.get(part.Request_Id__c);
            if(partValue == null){
                partValue = 0;
            }

            if (part.Participation_Amount__c != null) {
                partValue += part.Participation_Amount__c;
            }

            participationTotals.put(part.Request_Id__c, partValue);
        }

        for(LLC_BI__Loan__c facility : this.facilities){
            Decimal total = participationTotals.get(facility.Id);
            if(total != null){
                participationTotalsHasValue.put(facility.Id, true);
            }else{
                participationTotalsHasValue.put(facility.Id, false);
            }
        }
    }

}
