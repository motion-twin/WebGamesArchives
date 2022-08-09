typedef SectorInfos = {
	id : Int,
	seed : Int,
	width : Int, // max 65 environ
	height : Int, // max 65 environ
	name : String,
}

@:native('_sS')
enum SystemStatus {
	SLocked( cost : Int );
	SOpen;
}

typedef SystemInfos = {
	var id : Int;
	var seed : Int;
	var name : String;
	var x : Int;
	var y : Int;
	var status : SystemStatus;
	var planets : Array<SystemPlanetInfos>;
}

@:native('_sK')
enum SystemPlanetKind {
	SPlanet;
	SGas;
}

@:native('_sP')
enum SystemPlanetStatus {
	PUnexplored;
	PActive;
	PAbandonned;
	PInvited; // Active - invité
	PForbidden; // Not shared
}

typedef SystemPlanetInfos = {
	var id : Int;
	var seed : Int;
	var size : Int;
	var distance : Int; // 0-15
	var name : String;
	var status : SystemPlanetStatus;
	var kind : SystemPlanetKind;
	var biome : Common.BiomeKind;
	var bname : String;
}

@:native('_sp')
enum ShipPosition {
	PInSector( x : Int, y : Int );
	PInSystem( id : Int );
	PPlanet( id : Int );
}

typedef ExploreInfos = {
	var url : String;
	var ship : Null<{ data : haxe.io.Bytes, pos : ShipPosition, energy : Int }>;
	var sector : SectorInfos;
	var systems : Array<SystemInfos>;
	var holes : Array<{ x : Int, y : Int, targetId : Int, targetName : String }>;
	var texts : Hash<String>;
	var freeLicense : Bool;
}

@:native('_EA')
enum ExploreAction {
	ASetShipPos( p : ShipPosition );
	AUnlockSystem( id : Int );			// CLoadSystem/CNo
	ALandPlanet( id : Int );
	ADiscardPlanet( id : Int );
	ASendChunk( id : Int, x : Int, y : Int, data : haxe.io.Bytes );
	AInitPlanet( id : Int, inf : { sx : Int, sy : Int, sz : Int, water : Int, wlevel : Int } );
	ARenamePlanet( id : Int, name : String );
	APlanetError( id : Int, err : Int );
}

@:native('_EC')
enum ExploreCommand {
	COk;
	CNo( text : String );
	CSetEnergy( e : Int );
	CLoadSystem( s : SystemInfos );
	CGoto( url : String );
//	CReload( e : ExploreInfos );
}
