public class ContactHandler {
	public static void onBeforeInsert(List<Contact> contacts){
		String dummyAccount = getDummyAccount();

		for(Contact elem: contacts){
			if(elem.AccountId == null){
				elem.AccountId = dummyAccount;
			}
		}
	}

	private static String getDummyAccount(){
		List<Account> dummyAccount = [
				SELECT Id,
				Name
				FROM Account
				WHERE Name = 'Dummy'
		LIMIT 1
		];
		if(dummyAccount.isEmpty()){
			Account newDummyAccount = new Account(Name = 'Dummy');
			dummyAccount.add(newDummyAccount);
			insert dummyAccount;
		}
		return dummyAccount[0].Id;
	}

}