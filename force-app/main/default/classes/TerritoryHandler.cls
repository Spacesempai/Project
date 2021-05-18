public with sharing class TerritoryHandler {

	public static void  deleteOldAccountsAndContactsShares(List<Territory__c> territories) {
		List<AccountShare> accountShare = new List<AccountShare>();
		List<ContactShare> contactShares = new List<ContactShare>();
		Set<Id> territoriesId = new Set<Id>();
		Map<Id, Set<Territory__c>> territoryWithFathersTerritories = new Map<Id, Set<Territory__c>>();
		Set<Territory__c> allUpperTerritories = new Set<Territory__c>();
		Set<Id> territoriesWithChildTerritory = new Set<Id>();
		Map<Id, Set<Id>> territoriesIdWithUsersId = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> territoriesIdWithChildTerritoriesId = new Map<Id, Set<Id>>();
		Map<Id, List<Account>> territoriesWithAccounts = new Map<Id, List<Account>>();
		List<Account> accountsByTerritories = new List<Account>();
		Map<Id, Set<Id>> territoriesWithContactsId = new Map<Id, Set<Id>>();
		Set<Id> contactsByAccount = new Set<Id>();

		for (Territory__c elem : territories) {
			territoriesId.add(elem.Id);
		}

		for (Id territoryId : territoriesId) {
			allUpperTerritories = TerritoryHelper.getUpperTerritoriesHierarchy(territoryId);
			territoryWithFathersTerritories.put(territoryId, allUpperTerritories);
			territoriesWithChildTerritory = TerritoryHelper.getTerritoriesWithChildByTerritoriesId(new Set<Id>{territoryId});
			territoriesIdWithChildTerritoriesId.put(territoryId, territoriesWithChildTerritory);
			accountsByTerritories = AccountHelper.getAccountsByTerritories(territoriesWithChildTerritory);
			territoriesWithAccounts.put(territoryId, accountsByTerritories);
			contactsByAccount = ContactHelper.getContactsByAccounts(accountsByTerritories);
			territoriesWithContactsId.put(territoryId, contactsByAccount);


		}
		territoriesIdWithUsersId = TerritoryUserHelper.getUsersByTerritory(territoryWithFathersTerritories);

		accountShare =
				AccountHelper.getAccountSharesByUsersAndAccounts(territoriesWithAccounts, territoriesIdWithUsersId);
		contactShares =
				ContactHelper.getContactSharesByUsersIdAndAccountId(territoriesWithContactsId, territoriesIdWithUsersId);

		if (!accountShare.isEmpty()) {
			delete accountShare;
			if (!contactShares.isEmpty()) {
				delete contactShares;
			}
		}
	}

	public static void installNewSharesForAccountsAndContacts(List<Territory__c> newTerritories, Map<Id, Territory__c> oldTerritories){

		//проверить на повторность!!!!!!!!!!!!!!! deleteOldAccountAndContactShares


		List<Territory__c> territoriesWithoutParentsTerritories = new List<Territory__c>();
		List<Territory__c> territoriesWithParents = new List<Territory__c>();

		for (Territory__c elem: newTerritories){
			if(elem.Territory__c == null){
				territoriesWithoutParentsTerritories.add(elem);
			}else{
				territoriesWithParents.add(elem);
			}
		}

//		deleteOldAccountsAndContactsShares(territoriesWithoutParentsTerritories);


		List<AccountShare> accountsShare = new List<AccountShare>();
		List<ContactShare> contactShares = new List<ContactShare>();
		Set<Id> territoriesId = new Set<Id>();
		Map<Id, Set<Territory__c>> territoriesWithFathersTerritories = new Map<Id, Set<Territory__c>>();
		Set<Territory__c> allUpperTerritories = new Set<Territory__c>();
		Set<Id> territoriesIdWithChildTerritories = new Set<Id>();
		Map<Id, Set<Id>> territoriesIdWithUsersId = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> territoriesIdWithChildTerritoriesId = new Map<Id, Set<Id>>();
		Map<Id, List<Account>> territoriesIdWithAccounts = new Map<Id, List<Account>>();
		List<Account> accountsByTerritories = new List<Account>();
		Map<Id, Set<Id>> territoriesIdWithContactsId = new Map<Id, Set<Id>>();
		Set<Id> contactsIdByAccount = new Set<Id>();

		for (Territory__c elem : territoriesWithParents) {
			territoriesId.add(elem.Id);
		}

		for (Id territoryId : territoriesId) {
			allUpperTerritories = TerritoryHelper.getUpperTerritoriesHierarchy(territoryId);
			territoriesWithFathersTerritories.put(territoryId, allUpperTerritories);
			territoriesIdWithChildTerritories = TerritoryHelper.getTerritoriesWithChildByTerritoriesId(new Set<Id>{territoryId});
			territoriesIdWithChildTerritoriesId.put(territoryId, territoriesIdWithChildTerritories);
			accountsByTerritories = AccountHelper.getAccountsByTerritories(territoriesIdWithChildTerritories);
			territoriesIdWithAccounts.put(territoryId, accountsByTerritories);
			contactsIdByAccount = ContactHelper.getContactsByAccounts(accountsByTerritories);
			territoriesIdWithContactsId.put(territoryId, contactsIdByAccount);
		}
		territoriesIdWithUsersId = TerritoryUserHelper.getUsersByTerritory(territoriesWithFathersTerritories);

		accountsShare = AccountHelper.createAccountSharesByAccountAndUsersId(
																		territoriesIdWithAccounts,
																		territoriesIdWithUsersId);
		contactShares = ContactHelper.createContactsSharesByUsersIdAndAccountId(territoriesIdWithContactsId, territoriesIdWithUsersId);

		if (!accountsShare.isEmpty()) {
			insert accountsShare;
			if (!contactShares.isEmpty()) {
				insert contactShares;
			}
		}
	}

	public static void checkAndDeleteOldAccountAndContactShares(List<Territory__c> newTerritories, Map<Id,Territory__c> oldTerritories) {
		List<Territory__c> modifiedTerritories = new List<Territory__c>();

		for (Territory__c elem: newTerritories){
			if(elem.Territory__c != oldTerritories.get(elem.Id).Territory__c){
				modifiedTerritories.add(elem);
			}
		}
		deleteOldAccountsAndContactsShares(modifiedTerritories);
	}
}