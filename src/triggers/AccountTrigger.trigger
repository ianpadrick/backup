trigger AccountTrigger on Account (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
  
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AccountTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        } else if (Trigger.isDelete) {
            AccountTriggerHandler.onBeforeDelete(Trigger.old);
        }
    } else if (Trigger.IsAfter) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AccountTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        } else if (Trigger.isDelete) {
            AccountTriggerHandler.onAfterDelete(Trigger.old);
        }
    }
}