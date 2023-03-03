package tools;
import data.Explo;

private typedef ExploResources = {
	var common 	: Array<db.Tool>;
	var rare 	: Array<db.Tool>;
	var unusual	: Array<db.Tool>;
}

private typedef ExploPlans = {
	var epic 	: Array<db.Tool>;
	var rare 	: Array<db.Tool>;
	var unusual	: Array<db.Tool>;
}

// TODO utiliser des probas non égalitaires ?

class ExploTool {
	static var bunkerResources 	: ExploResources = { common:[], rare:[], unusual:[] };
	static var hotelResources 	: ExploResources = { common:[], rare:[], unusual:[] };
	static var hospitalResources: ExploResources = { common:[], rare:[], unusual:[] };
	
	static var bunkerBuildings		: Array<Building> = [];
	static var hotelBuildings		: Array<Building> = [];
	static var hospitalBuildings	: Array<Building> = [];
	
	public static function addResource( pExploKind:ExploKind, pRscKind:ExploResourceKind, tool : db.Tool ) {
		var allResources = getResources(pExploKind);
		var resources = switch( pRscKind ) {
			case Common		: allResources.common;
			case Rare 		: allResources.rare;
			case Unusual	: allResources.unusual;
		}
		resources.push(tool);
	}
	
	public static function addBuilding( pExploKind:ExploKind, b : Building ) {
		var buildings = getBuildings(pExploKind);
		buildings.push(b);
	}
	
	public static function getRandomResource( pExploKind:ExploKind, pRscKind:ExploResourceKind ) {
		var allResources = getResources(pExploKind);
		var resources = switch( pRscKind ) {
			case Common		: allResources.common;
			case Rare 		: allResources.rare;
			case Unusual	: allResources.unusual;
		}
		return resources[Std.random(resources.length)];
	}
	
	public static function getResources( pExploKind:ExploKind ) {
		return switch( pExploKind ) {
			case Bunker 	: bunkerResources;
			case Hospital	: hospitalResources;
			case Hotel		: hotelResources;
		}
	}
	
	public static function getBuildings( pExploKind:ExploKind ) {
		return switch( pExploKind ) {
			case Bunker 	: bunkerBuildings;
			case Hospital	: hospitalBuildings;
			case Hotel		: hotelBuildings;
		}
	}
}