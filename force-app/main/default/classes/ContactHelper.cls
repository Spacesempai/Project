public with sharing class ContactHelper {

	public static Set<Id> getContactsByAccounts(List<Account> accountsId) {
		Set<Id> contactsId = new Set<Id>();

		List<Reference__c> references = [SELECT Id,
		 								 		  Contact__c
		 								  FROM Reference__c
		 								  WHERE Account__c IN :accountsId
		];

		for (Reference__c elem: references){
			contactsId.add(elem.Contact__c);
		}

		return contactsId;
	}

	public static List<ContactShare> getContactSharesByUsersIdAndAccountId(Map<Id, Set<Id>> territoryWithContactId,
																		   Map<Id, Set<Id>> territoryIdWithUsersId) {
		List<ContactShare> result = new List<ContactShare>();
		List<ContactShare> contactsShares = new List<ContactShare>();

		for(Id territoryId: territoryWithContactId.keySet()){
			if(territoryIdWithUsersId.containsKey(territoryId)){
				contactsShares = getContactsSharesByUsersIdAndContactsId(territoryWithContactId.get(territoryId),territoryIdWithUsersId.get(territoryId));
				result.addAll(contactsShares);
			}
		}

		return result;
	}

	private static List<ContactShare> getContactsSharesByUsersIdAndContactsId(Set<Id> contactsId, Set<Id> usersId) {
		return [SELECT Id
				FROM ContactShare
				WHERE ContactId IN :contactsId
				AND UserOrGroupId IN :usersId
				AND RowCause = 'Manual'
		];
	}

	public static List<ContactShare> createContactsSharesByUsersIdAndAccountId(Map<Id, Set<Id>> territoryWithContacts,
																			   Map<Id, Set<Id>> territoryIdWithUsersId) {
		List<ContactShare> result = new List<ContactShare>();
		List<ContactShare> contactsShares = new List<ContactShare>();

		for(Id territoryId: territoryWithContacts.keySet()){
			if(territoryIdWithUsersId.containsKey(territoryId)) {
				contactsShares = createContactsShares(territoryWithContacts.get(territoryId),
						territoryIdWithUsersId.get(territoryId));
				result.addAll(contactsShares);
			}
		}

		return result;
	}

	private static List<ContactShare> createContactsShares(Set<Id> contactsId, Set<Id> usersId) {
		List<ContactShare> result = new List<ContactShare>();

		for(Id contactId: contactsId){
			for(Id userId: usersId){
				result.add(ContactShareHelper.createContactShareByUserIdAndContactId(userId, contactId));
			}
		}

		return result;
	}
 }