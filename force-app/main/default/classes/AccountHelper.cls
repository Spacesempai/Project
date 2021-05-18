public with sharing class AccountHelper {

	public static List<AccountShare> getAccountSharesByAccountAndTerritories(Map<Id, Set<Territory__c>> accountWithTerritories) {
		List<AccountShare> result = new List<AccountShare>();

		for (Id accountId : accountWithTerritories.keySet()) {
			for (Territory__c territories : accountWithTerritories.get(accountId)) {
				if (territories.TerritoryUsers__r != null) {
					for (TerritoryUser__c TerritoryUser : territories.TerritoryUsers__r) {
						if(TerritoryUser.User__c != null) {
							result.add(AccountShareHelper.createAccountShareByUserAndAccount(TerritoryUser.User__c, accountId));
						}
					}
				}
			}
		}

		return result;
	}


	public static void deleteOldAccountContactShares(Map<Id,Account > oldAccounts){
		List<AccountShare> accountShare = new List<AccountShare>();

		accountShare = AccountHelper.getAccountSharesByAccount(oldAccounts.values());

		if(!accountShare.isEmpty()){
			delete accountShare;
		}

		AccountHandler.deleteContactSharesByAccounts(oldAccounts.values());
	}

	public static List<AccountShare> getAccountSharesByAccount(List<Account> accounts) {
		return [SELECT Id
				FROM AccountShare
				WHERE AccountId IN :accounts
		    	AND RowCause = 'Manual'
		];
	}

	public static Map<Id, Set<Id>> getAccountsWithUsersByAccounts(Set<Id> accountsId) {
		Map<Id, Set<Id>> result = new Map<Id, Set<Id>>();

		List<AccountShare> accountShares= [SELECT Id,
		 											AccountId,
		 											UserOrGroupId
		 									FROM AccountShare
		 									WHERE AccountId IN : accountsId
											AND RowCause = 'Manual'
		];

		for(AccountShare elem: accountShares){
			if(result.containsKey(elem.AccountId)){
				result.get(elem.AccountId).add(elem.UserOrGroupId);
			}else{
				result.put(elem.AccountId, new Set<Id>{elem.UserOrGroupId});
			}
		}

		return result;
	}

	public static List<Account> getAccountsByTerritories(Set<Id> territoriesId) {
		return [SELECT Id,
						Name,
			   (SELECT Id, Contact__c FROM References__r)
				FROM Account
				WHERE Territory__c IN :territoriesId
		];
	}

	public static List<AccountShare> getAccountSharesByUsersAndAccounts(Map<Id, List<Account>> territoryWithAccounts,
																		  			Map<Id, Set<Id>> territoryIdWithUsersId) {
		List<AccountShare> result = new List<AccountShare>();
		List<AccountShare> accountShares = new List<AccountShare>();

		for(Id territoryId: territoryWithAccounts.keySet()){
			if(territoryIdWithUsersId.containsKey(territoryId)){
				accountShares = getSharesByUsersIdAndAccount(territoryWithAccounts.get(territoryId),
																		territoryIdWithUsersId.get(territoryId));
				result.addAll(accountShares);
			}
		}

		return result;
	}

	private static List<AccountShare> getSharesByUsersIdAndAccount(List<Account> accounts, Set<Id> usersId) {
		return [SELECT Id
				FROM AccountShare
				WHERE AccountId IN :accounts
				AND UserOrGroupId IN :usersId
				AND RowCause = 'Manual'
		];
	}

	public static List<AccountShare> createAccountSharesByAccountAndUsersId(Map<Id, List<Account>> territoryWithAccounts,
																			Map<Id, Set<Id>> territoryIdWithUsersId) {
		List<AccountShare> result = new List<AccountShare>();
		List<AccountShare> accountShare = new List<AccountShare>();

		for(Id territoryId: territoryWithAccounts.keySet()){
			if(territoryIdWithUsersId.containsKey(territoryId) ) {
				accountShare = createAcccontactShares(territoryWithAccounts.get(territoryId),
						territoryIdWithUsersId.get(territoryId));
				result.addAll(accountShare);
			}
		}

		return result;
	}

	private static List<AccountShare> createAcccontactShares(List<Account> accounts, Set<Id> usersId) {
		List<AccountShare> result = new List<AccountShare>();

		for(Account account: accounts){
			for(Id userId: usersId){
				result.add(AccountShareHelper.createAccountShareByUserAndAccount(userId, account.Id));
			}
		}

		return result;
	}
}