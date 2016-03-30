public class ChartController {

    public ChartController() {

    }

    public String repId   { get; set; }
    public Id oppId = ApexPages.currentPage().getParameters().get('id');
    public String oppName { get; set; }
    public List<OpportunityHistory> oppHistoryList { get; set; }
    public Map<Id,String> oppMap { get; set; }

    public ChartController(ApexPages.StandardController stdController) {
        //Opportunity o = (Opportunity)stdController.getRecord();
        ////oppId = o.Id;

        //oppHistoryList = [SELECT
        //        Id,
        //        Opportunity.Name,
        //        StageName
        //    FROM
        //        OpportunityHistory
        //    WHERE
        //        OpportunityId =: oppId];
        
        //System.debug('*** oppHitoryList: ' + oppHistoryList);
        //System.debug('*** oppHitoryList Size: ' + oppHistoryList.size());
                
        //for (OpportunityHistory opp : oppHistoryList) {
        //    System.debug('*** stage name: ' + opp.StageName);
        //    System.debug('*** opp name: ' + opp.Opportunity.Name);
            
        //    oppMap.put(opp.Id, opp.StageName);
        //}
        
        //System.debug('*** oppMap: ' + oppMap);
        
        //Report r = [SELECT Id FROM Report WHERE DeveloperName = 'Opportunity_History'];
        
        //repId = String.ValueOf(r.Id);
    }

    public List<Data> getData() {
        //Opportunity o = [SELECT Id FROM Opportunity WHERE Id =: oppId];
        //oppId = o.Id;

        oppHistoryList = [SELECT
                Id,
                Opportunity.Name,
                StageName
            FROM
                OpportunityHistory
            WHERE
                OpportunityId =: oppId];

        //String stageName1 = oppHistoryList[0].StageName;
        //String stageName2 = oppHistoryList[1].StageName;
        //String stageName3 = oppHistoryList[2].StageName;
        String opportunityName = oppHistoryList[0].Opportunity.Name;
        
        System.debug('*** oppHitoryList: ' + oppHistoryList);
        System.debug('*** oppHitoryList Size: ' + oppHistoryList.size());
                
        //for (OpportunityHistory opp : oppHistoryList) {
        //    System.debug('*** stage name: ' + opp.StageName);
        //    System.debug('*** opp name: ' + opp.Opportunity.Name);
            
        //    oppMap.put(opp.Id, opp.StageName);
        //}

        List<Data> data = new List<Data>();
        Integer stageName1 = 1;
        Integer stageName2 = 2;
        Integer stageName3 = 3;
        System.debug('*** oppMap: ' + oppMap);
        //for (String oh : oppMap.keySet()) {
        //    data.add(new Data(oppMap.get(oh), counter));
        //    counter += 1;
        //}

        data.add(new Data(opportunityName, stageName1, stageName2, stageName3));

        //for (OpportunityHistory oh : oppHistoryList) {
        //    data.add(new Data(oh.Opportunity.name, oh.StageName, counter));
        //    counter += 1;
        //}

        //data.add(new Data('Jan', 30, 90, 55));
        //data.add(new Data('Feb', 44, 15, 65));
        //data.add(new Data('Mar', 25, 32, 75));
        //data.add(new Data('Apr', 74, 28, 85));
        //data.add(new Data('May', 65, 51, 95));
        //data.add(new Data('Jun', 33, 45, 99));
        //data.add(new Data('Jul', 92, 82, 60));
        //data.add(new Data('Aug', 87, 73, 45));
        //data.add(new Data('Sep', 34, 65, 55));
        //data.add(new Data('Oct', 78, 66, 56));
        //data.add(new Data('Nov', 80, 67, 53));
        //data.add(new Data('Dec', 17, 70, 70));
        
        System.debug('*** data: ' + data);
        return data;
    }

    public class Data {

        public Integer stageName1 { get; set; }
        public Integer stageName2 { get; set; }
        public Integer stageName3 { get; set; }
        public String oppName { get; set; }

        public Data(String oppName, Integer stageName1, Integer stageName2, Integer stageName3) {
            this.oppName = oppName;
            this.stageName1 = stageName1;
            this.stageName2 = stageName2;
            this.stageName3 = stageName3;
        }
    }
}