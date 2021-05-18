public class ContactShareHelper {

	public static List<ContactShare> createContactsSharesByUsersAndReferences(Id userId, List<Reference__c> references){
		List<ContactShare> contactsShares = new List<ContactShare>();

		for(Reference__c elem: references){
			ContactShare contactShare = new ContactShare();
			contactShare.ContactId = elem.Contact__c;
			contactShare.ContactAccessLevel = 'Edit';
			contactShare.UserOrGroupId = userId;
			contactShare.RowCause = 'Manual';
			contactsShares.add(contactShare);
		}

		return contactsShares;
	}



	public static void deleteContactsSharesByUsersIdAndContactsId(Set<Id> usersId, Set<Id> contactsId) {
		List<ContactShare> contactsShares = [
					SELECT Id
					FROM ContactShare
					WHERE UserOrGroupId IN:usersId
					AND ContactId IN:contactsId
					AND RowCause ='Manual'
		];

		if(!contactsShares.isEmpty()){
			delete contactsShares;
		}
	}

	public static List<ContactShare> getContactsSharesByContacts(Set<Id> contactsId) {
		return [SELECT Id
				FROM ContactShare
				WHERE ContactId IN :contactsId
				AND RowCause ='Manual'
				];
	}

	public static ContactShare createContactShareByUserIdAndContactId(Id userId, Id contactId) {
		ContactShare contactShare = new ContactShare();

		contactShare.ContactId = contactId;
		contactShare.ContactAccessLevel = 'Edit';
		contactShare.UserOrGroupId = userId;
		contactShare.RowCause = 'Manual';

		return contactShare;
	}
}