public with sharing class AccountHandler {

	public static void insertAccountAndContactShares(List<Account> accounts) {
		List<AccountShare> accountShares = new List<AccountShare>();
		List<ContactShare> contactShare = new List<ContactShare>();
		List<Reference__c> accountReferences = new List<Reference__c>();
		Set<Id> accountsId = new Set<Id>();
		Map<Id, Set<Territory__c>> accountWithTerritories = new Map<Id, Set<Territory__c>>();

		for(Account acc: accounts){
			accountsId.add(acc.Id);
		}

		accountWithTerritories = TerritoryHelper.getTerritoriesWithParentsByAccount(accounts);
		accountShares = AccountHelper.getAccountSharesByAccountAndTerritories(accountWithTerritories);

		if (!accountShares.isEmpty()) {
			insert accountShares;
		}

		accountReferences = ReferenceHelper.getReferencesByAccounts(accountsId);

		for (Id accountId : accountWithTerritories.keySet()) {
			for (Territory__c territories : accountWithTerritories.get(accountId)) {
				if (territories.TerritoryUsers__r != null) {
					for (TerritoryUser__c TerritoryUser : territories.TerritoryUsers__r) {
						if(TerritoryUser.User__c != null) {
							contactShare.addAll(ContactShareHelper.createContactsSharesByUsersAndReferences(TerritoryUser.User__c, accountReferences));
						}
					}
				}
			}
		}

		if(!contactShare.isEmpty()){
			insert contactShare;
		}

	}

	public static void deleteContactSharesByAccounts(List<Account> accounts) {
		List<ContactShare> contactShares = new List<ContactShare>();
		Set<Id> contactsId = ContactHelper.getContactsByAccounts(accounts);

		contactShares = ContactShareHelper.getContactsSharesByContacts(contactsId);

		if(!contactShares.isEmpty()){
			delete contactShares;
		}
	}

	public static void deleteOldSharesAndInsertNewShares(List<Account> newAccounts, Map<Id, Account> oldAccounts) {
		Map<Id, Account> accountsWithNewTerritories = new Map<Id, Account>();
		Map<Id, Account> accountsWithOldTerritories = new Map<Id, Account>();

		for (Account account: newAccounts){
			if(account.Territory__c != oldAccounts.get(account.Id).Territory__c	){
				accountsWithOldTerritories.put(account.Id, account);
				if(account.Territory__c != null){
					accountsWithNewTerritories.put(account.Id, account);
				}
			}
		}
		if(!accountsWithOldTerritories.isEmpty()){
			AccountHelper.deleteOldAccountContactShares(accountsWithOldTerritories);
		}

		insertAccountAndContactShares(accountsWithNewTerritories.values());

	}
}