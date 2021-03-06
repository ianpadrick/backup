trigger contact_ExampleTrigger on Contact (before insert, before update){
    
    Set<ID> setConIds = new Set<ID>();
    for(Contact obj : trigger.new){
        if(obj.User_Name__c!= null)
        setConIds.add(obj.User_Name__c);
    }
    
    MAP<ID , User> mapCon = new MAP<ID , User>([Select Id,Email,Phone from User where id in: setConIds]);
    for(Contact obj : trigger.new) {
        if(obj.User_Name__c != null) {
            User c = mapCon.get(obj.User_Name__c);
            obj.Email= c.Email;
        }
    }
}
