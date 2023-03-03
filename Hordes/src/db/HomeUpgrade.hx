package db;
import mt.db.Types;
import Common;

class HomeUpgrade extends neko.db.Object {

	static var INDEXES = [ ["level"] ];
	static var PRIVATE_FIELDS = [ "key","info" ] ;

	static var RELATIONS = function(){
		return [
			{ key : "userId",	prop : "user",	manager : User.manager }
		];
	}

	static var TABLE_IDS = ["userId","upkey"];

    public static var manager  = new HomeUpgradeManager();
	
    public var userId(default,null)	: SInt;
    public var upkey		: SEncoded;
	public var level		: SInt;

	public var user(dynamic,dynamic)	: User;

	public var key : String;
	public var info : HUpgrade;

	public static function add( user : User, upgrade ) {
		var o = manager.getWithKeys(  { userId:user.id, upkey: upgrade.ikey } );
		if( o != null ) {
			o.level++;
			o.update();
			return o;
		}

		o = new HomeUpgrade();
		o.upkey = upgrade.ikey;
		o.user = user;
		o.insert();
		return o;
	}

	public function new() {
		super();
		level = 1;
	}

}

class HomeUpgradeManager extends neko.db.Manager<HomeUpgrade> {

	override private function make( o : HomeUpgrade ) {
		o.key = mt.db.Id.decode( o.upkey );
		o.info = HomeUpgradeXml.getByKey( o.key );
	}

	public function new() {
		super( HomeUpgrade);
	}

	public function deleteForUser(u:User) {
		execute("DELETE FROM HomeUpgrade WHERE userId="+u.id);
	}
	
	public function getUpgradesByUser( u : User ) : List<{upkey:Int,level:Int}>{
		return results( "SELECT upkey, level FROM HomeUpgrade WHERE userId="+u.id+" ORDER BY upkey" );
	}

	public function getUpgradeByUser( u : User, up : HUpgrade, lock = false ) {
		if( lock ) {
			return object( select("userId="+u.id+" AND upkey=" + up.ikey ), true );
		}
		return object( selectReadOnly("userId="+u.id+" AND upkey=" + up.ikey ), false );
	}

	public function getUpgradeByKey( u:User, k:String ) {
		return object( selectReadOnly( "userId="+u.id+" AND upkey="+mt.db.Id.encode(k) ), false  );
	}

	public function reset( u : User ) {
		execute("DELETE FROM HomeUpgrade WHERE userId="+u.id);
	}

	public function hasAvailableAction( u : User, act : String ) {
		for( info in getUpgradesByUser( u ) ) {
			var key = mt.db.Id.decode( info.upkey);
			if( act==key )
				return true;
		}
		return false;
	}

	public function getAvailableActions( u : User ) {
		var list = new List();
		for( info in getUpgradesByUser( u ) ) {
			var key = mt.db.Id.decode( info.upkey);
			var current = HomeUpgradeXml.getByKey( key );
			if( current == null || current.actName=="" || current.actName==null )
				continue;

			var thisLevel = HomeUpgradeXml.getCurrentLevel(current,info.level);
			list.add( { act:key, actName:current.actName, level:thisLevel, limit:HomeUpgradeXml.getLimit(current,info.level) } );
		}
		return list;
	}
}
