public class TestController {

    public static Map<String, Integer> innerMap             { get; set; }
    public static Map<String, Map<String, Integer>> dataMap { get; set; }
    public static String yfield                             { get; set; }
    public static Decimal convertedAmount                   { get; set; }

    public TestController(ApexPages.StandardController stdController) {
        innerMap = new Map<String, Integer>();
        dataMap = new Map<String, Map<String, Integer>>();
        yfield = '';

        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        String oppName = opp.Name;

        List<OpportunityHistory> oppHistoryList = [SELECT 
                Id, 
                StageName
            FROM
                OpportunityHistory
            WHERE
                OpportunityId =: opp.Id];

        Integer counter = 100;
        for (OpportunityHistory o : oppHistoryList) {
            innerMap.put(o.StageName, counter);
            yfield += o.StageName + ',';
            counter += 500;
        }
        
        if(yfield.endsWith(',')) {
            yfield = yfield.removeEnd(',') ;
        }

        dataMap.put(oppName, innerMap);

        //yfield = 'USD,INR,EUR';
        //convertedAmount = 1800;
        //innerMap.put('USD',900);
        //innerMap.put('INR',200);
        //innerMap.put('EUR',700);
        //dataMap.put('2014 Q1', innerMap);
    }
    
    public static Map<String, Map<String,Integer>> getChartData() {
        //yfield = 'USD,INR,EUR';
        //convertedAmount = 1800;
        //dataMap = new Map<String, Map<String,Integer>>();
        //Integer totalCount = 0;
       
        //innerMap.put('USD',900);
        //innerMap.put('INR',200);
        System.debug('*** entered method');
        innerMap.put('EUR',700);
        dataMap.put('2014 Q1', innerMap);
        System.debug('*** dataMap getChartData: ' + dataMap);
        return dataMap;
    }
}