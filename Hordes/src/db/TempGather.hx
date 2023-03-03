package db;
import mt.db.Types;

class TempGather extends neko.db.Object {

	static var RELATIONS = function() {
		return [
            { key : "userId",    prop : "user",    manager : User.manager, lock : false }
        ];
	}

	public static var manager = new TempGatherManager();

	public var id : SId;
	public var toolId : SNull<SInt>;
	public var userId(default,null) : SInt;

	public var user(dynamic, dynamic)	: User;

	public static function add( user : User, toolId : Int ) {
		var t = new TempGather();
		t.toolId = toolId;
		t.user = user;
		t.insert();

		return t;
	}

	public function getDescription() : Tool {
		if( toolId == null ) return null;
		return XmlData.getTool( toolId );
	}
}

class TempGatherManager extends neko.db.Manager<TempGather> {
	public function new() {
		super( TempGather );
	}

	public function _getTools( user : User ) {
		return objects( selectReadOnly( "userId="+ user.id + " ORDER BY id"), false );
	}

	public function deleteTools( user : User ) {
		return execute( "DELETE FROM TempGather WHERE userId="+ user.id );
	}
	
}

