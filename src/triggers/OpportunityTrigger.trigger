trigger OpportunityTrigger on Opportunity (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
  
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OpportunityTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            OpportunityTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        } else if (Trigger.isDelete) {
            OpportunityTriggerHandler.onBeforeDelete(Trigger.old);
        }
    } else if (Trigger.IsAfter) {
        if (Trigger.isInsert) {
            OpportunityTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            OpportunityTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        } else if (Trigger.isDelete) {
            OpportunityTriggerHandler.onAfterDelete(Trigger.old);
        }
    }
}