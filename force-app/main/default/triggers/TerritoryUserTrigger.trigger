trigger TerritoryUserTrigger on TerritoryUser__c(before insert, before update, before delete, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            TerritoryUserHandler.deleteOldAccountsAndContactsShares(Trigger.old);
        }
        if (Trigger.isInsert) {
            TerritoryUserHandler.insertNewAccAndContactShares(Trigger.new);
        }
        if (Trigger.isDelete) {
            TerritoryUserHandler.deleteOldAccountsAndContactsShares(Trigger.old);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            TerritoryUserHandler.insertNewAccAndContactShares(Trigger.new);
        }
    }
}