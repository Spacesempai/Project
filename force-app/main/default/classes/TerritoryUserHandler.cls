public with sharing class TerritoryUserHandler {

	public static void insertNewAccAndContactShares(List<TerritoryUser__c> newTerritoryUser) {
		List<AccountShare> accountsShares = new List<AccountShare>();
		List<ContactShare> contactsShares = new List<ContactShare>();
		Map<Id, Set<Id>> usersIdWithTerritoryIncludeChild = new Map<Id, Set<Id>>();
		for (TerritoryUser__c TerritoryUser : newTerritoryUser) {
			if (usersIdWithTerritoryIncludeChild.containsKey(TerritoryUser.User__c)) {
				usersIdWithTerritoryIncludeChild.get(TerritoryUser.User__c).add(TerritoryUser.Territory__c);
			} else {
				if (TerritoryUser.User__c != null) {
					usersIdWithTerritoryIncludeChild.put(TerritoryUser.User__c, new Set<Id>{TerritoryUser.Territory__c});
				}
			}

			for (Id userId : usersIdWithTerritoryIncludeChild.keySet()) {
				Set<Id> territoriesIdIncludeChild = new Set<Id>();
				territoriesIdIncludeChild =	TerritoryHelper.getTerritoriesWithChildByTerritoriesId(usersIdWithTerritoryIncludeChild.get(userId));
				usersIdWithTerritoryIncludeChild.put(userId, territoriesIdIncludeChild);

				List<Account> accounts = ReferenceHelper.getAccountByTerritoriesId(usersIdWithTerritoryIncludeChild.get(userId));
				for (Account account : accounts) {
					accountsShares.add(AccountShareHelper.createAccountShareByUserAndAccount(userId, account.Id));
					contactsShares.addAll(ContactShareHelper.createContactsSharesByUsersAndReferences(userId, account.References__r));
				}

			}	
		}
		if (!accountsShares.isEmpty()) {
			insert accountsShares;
			if (!contactsShares.isEmpty()) {
				insert contactsShares;
			}
		}
	}
	public static void deleteOldAccountsAndContactsShares(List<TerritoryUser__c> oldTerritoryUser) {
		Set<Id> accountsIdByTerritory = new Set<Id>();
		Set<Id> contactsIdByAccount = new Set<Id>();
		Map<Id, Set<Id>> usersIdWithTerritoryIncludeChild = new Map<Id, Set<Id>>();

		for (TerritoryUser__c elem : oldTerritoryUser) {
			if (usersIdWithTerritoryIncludeChild.containsKey(elem.User__c)) {
				usersIdWithTerritoryIncludeChild.get(elem.User__c).add(elem.Territory__c);
			} else {
				usersIdWithTerritoryIncludeChild.put(elem.User__c, new Set<Id>{elem.Territory__c});
			}
			for (Id userId : usersIdWithTerritoryIncludeChild.keySet()) {
				Set<Id> territoriesIdIncludeChild = new Set<Id>();
				territoriesIdIncludeChild =
						TerritoryHelper.getTerritoriesWithChildByTerritoriesId(usersIdWithTerritoryIncludeChild.get(userId));
				System.debug(territoriesIdIncludeChild);

				usersIdWithTerritoryIncludeChild.put(userId, territoriesIdIncludeChild);

				List<Account> accountsByTerritory = ReferenceHelper.getAccountByTerritoriesId(usersIdWithTerritoryIncludeChild.get(userId));
				for (Account account: accountsByTerritory){
					accountsIdByTerritory.add(account.Id);
					for(Reference__c reference: account.References__r){
						contactsIdByAccount.add(reference.Contact__c);
					}
				}
			}
			AccountShareHelper.deleteAccountsSharesByUsersIdAndAccountsId(usersIdWithTerritoryIncludeChild.keySet(), accountsIdByTerritory);
			ContactShareHelper.deleteContactsSharesByUsersIdAndContactsId(usersIdWithTerritoryIncludeChild.keySet(), contactsIdByAccount);
		}
	}
}