public with sharing class TerritoryUserHelper {
	public static Map<Id, Set<Id>> getUsersByTerritory(Map<Id, Set<Territory__c>> territoryIdWithFathersTerritory) {
		Map<Id, Set<Id>> result = new Map<Id, Set<Id>>();
		Set<Id> usersId =new Set<Id>();
		for(Id idTerritory: territoryIdWithFathersTerritory.keySet()){
			usersId = getUsersByTerritories(territoryIdWithFathersTerritory.get(idTerritory));
			if(!usersId.isEmpty()){
				result.put(idTerritory, usersId);
			}
		}
		return result;
	}
	private static Set<Id> getUsersByTerritories(Set<Territory__c> territories) {
		Set<Id> usersId = new Set<Id>();
		Set<Id> territoriesId = new Set<Id>();
		for(Territory__c elem: territories){
			territoriesId.add(elem.Id);
		}
		List<TerritoryUser__c> TerritoryUsers= [SELECT Id,
							Territory__c,
							User__c
							FROM TerritoryUser__c
							WHERE Territory__c IN :territoriesId];
		for(TerritoryUser__c TerritoryUser: TerritoryUsers){
			if(TerritoryUser.User__c!=null){
				usersId.add(TerritoryUser.User__c);
			}
		}
		return usersId;
	}
}