package db;
import mt.db.Types;

class GatheredObject extends neko.db.Object {

	static var INDEXES = [ ["used"] ];

	static var TABLE_IDS       = ["userId","toolId"];

	static var RELATIONS = function() {
		return [
            { key : "userId",    prop : "user",    manager : cast User.manager }
        ];
	}

	public static var manager = new GatheredObjectManager();

	public var toolId : SInt;
	public var userId(default, null) : SInt;
	public var count : SInt;
	public var used : SBool;
	public var user(dynamic, dynamic)	: User;

	public function new() {
		super();
		count = 1;
		used = false;
	}

	public static function use( toolId : Int, user : User ) {
		var o = manager.getWithKeys( { userId : user.id, toolId : toolId });
		if( o == null ) return; // Ne devrait jamais arriver

		o.used = true;
		o.update();
	}

	public static function add( toolId : Int, user : User ) {
		var o = manager.getWithKeys( { userId : user.id, toolId : toolId });
		if( o != null ) {
			o.count++;
			o.update();
			return o;
		}

		o = new GatheredObject();
		o.toolId = toolId;
		o.user = user;
		o.insert();
		return o;
	}
}


private class GatheredObjectManager extends neko.db.Manager<GatheredObject> {

	public function new() {
		super( GatheredObject );
	}

	public function getByUserId( user : User ) {
		return objects( selectReadOnly("userId="+user.id), false );
	}

	public function getDropRate() {
		return results("SELECT toolId, sum(count) as `count` FROM GatheredObject GROUP BY toolId ORDER BY `count` DESC" );
	}

	public function getTotalDropCount() {
		return execute("SELECT sum(count) as total FROM GatheredObject" ).getIntResult(0);
	}
	
}
