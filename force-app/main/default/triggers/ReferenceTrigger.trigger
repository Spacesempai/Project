trigger ReferenceTrigger on Reference__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ReferenceHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isDelete) {
            ReferenceHandler.onAfterDelete(Trigger.old);
        }
    }
}