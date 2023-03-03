package db;
import mt.db.Types;

class ZoneAction extends neko.db.Object
{
	static var TABLE_IDS       = ["userId","zoneId","action"];
	static var RELATIONS = function() {
		return [
			{ key : "zoneId", prop : "zone", manager : Zone.manager, lock : false },
			{ key : "userId", prop : "user", manager : User.manager, lock : false }
		];
	}

	public static var manager  = new ZoneManager();

	public var userId(default,null)		: SInt;
	public var zoneId(default,null)		: SInt;
	public var action					: SString<30>;
	public var tries					: SInt;

	public var zone(dynamic,dynamic)	: Zone;
	public var user(dynamic,dynamic)	: User;
	
	public function new( zone:Zone, user:User, action:String ) {
		super();
		this.user = user;
		this.zone = zone;
		this.action = action;
		tries =1;
	}

	public static function addDirectly( user:User, action:String ) {
		var za = new ZoneAction(user.zone, user, action) ;
		za.insert() ;
	}

	public static function add( user : User, action : String, ?bypassSecurity=false, ?n=1 ) {
		if( ZoneAction.manager.hasDoneActionZone( user, action) && !bypassSecurity )
			return;
		
		var z = manager.getWithKeys({userId : user.id, zoneId : user.zoneId, action : action});
		if( z != null ) {
			z.tries += n;
			z.update();
		} else {
			var za = new ZoneAction(user.zone, user, action) ;
			za.tries = n;
			za.insert() ;
		}
	}

	function dbRights() {
		return {
			can : {
				insert : true,
				delete : true,
				modify : true,
				truncate : false,
			},
			invisible : [],
			readOnly : [],
		};
	}

}

private class ZoneManager extends neko.db.Manager<ZoneAction>
{
	public function new() {
		super( ZoneAction );
	}
	
	public function deleteForUser(user:User) {
		execute("DELETE FROM ZoneAction WHERE userId="+user.id);
	}
	
	public function deleteAction(user:User, key:String) {
		execute("DELETE FROM ZoneAction WHERE userId="+user.id+" AND action="+quote(key));
	}
	
	public function deleteAllActions(key:String) {
		execute("DELETE FROM ZoneAction WHERE action="+quote(key));
	}
	
	// Liste des actions effectuées dans une zone précise
	public function getDoneActions( user : User ) : List<String> {
		var rs = results(" SELECT action FROM ZoneAction WHERE userId="+user.id);
		var li = new List();
		for( value in rs )
			li.add( value.action );
		return li;
	}

	// Liste des actions effectuées dans une zone précise
	public function getDoneActionsHash( user : User ) : Hash<Bool> {
		var rs = results(" SELECT action FROM ZoneAction WHERE userId="+user.id);
		var li = new Hash();
		for( value in rs )
			li.set( value.action, true );
		return li;
	}
	
	public function countLocksForZone( zone:Zone, action:String ) {
		return execute("SELECT COUNT(*) FROM ZoneAction WHERE zoneId="+zone.id+" AND action="+quote(action)).getIntResult(0);
	}

	public function countAction( user:User, action:String ) {
		return execute("SELECT SUM(tries) FROM ZoneAction WHERE userId="+user.id+" AND action="+quote(action)).getIntResult(0);
	}

	// Regarde si l'action a été effectuée, quelle que soit la zone
	public function hasDoneAction( user: User, action : String) {
		return execute("SELECT COUNT(*) FROM ZoneAction WHERE userId="+user.id+" AND action="+quote(action)).getIntResult(0) > 0;
	}

	// Regarde si l'action a été effectuée dans la zone de l'utilisateur
	public function hasDoneActionZone(user : User, aid : String) : Bool {
		if( user.zoneId == null ) return false;
		return getWithKeys({userId : user.id, zoneId : user.zoneId, action : aid}) != null;
	}
	
	public function getDoneActionsByZone( user : User ) : Hash<Bool> {
		var rs = results(" SELECT action FROM ZoneAction WHERE userId="+user.id + " AND zoneId="+user.zoneId );
		var li = new Hash();
		for( value in rs )
			li.set( value.action, true );
		return li;
	}

	// Regarde si l'action a été effectuée n fois dans la zone de l'utilisateur
	public function hasDoneCountedActionZone(user : User, aid : String, n : Int) : Bool {
		var r = getWithKeys({userId : user.id, zoneId : user.zone.id, action : aid});
		if( r == null ){
			return false;
		}
		return r.tries >= n;
	}
}
