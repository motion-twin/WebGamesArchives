package data;
import Common;

typedef GuardianInfo = {
	var def : Int;
	var base : GuardianBaseInfo;
	var survivalBonus : Int;
	var status : List<GuardianStatusInfo>;
	var tools : List<GuardianToolInfo>;
	var job : GuardianJobInfo;
}

typedef GuardianBaseInfo = {
	var baseDef : Int;
}

typedef GuardianJobInfo = {
	var key : String;
	var def : Int;
	var survivalBonus	: Int;
}

typedef GuardianStatusInfo = {
	var status 	: String;
	var def		: Int;
	var survivalBonus	: Int;
}

typedef GuardianToolInfo = {
	var key : String;
	var def : Int;
}

class Guardians {

	static var JOB_INFOS 	= ods.Data.parse( "ods/veilleurs.ods", "Jobs", GuardianJobInfo );
	static var STATUS_INFOS = ods.Data.parse( "ods/veilleurs.ods", "Status", GuardianStatusInfo );
	static var TOOLS_INFOS 	= ods.Data.parse( "ods/veilleurs.ods", "Weapons", GuardianToolInfo );
	public static var BASE 	= ods.Data.parse( "ods/veilleurs.ods", "Resume", GuardianBaseInfo )[0];
	public static var BASE_DEF = BASE.baseDef;
	
	static function getCacheFile( file ) {
		return Config.ROOT+ file;
	}
	
	public static function getJobInfo( jobKey : String ) : GuardianJobInfo {
		for( info in JOB_INFOS )
			if( info.key == jobKey )
				return info;
		return null;
	}
	
	public static function getEmptyJobInfo() : GuardianJobInfo {
		return { key:null, def:0, survivalBonus:0 };
	}
	
	public static function getStatusInfo( status : String ) : GuardianStatusInfo {
		for( info in STATUS_INFOS )
			if( info.status == status )
				return info;
		return null;
	}
	
	public static function getToolInfo( toolKey : String, ?map : db.Map ) : GuardianToolInfo {
		for( info in TOOLS_INFOS ) {
			if( info.key == toolKey ) {
				var info = Reflect.copy( info );
				if( map != null ) {
					var t = XmlData.getToolByKey( toolKey );
					
					if( map.hasCityBuilding("catapult3") && t.hasType(Animal) )
						info.def = Std.int( info.def * 1.2 );
					
					if( map.hasCityBuilding("tourello") && (t.action == "waterGun" || toolKey == "grenade" || toolKey == "bGrenade") )
						info.def = Std.int( info.def * 1.2 );
					
					if( map.hasCityBuilding("armor") && t.hasType(Weapon) )
						info.def = Std.int( info.def * 1.2 );
					
					if( map.hasCityBuilding("ikea") && t.hasType(Furniture) )
						info.def = Std.int( info.def * 1.2 );
				}
				return info;
			}
		}
		return null;
	}
}
