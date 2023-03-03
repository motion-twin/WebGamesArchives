package db;
import mt.db.Types;
import Common;
import tools.Utils;

class Tool extends neko.db.Object {

	static var INDEXES = [ ["toolId","userId"], ["userId","inBag"] ];

	static var RELATIONS = function(){
		return [
			{ key : "userId",	prop : "user",	manager : User.manager },
		];
	}

	static var PRIVATE_FIELDS	= [
		"name" ,
		"isHeavy",
		"types",
		"loss_probability",
		"broken",
		"power",
		"random",
		"deco",
		"bonus",
		"transport",
		"description",
		"replacement",
		"icon",
		"key",
		"action",
		"limit",
		"lock",
		"parts",
		"hero",
		//"guard",
		"ghoulProba",
	] ;
	
	public static var manager  = new ToolManager() ;
	
	/* database */
	public var id				: SId;
	public var toolId			: SInt;
	public var userId(default,null)			: SInt;
	public var isBroken			: SBool;
	public var inBag			: SBool;
	public var soulLocked		: SBool;
	public var decoPoints		: SInt;
	public var user(dynamic,dynamic): User;
	
	/* xml */
	public var name				: String;
	public var isHeavy			: Bool;
	public var types			: List<String>;
	public var loss_probability	: Int;
	public var broken			: Int;
	public var power			: Float;
	public var random			: Int;
	public var deco				: Int;
	public var bonus			: String;
	public var transport		: Int;
	public var description		: String;
	public var replacement		: Array<String>;
	public var icon				: String;
	public var key				: String;
	public var action			: String;
	public var limit			: String;
	public var lock 			: String;
	public var parts			: List<String>;
	public var hero				: Bool;
	//public var guard(getGuard, null):Int;
	public var ghoulProba		: Int;
	
	public function new() {
		super();
		//guard = 0;
		isBroken = false;
		transport = 0;
		inBag = false;
		types = new List();
		key="";
		action ="";
		limit="";
		isHeavy = false;
		replacement = new Array();
		lock = null;
		icon = "";
		decoPoints = 0;
		random = 0;
		soulLocked = false;
		ghoulProba = null;
	}
	
	public function getGuard( map ) {
		var info = data.Guardians.getToolInfo( this.key, map );
		return info == null ? 0 : info.def;
	}
	
	public override function toString() {
		return Utils.toString( this );
	}
	
	public function getInfo() {
		return XmlData.getTool( toolId );
	}
	
	public function getRandom() {
		return if(random > 0) Std.random(random) else 0;
	}
	
	public function isStealthy() {
		return hasType(Stealthy) || hasType(Food) || hasType(Beverage) || hasType(Drug);
	}
	
	public function use() {
		if( isBroken ) return;
	}
	
	public static function addByKey( k:String, user : User, ?inBag : Bool ) {
		var xmlTool = XmlData.getToolByKey(k);
		if( xmlTool != null )
			return add(xmlTool.toolId, user, inBag);
		throw "unknown tool :" + k;
	}
	
	public static function add( toolId : Int, user : User, ?inBag : Bool ) : Tool {
		var t = new Tool();
		t.toolId = toolId;
		t.user = user;
		if( inBag != null ) t.inBag = inBag;
		t.insert();
		t.makeInfos();
		return t;
	}
	
	override function delete() {
		manager.forceCacheUpdate();
		super.delete();
	}
	
	override public function update() {
		if( soulLocked && !inBag ) {
			throw "Cet objet est un objet Métier, il ne peut être déposé ! Merci de rapidement prévenir l'administrateur à support@hordes.fr !";
		}
		if( soulLocked && isBroken ) {
			throw "Cet objet est un objet Métier, il ne peut être cassé ! Merci de rapidement prévenir l'administrateur à support@hordes.fr !";
		}
		super.update();
    	manager.forceCacheUpdate();
	}
	
	override public function insert() {
		if( soulLocked && !inBag )
			throw "Cet objet est un objet Métier, il ne peut être déposé ! Merci de rapidement prévenir l'administrateur à support@hordes.fr !";
		if( soulLocked && isBroken )
			throw "Cet objet est un objet Métier, il ne peut être cassé ! Merci de rapidement prévenir l'administrateur à support@hordes.fr !";
		var info = XmlData.getTool( toolId );
		// TODO HACK !!
		if( info == null )
			return;
		if( info.deco != null && info.deco > 0 )
			decoPoints = info.deco;
		if( info.hasType( SoulLocked ) )
			soulLocked = true;
		super.insert();
    	manager.forceCacheUpdate();
	}

	public function hasType( tpe : ToolType ) {
		if( types == null )
			return false;
		var type = Std.string( tpe );
		for( tp in types ) {
			if( tp == type )
				return true;
		}
		return false;
	}

	public inline function print() {
		var fl_broken = if(id!=null && isBroken!=null) isBroken else false; // cas où l'objet n'est pas en BDD
		return "<strong class='tool'><img src='/gfx/icons/item_"+icon+".gif?v="+App.getDbVar("fileVersion")+"' alt='[]' title=''/>&nbsp;" + name +(if(fl_broken) " <em>"+Text.get.BrokenWord+"</em>" else "")+"</strong> ";
	}

	public inline function printName() {
		var str = "<strong>"+name+"</strong>";
		return str;
	}

	/**
	 * Method qui renvoie true si en fait le replacement est un upgrade de l'outil grace a l'action assemble
	 */
	public function isReplacementAnUpgrade()
	{
		return this.action == "assemble";
	}
	
	public function getReplacementAt(index:Int):Null<Tool> {
		if( replacement.length == 0 || index >= replacement.length ) return null;
		return XmlData.getToolByKey(replacement[index]);
	}
	
	public function getReplacement(?baseKey:String) : Tool {
		var k = getReplacementKey();
		if( baseKey != null ) k = baseKey + k;
		var t = XmlData.getToolByKey(k);
		if( t != null ) {
			t.isBroken = false;
		}
		return t;
	}

	public function getReplacementKey() : String {
		return replacement[Std.random(replacement.length)];
	}

	public function forceBroken(fl) {
		isBroken = fl; // WARNING : only for temporary use in templates !
		return "";
	}

	public function makeInfos() {
		var info = XmlData.getTool( toolId );
		if ( info == null ) { // todo: vérifier si c'est un cas normal et courant ?
			throw "Appel à 'MakeInfos' sur un objet null ! Merci de rapidement prévenir l'administrateur à support@hordes.fr !";
		}
		name = info.name;
		isHeavy = info.isHeavy;
		types = info.types;
		loss_probability = info.loss_probability;
		broken = info.broken;	// XXX vérifier s'il n'y a pas de conflits avec le isBroken en base...
		power = info.power;
		random = info.random;
		deco = if( info.deco != null ) info.deco else 0;
		bonus = info.bonus;
		transport = info.transport;
		description	= info.description;
		replacement	= info.replacement;
		parts = info.parts;
		hero = info.hero;
		icon = info.icon;
		key = info.key;
		//guard = data.Guardians.getToolInfo( this.key ).def;
		action = info.action;
		limit = info.limit;
		lock = info.lock;
		ghoulProba = info.ghoulProba;
	}

	public function hasLimit( l : String ) {
		return limit == l;
	}

	public function getDefense() {
		if( hasType( Armor ) ) {
			return Const.get.armor;
		}
		return 0;
	}

	public static function getCategory(tool:Tool) {
		if ( tool==null ) return null;
		var cat = null;
		if ( tool.hasType(Rsc) )								cat = Rsc;
		if ( tool.hasType(Weapon) || tool.hasType(EmptyWeapon) )cat = Weapon;
		if ( tool.hasType(Furniture) )							cat = Furniture;
		if ( tool.hasType(Armor) )								cat = Armor;
		if ( tool.hasType(Drug) )								cat = Drug;
		
		if ( tool.hasType(Box) || tool.hasType(Bag) || tools.Utils.inSet(tool.key,["book_gen_1","book_gen_2"]) )
			cat = Box;
		
		if ( tool.hasType(Food) || tool.hasType(Beverage) || tool.hasType(Alcohol) ||
			 tools.Utils.inSet(tool.key,["can","coffee","food_bag", "chest_food"]) ) {
			cat = Food;
		}
		
		if ( tools.Utils.inSet(tool.key,["bandage","pharma","purifier","pharma_part"]) )
			cat = Drug;
		
		if ( tools.Utils.inSet(tool.key,["fence","home_box","home_box_xl","home_def"]) )
			cat = Furniture;
		
		return cat;
	}

	public static function getCategoryName(t:Tool) {
		var cat = getCategory(t);
		return if(cat==null) Text.get.BankCat_None else Text.getByKey("BankCat_"+Std.string(cat));
	}

	public function canBeLaunched(u:User) {
		return u.id==userId && !soulLocked && !isBroken && !hasType(Bag);
	}
	
	
	#if tid_appli
	public function getGraph( viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields ) : Dynamic {
		var tinfo = XmlData.getTool(toolId);
		if( fields == null ) fields = [];
		
		var cat = getCategory(this);
		
		var graph:Dynamic = {
			id: 	tinfo.toolId,
			name: 	tinfo.name,
			count: 	1,
			broken: this.isBroken,
			img: 	tinfo.icon,
			cat: 	Std.string(cat),
			deco:	if( tinfo.deco != null ) tinfo.deco else 0,
			heavy: 	tinfo.isHeavy,
		}
		
		for ( f in fields ) {
			switch (f.name) {
				case "id", "name", "count", "broken", "img", "cat", "deco", "heavy":
					
				case "guard":
					var def = 0;
					var info = data.Guardians.getToolInfo( this.key );
					if ( info != null ) def = info.def;
					graph.guard = def;
					
				case "desc": 
					graph.desc = tinfo.description;
				
				default:
					throw "Unknown field: "+f.name;
				
			}
		}
		
		return graph;
	}
	#end
}

// *** MANAGER
private class ToolManager extends neko.db.Manager<Tool>
{
	public function new(){
		super(Tool);
		_cachedTools = null;
	}

	override function make(t : Tool ) {
		t.makeInfos();
	}

	public function getUsersTools( map : Map, ?userList : List<Int> ) {
		var list = "";
		if( userList != null && userList.length > 0) {
			if( userList.length == 1 )
				list= " AND userId=" + userList.pop();
			else
				list = " AND userId IN ( " + userList.join(",") + ")";
		}
		else {
			list = " AND userId IS NOT NULL AND userId IN ( SELECT id FROM User WHERE mapId="+map.id + ")";
		}
		
		var sql = "SELECT * FROM Tool WHERE inBag=0 " +list + " ORDER BY userId";
		return Lambda.list( objects(sql, false));
	}
	
	public function getMapUserTools(pMap:db.Map, pTools:List<Int>, ?pIncludeInBag:Bool = false, ?pIncludeIsBroken = false) {
		var filter = "";
		if ( !pIncludeInBag ) filter += " inBag=0 AND ";
		if ( !pIncludeIsBroken ) filter += "isBroken=0 AND ";
		
		var sql = "SELECT * FROM Tool WHERE " + filter;
		if (pTools.length == 1 ) sql += " toolId=" + pTools.first() + " ";
		else sql += " toolId IN(" + pTools.join(",") + ") ";
		
		var userIds = Lambda.map(pMap.getUsers(false, true), function(u) return u.id);
		if( userIds.length > 0 )
			sql += " AND userId IN (" + userIds.join(",") + ") ";
		else
			sql += " AND userId IS NOT NULL";
		
		return Lambda.list(objects(sql,false));
	}
	
	public function getUsersDefenseTools( map : Map, ?userList : List<Int> ) {
		var list = "";
		if( userList != null && userList.length > 0) {
			if( userList.length == 1 )
				list= " AND userId=" + userList.pop();
			else
				list = " AND userId IN ( " + userList.join(",") + ")";
		}
		else {
			list = " AND userId IS NOT NULL AND userId IN ( SELECT id FROM User WHERE mapId="+map.id + ")";
		}
		
		var tl = Lambda.map( XmlData.getToolsByType( Armor ), function( t: Tool ) { return t.toolId; });
		var sql = "SELECT * FROM Tool WHERE inBag=0 AND isBroken=0 AND toolId IN("+tl.join(",")+") "+list + " ORDER BY userId";
		return Lambda.list( objects(sql, false));
	}

	public function _getUserTools( user : User, ?lock) {
		var list =	if( lock )
						Lambda.list( objects(select("userId = " + user.id), true) );
					else
						getCache(user);
		return list;
//		var arr = Lambda.array(list);
//		arr.sort( function(a,b) {
//			if ( a.name<b.name ) return -1;
//			if ( a.name>b.name ) return 1;
//			return 0;
//		});
//		for (t in arr ) trace(t.name);
//		return Lambda.list(arr);
	}

	public function emptyUserBag( user : User, ?limit:Int ) {
		if ( limit!=null ) {
			execute("UPDATE Tool set inBag=0 where inBag=1 AND soulLocked=0 AND userId="+user.id+" LIMIT "+limit);
		}
		else {
			execute("UPDATE Tool set inBag=0 where inBag=1 AND soulLocked=0 AND userId="+user.id);
		}
	}

	public function getInTownTools( user : User) {
		return objects(selectReadOnly("userId = " + user.id + " AND inBag = 0"), false);
	}

	public function countTools( user : User, ?inBag=false, ?soulLocked=false) {
		return execute( "SELECT COUNT(*) FROM Tool WHERE userId="+ user.id
							+" AND inBag=" + ( if(inBag) "1" else "0" )
							+" AND soulLocked=" + ( if ( soulLocked ) "1" else "0") ).getIntResult(0);
	}

	public function hasTool( toolId : Int, user: User ) {
		return ( execute("SELECT count(*) FROM Tool WHERE userId="+user.id+" AND toolId="+toolId).getIntResult(0) ) > 0;
	}

	public function deleteSoulLockedTool( user: User ) {
		execute("DELETE FROM Tool WHERE userId="+user.id+" AND soulLocked=1");
	}

	public function countTool( toolId : Int, ids ) {
		if( ids.length <= 0 )
			return 0;
		
		if( toolId == null )
			return 0;
		
		return execute("SELECT count(id) FROM Tool WHERE toolId="+toolId+" AND userId IN("+ids.join(",")+")").getIntResult(0);
	}
	
	public function deleteSoulLockedTools(user:User) {
		execute("DELETE FROM Tool WHERE userId="+user.id+" AND soulLocked=1");
	}
	
	public function deleteJobTools(user:User) {
		var tids = XmlData.getJobToolIds();
		execute("DELETE FROM Tool WHERE userId="+user.id+" AND toolId IN ("+tids.join(",")+")");
	}
	
	private function getCache( user : User ) {
		if ( user != null ) {
			if( user != App.user ) 
				return Lambda.list( objects(selectReadOnly(" userId = " + user.id), false) );
			
			if( _cachedTools != null )
				return _cachedTools;
			
			_cachedTools = Lambda.list( objects(selectReadOnly(" userId = " + user.id), false) );
			return _cachedTools;
		} else {
			return new List();
		}
	}

	public function forceCacheUpdate() {
		_cachedTools = null;
	}

	public function cleanup() {
		_cachedTools = null;
	}

	private var _cachedTools : List<Tool>;
}
