trigger ContactTrigger on Contact (before insert, before update, before delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ContactHandler.onBeforeInsert(Trigger.new);
        } 
    }
}