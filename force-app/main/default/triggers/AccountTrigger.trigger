trigger AccountTrigger on Account(before delete, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            AccountHandler.deleteContactSharesByAccounts(Trigger.old);
        }
    }
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                AccountHandler.insertAccountAndContactShares(Trigger.new);
            }
            if (Trigger.isUpdate) {
                AccountHandler.deleteOldSharesAndInsertNewShares(Trigger.new, Trigger.oldMap);
            }
        }
    }