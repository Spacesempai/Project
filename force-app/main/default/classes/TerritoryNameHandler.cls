public with sharing class TerritoryNameHandler{
	public static void checkUniqueName(List<Territory__c> newRecords){
		List<Territory__c> territoriesWithoutParent = new List<Territory__c>();
		List<Territory__c> territoriesWhithParent = new List<Territory__c>();
		Set<Id> parentTerritoryIds = new Set<Id>();

		for(Territory__c elem: newRecords){
			if(elem.Territory__c != null){
				territoriesWhithParent.add(elem);
				parentTerritoryIds.add(elem.Territory__c);

			}else{
				territoriesWithoutParent.add(elem);
			}
		}
		if(!territoriesWhithParent.isEmpty()){
			Map<Id, Territory__c> allTerritoryWithParents = getChildTerritoryByParent(parentTerritoryIds);
			if(!allTerritoryWithParents.isEmpty()) {
				for (Territory__c elem : newRecords) {
					compareNames(elem, allTerritoryWithParents.get(elem.Territory__c).Territory__r);
				}
			}
		}
		if (!territoriesWithoutParent.isEmpty()){
			List<Territory__c> territoriesWithoutChild = getTerritoriesWithoutChild();
			for(Territory__c elem: territoriesWithoutParent){
				compareNames(elem, territoriesWithoutChild);
			}
		}
	}
	private static Map<Id,Territory__c> getChildTerritoryByParent(Set<Id> parentTerritory){
		return new Map<Id,Territory__c>([
				Select id,
            Name,
            (SELECT Name, Territory__c FROM Territory__r)
            FROM Territory__c
            Where Id IN :parentTerritory
		]);
	}
	private static void compareNames(Territory__c newTerritory, List<Territory__c> oldTerritories){
		for(Territory__c elem: oldTerritories){
			if(newTerritory.Name == elem.Name){
				newTerritory.addError('Territory already exists');
			}
		}
	}

	private static List<Territory__c> getTerritoriesWithoutChild(){
		return [
			SELECT
				Name
			FROM Territory__c
			WHERE Territory__c = null
		];
	}

}