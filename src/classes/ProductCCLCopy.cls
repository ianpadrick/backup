Id PRODUCT_TO_COPY = 'a0b1a000000UZzX';
Id NEW_PRODUCT = 'a0b1a000000WIiK';

Set<Id> cclIds = new Set<Id>();
List<LLC_BI__ProductCCL__c> cclList = [SELECT 
		Id, 
		LLC_BI__Closing_Checklist__c, 
		LLC_BI__Product__c 
	FROM 
		LLC_BI__ProductCCL__c 
	WHERE 
		LLC_BI__Product__c =: PRODUCT_TO_COPY];

for (LLC_BI__ProductCCL__c p : cclList) {
	cclIds.add(p.LLC_BI__Closing_Checklist__c);
}

List<LLC_BI__ClosingChecklist__c> closingList = [SELECT 
		Id, 
		Name 
	FROM 
		LLC_BI__ClosingChecklist__c 
	WHERE 
		Id IN : cclIds];

for (LLC_BI__ClosingChecklist__c c : closingList) {
	LLC_BI__ProductCCL__c p = new LLC_BI__ProductCCL__c();
	p.LLC_BI__Product__c = NEW_PRODUCT;
	p.LLC_BI__Closing_Checklist__c = c.Id;
	insert p;
}
