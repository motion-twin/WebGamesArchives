package db;
import mt.db.Types;
import tools.Utils;

class Expedition extends neko.db.Object {

	static var RELATIONS = function(){
		return [
			{ key : "mapId",	prop : "map",	manager : Map.manager, lock : false },
			{ key : "userId",	prop : "user",	manager : User.manager, lock : false },
		];
	}

	public var id		: SId;
	public var userId(default,null)	: SInt;
	public var mapId(default,null)	: SInt;
	public var name		: SString<60>;
	public var path		: SString<250>;

	public var user(dynamic,dynamic)	: User;
	public var map(dynamic,dynamic)		: Map;

	public static var manager = new ExpeditionManager();

	public static function create( user:User, path:String, ?nam:String ) {
		// checks
		var list = path.split("|");
		var prev = null;
		var map = user.getMapForDisplay();
		var c = map._getCity();
		list.push(c.x+":"+c.y);
		for (c in list) {
			var pt = c.split(":");
			if ( pt.length!=2 ) return null;
			if ( !~/^[0-9]+$/.match(pt[0]) || !~/^[0-9]+$/.match(pt[1]) ) return null;
			var x = Std.parseInt(pt[0]);
			var y = Std.parseInt(pt[1]);
			if ( x<0 || y<0 || x>map.width ) return null;
			if ( prev!=null ) {
				if ( x!=prev.x && y!=prev.y ) return null;
			}
			prev = {x:x,y:y};
		}

		// all ok
		var e = new Expedition();
		e.userId = user.id;
		e.mapId = user.mapId;
		if ( nam==null ) {
			e.name = user.name;
		}
		else {
			e.name = StringTools.trim(nam);
		}
		e.path = path;
		e.name+=" ["+e.getLength()+"PA]";
		e.insert();
		return e;
	}

	public function getFullPath(?fl_includeCity:Bool) {
		if (path==null) return null;
		var list = path.split("|");
		var plist : Array<{x:Int,y:Int}> = new Array();
		var map = user.getMapForDisplay();
		if( map == null ) return null;

		var c = map._getCity();
		if ( fl_includeCity ) {
			plist.push( {x:c.x, y:c.y} );
		}
		for (c in list) {
			var pt = c.split(":");
			plist.push( {x:Std.parseInt(pt[0]),y:Std.parseInt(pt[1])} );
		}
		if ( fl_includeCity ) {
			plist.push( {x:c.x, y:c.y} );
		}
		return plist;
	}


	public function new() {
		super();
		userId = null;
		mapId = null;
		name = Text.get.UnnamedExpedition;
		path = "";
	}

	public function getLength() {
		var plist = getFullPath(true);
		if( plist == null )
			return 0;
		return MapCommon.getPathLength(plist);
	}

	#if tid_appli
	public function getGraph( viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields ) : Dynamic {
		if( fields == null ) fields = [{name:"author"}];
		
		var expGraph:Dynamic = {
			name: this.name,
			length: this.getLength(),
		}
		
		for ( f in fields ) {
			switch (f.name) {
				case "name", "length":
				case "author":
					expGraph.author = this.user.getGraph(viewer, scopes, f.fields);
				default:
					throw "Unknown field: "+f.name;
			}
		}
		
		var path = getFullPath(true);
		if ( path != null ) {
			expGraph.points = [];
			for ( pt in path ) {
				expGraph.points.push( { x: pt.x, y: pt.y } );
			}
		}
		
		return expGraph;
	}
	#end

}
class ExpeditionManager extends neko.db.Manager<Expedition> {
	public function new() {
		super(Expedition);
	}

	public function hasExpedition(u:User) {
		return execute("SELECT count(*) FROM Expedition WHERE mapId="+u.mapId+" AND userId="+u.id).getIntResult(0) > 0;
	}

	public function countForMap(map:Map) {
		return execute("SELECT count(*) FROM Expedition WHERE mapId="+map.id).getIntResult(0);
	}

	public function getByUser(u:User, ?lock:Bool) {
		if ( lock==null ) lock = false;
		return object( select("mapId="+u.mapId+" AND userId="+u.id), lock );
	}

	public function getByMapId(map:Map, ?lock:Bool) {
		if ( lock==null ) lock = false;
		return objects(" SELECT * FROM Expedition WHERE mapId="+map.id,lock);

	}

	public function getForSwf(map:Map) {
		var elist = getByMapId(map);
		var list = new Array();
		for (e in elist) {
			list.push({
				_i	: e.id,
				_n	: e.name,
				_p	: e.path,
			});
		}
		return list;
	}
}
