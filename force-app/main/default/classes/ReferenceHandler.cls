public with sharing class ReferenceHandler {
	public static void onAfterInsert(List<Reference__c> references){
		List<ContactShare> contactShares =new List<ContactShare>();
		Map<Id, List<Reference__c>> accountsIdWithReference = new Map<Id, List<Reference__c>>();
		Map<Id, Set<Id>> accountsIdWithUsersId = new Map<Id, Set<Id>>();
		Set<Id> usersId = new Set<Id>();

		for(Reference__c reference: references){
				if(accountsIdWithReference.containsKey(reference.Account__c)){
					accountsIdWithReference.get(reference.Account__c).add(reference);
				}else{
					accountsIdWithReference.put(reference.Account__c, new List<Reference__c>{reference});
				}
		}

		accountsIdWithUsersId = AccountHelper.getAccountsWithUsersByAccounts(accountsIdWithReference.keySet());
		for(Id accId: accountsIdWithReference.keySet()){
			if(accountsIdWithUsersId.containsKey(accId)){
				usersId = accountsIdWithUsersId.get(accId);
				for (Id elem: usersId){
					contactShares.addAll(ContactShareHelper.createContactsSharesByUsersAndReferences(elem, accountsIdWithReference.get(accId)));
				}
			}
		}

		if(!contactShares.isEmpty()){
			insert contactShares;
		}
	}

	public static void onAfterDelete(List<Reference__c> references) {
		Set<Id> contactsId = new Set<Id>();
		List<ContactShare> contactShares = new List<ContactShare>();

		for (Reference__c ref : references) {
			contactsId.add(ref.Contact__c);
		}
		contactShares = ContactShareHelper.getContactsSharesByContacts(contactsId);

		if(!contactShares.isEmpty()){
			delete contactShares;
		}
	}
}