public with sharing class AccountShareHelper {

		public static AccountShare createAccountShareByUserAndAccount(Id userId, Id accountId){
			AccountShare accountShare = new AccountShare();

			accountShare.AccountId = accountId;
			accountShare.UserOrGroupId = userId;
			accountShare.AccountAccessLevel = 'Edit';
			accountShare.ContactAccessLevel = 'None';
			accountShare.OpportunityAccessLevel ='None';
			accountShare.CaseAccessLevel = 'None';

			return accountShare;
		}

	public static void deleteAccountsSharesByUsersIdAndAccountsId(Set<Id> usersId, Set<Id> accountsId){
		List<AccountShare> accountShares = [
					SELECT Id,
					UserOrGroupId,
					AccountId,
					RowCause
					FROM AccountShare
					WHERE UserOrGroupId IN:usersId
					AND AccountId IN:accountsId
					AND RowCause ='Manual'
		];

		if(!accountShares.isEmpty()){
			delete accountShares;
		}
	}
}