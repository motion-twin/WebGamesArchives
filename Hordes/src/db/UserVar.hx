package db;
import Common;
import mt.db.Types;

class UserVar extends neko.db.Object {

	static var INDEXES:Array<Dynamic> = [ ["userId","name",true] ];
	static var RELATIONS = function(){
		return [
			{ key : "userId",	prop : "user",	manager : User.manager, cascade:true }
		];
	}

	public static var manager = new Manager();
	public var id					: SId;
	public var userId(default,null)	: SInt;
	public var name					: SString<32>;
	public var value				: SInt;
	public var persistOnDeath		: SBool; // si TRUE, la variable ne sera pas effacée à la mort du joueur
	public var user( dynamic, dynamic ) : User;

	public function new(user:User, name, value) {
		super();
		this.user = user;
		this.name = name.toLowerCase();
		this.value = value;
		persistOnDeath = false;
	}
	
	public static function getValue(user:User, n:String, ?defValue:Int) {
		var v = manager.getVar(user, n);
		return if( v == null ) defValue else v.value;
	}
	
	public static function getBool(user:User, n:String) {
		var v = manager.getVar(user, n);
		return v != null && v.value == 1;
	}
	
	public static function delete(user:User, n:String) {
		var v = manager.getVar(user, n);
		if( v != null )
			v.delete();
	}
	
	public static function setValue(user:User, n:String, val:Int, ?fl_persisOnDeath = false) {
		var n = n.toLowerCase();
		var v = manager.getVar(user, n, true);
		if( v == null ) {
			v = new UserVar(user, n, val);
			v.persistOnDeath = fl_persisOnDeath;
			v.insert();
		} else {
			v.value = val;
			v.persistOnDeath = fl_persisOnDeath;
			v.update();
		}
	}
}

private class Manager extends neko.db.Manager<UserVar> {
	public function new() {
		super(UserVar);
	}
	
	public function getVar(user:User, n:String, fl_lock = false) {
		var n = n.toLowerCase();
		return	if( fl_lock )
					object(select("userId="+user.id+" AND name="+quote(n)), true);
				else
					object(selectReadOnly("userId="+user.id+" AND name="+quote(n)), false);
	}
	
	public function hasVar(user:User, n:String) {
		var n = n.toLowerCase();
		return count( {userId:user.id, name:n} ) > 0;
	}
	
	public function reset(u:User) {
		execute("DELETE FROM UserVar WHERE userId="+u.id+" AND persistOnDeath=0");
	}
	
	public function deleteAllVars(n:String, ?uids:List<Int>) {
		var n = n.toLowerCase();
		var sql = "DELETE FROM UserVar WHERE name=" + quote(n);
		if ( uids != null ) sql += " AND userId IN(" + uids.join(",") + ")";
		execute(sql); 
	}
	
	public function getAll(uids:List<Int>, n:String, ?lock:Bool = false) {
		var n = n.toLowerCase();
		return objects(select("userId IN ("+uids.join(',')+") AND name=" + quote(n)+""), lock) ;
	}
	
	public function fastInc(userId:Int, n:String, ?inc = 1) {
		var n = n.toLowerCase();
		// création de valeur sans l'objet principal
		var v = object( select("userId="+userId+" AND name="+quote(n)), true);
		if( v != null ) {
			v.value += inc;
			v.update();
			return v.value;
		} else {
			execute("INSERT INTO UserVar(userId,name,value) VALUES ("+userId+", "+quote(n)+", "+inc+")");
			return inc;
		}
	}
	
	public function setVar(userId:Int, n:String, value:Int) {
		var n = n.toLowerCase();
		// création de valeur sans l'objet principal
		var v = object( select("userId="+userId+" AND name="+quote(n)), true);
		if( v != null ) {
			v.value = value;
			v.update();
			return v.value;
		} else {
			execute("INSERT INTO UserVar(userId,name,value) VALUES ("+userId+", "+quote(n)+", "+value+")");
			return value;
		}
	}
}
