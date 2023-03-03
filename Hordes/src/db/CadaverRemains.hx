package db;
import Common;
import mt.db.Types;

class CadaverRemains extends neko.db.Object {


	static var RELATIONS = function(){
		return [
			{ key : "cadaverId",	prop : "cadaver",	manager : Cadaver.manager, lock : false },
		];
	}

	public static var manager = new CadaverRemainsManager();

	public var id : SId;
	public var cadaverId(default,null) : SInt;
	public var toolId : SInt;
	public var isBroken : SBool;

	public var cadaver(dynamic, dynamic) : Cadaver;

	public function hasType(type:ToolType) {
		return getTool().hasType(type);
	}
	
	public function getTool() {
		return XmlData.getTool(toolId);
	}
	
	public function getIcon() {
		return getTool().icon;
	}
}

private class CadaverRemainsManager extends neko.db.Manager<CadaverRemains> {

	public function new() {
		super( CadaverRemains );
	}

	public function getByCadaver(cadaver : Cadaver) {
		var rs= Lambda.array( objects(selectReadOnly("cadaverId="+cadaver.id),false) );
		rs.sort( function( o1,o2) { if( o1.toolId > o2.toolId ) return 1; if (o2.toolId>o1.toolId) return -1; return 0; } );
		return Lambda.list( rs );
	}

	public function getByCadavers( ids: List<Int>) {
		var rs= Lambda.array( objects(selectReadOnly("cadaverId IN ("+ids.join( ",")+")"),false) );
		rs.sort( function( o1,o2) { if( o1.toolId > o2.toolId ) return 1; if (o2.toolId>o1.toolId) return -1; return 0; } );
		return Lambda.list( rs );
	}

	public function convertTools( user : User, cadaver : Cadaver, ?houseOnly : Bool ) {
		var banMod = if(user.map != null) user.map.hasMod("BANNED")
					 else db.GameMod.hasMod("BANNED");
		
		if( user.isCityBanned && banMod ) {
			// note de banni (révèle une cache d'objets)
			var note = XmlData.getToolByKey("banned_note");
			execute("INSERT INTO CadaverRemains ( cadaverId, toolId, isbroken ) VALUES ("+cadaver.id+", "+note.toolId+", 0)");
		}
		if( houseOnly ) {
			execute("INSERT INTO CadaverRemains ( cadaverId, toolId, isbroken ) ( SELECT "+cadaver.id+", toolId, isBroken FROM Tool WHERE soulLocked= 0 AND inBag=0 AND userId="+user.id+ ")");
			execute("DELETE FROM Tool WHERE inBag=0 AND userId="+user.id);
		} else {
			execute("INSERT INTO CadaverRemains ( cadaverId, toolId, isbroken ) ( SELECT "+cadaver.id+", toolId, isBroken FROM Tool WHERE soulLocked= 0 AND userId="+user.id+ ")");
			execute("DELETE FROM Tool WHERE userId="+user.id);
		}
	}

	public function deleteCadaverTools( cadaverId : Int ) {
		execute("DELETE FROM CadaverRemains WHERE cadaverId="+cadaverId);
	}

}
