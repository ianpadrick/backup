public with sharing class AmendmentTriggerHandler {
    
    @future
    public static void deleteLoanTeam(Id loan) {

        List<LLC_BI__LoanTeam__c> teamList = 
            [
                SELECT 
                    Id, 
                    LLC_BI__User__c, 
                    LLC_BI__Assigned_Role__r.Name, 
                    LLC_BI__Loan__c,
                    LLC_BI__Role__c
                FROM 
                    LLC_BI__LoanTeam__c 
                WHERE
                    LLC_BI__Loan__c =: loan
                AND
                    (
                        LLC_BI__Role__c =: ROLE_CLOSER
                        OR
                        LLC_BI__Role__c =: ROLE_CLIENT_SERVICE
                        OR
                        LLC_BI__Role__c =: ROLE_DILIGENCE
                        OR
                        LLC_BI__Role__c =: ROLE_DOCUMENT_DRAFTER
                        OR
                        LLC_BI__Role__c =: ROLE_LOAN_OPS_SUPPORT
                        OR
                        LLC_BI__Role__c =: ROLE_LOAN_OPS_SPECIALIST
                        OR
                        LLC_BI__Role__c =: ROLE_GTM_SALES
                        OR
                        LLC_BI__Role__c =: ROLE_GTM_SUPPORT
                    )
            ];

        Database.delete(teamList);
    }

    public static void updateLoan(Id loan) {

        String soql = 'SELECT ';

        Map<String, Amendment_Configuration__c> setMap = new Map<String, Amendment_Configuration__c>();
        List<Amendment_Configuration__c> settingsList = 
            [
                SELECT 
                    Id, 
                    Field_API_Name__c, 
                    Field_Value__c 
                FROM 
                    Amendment_Configuration__c 
                WHERE 
                    Field_API_Name__c != null
            ];

        for (Amendment_Configuration__c a : settingsList) {
            setMap.put(a.Field_API_Name__c, a);
            soql += a.Field_API_Name__c + ',';
        }

        soql = soql.substring(0, soql.length() - 1);
        soql = soql + ' FROM LLC_BI__Loan__c WHERE Id =: loan LIMIT 1';
        List<sObject> results = database.query(soql);
            
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = LLC_BI__Loan__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();

        for(String fieldName : fieldMap.keySet() ) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            labelMap.put(fieldDescribe.getName(), String.valueOf(fieldDescribe.getType()));
        }

        for (sObject l : results) {
            for (String key : setMap.keySet()) {

                if (setMap.get(key).Field_Value__c == null) {
                    l.put(key, null);
                } else if (labelMap.get(key) == 'STRING') {
                    l.put(key, String.valueOf(setMap.get(key).Field_Value__c));
                } else if(labelMap.get(key) == 'PICKLIST') {
                    l.put(key, String.valueOf(setMap.get(key).Field_Value__c));
                } else if(labelMap.get(key) == 'DOUBLE') {
                    l.put(key, Integer.valueOf(setMap.get(key).Field_Value__c));
                } else if(labelMap.get(key) == 'PERCENT') {
                    l.put(key, Decimal.valueOf(setMap.get(key).Field_Value__c));
                }  else if (labelMap.get(key) == 'DATE') {
                    l.put(key, Date.valueOf(setMap.get(key).Field_Value__c));
                } else if (labelMap.get(key) == 'DATETIME') {
                    l.put(key, Datetime.valueOf(setMap.get(key).Field_Value__c));
                } else if (labelMap.get(key) == 'BOOLEAN') {
                    l.put(key, Boolean.valueOf(setMap.get(key).Field_Value__c));
                } else if (labelMap.get(key) == 'CURRENCY') {
                    l.put(key, Decimal.valueOf(setMap.get(key).Field_Value__c));
                }
            }
        }
        
        Database.update(results);
    }

    private static final String ROLE_CLOSER = 'Loan Closer';
    private static final String ROLE_CLIENT_SERVICE = 'Client Services';
    private static final String ROLE_DILIGENCE = 'Diligence';
    private static final String ROLE_DOCUMENT_DRAFTER = 'Document Drafter';
    private static final String ROLE_LOAN_OPS_SUPPORT = 'Loan Ops Support';
    private static final String ROLE_LOAN_OPS_SPECIALIST = 'Loan Ops Specialist';
    private static final String ROLE_GTM_SALES = 'GTM Sales';
    private static final String ROLE_GTM_SUPPORT = 'GTM Support';
}
