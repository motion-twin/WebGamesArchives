package data;

class Container<T,X : haxe.xml.Proxy<Dynamic,T>> {

	var file : String;
	public var h : Hash<T>;
	public var l : List<T>;
	public var i : IntHash<T>;
	public var list(default,null) : X;

	public function new( ?ordered, ?noid ) {
		h = new Hash();
		if( !noid )
			i = new IntHash();
		if( ordered )
			l = new List();
		list = cast new haxe.xml.Proxy(h.get);
	}

	public function parse( file : String, f : String -> Int -> haxe.xml.Fast -> T ) {
		this.file = file;
		for( e in Data.xml(file).elements() ) {
			var e = new haxe.xml.Fast(e);
			var id = e.att.id;
			var iid = if( i != null ) Tools.makeId(id) else 0;
			if( h.exists(id) )
				throw "Duplicate id in "+file+" : "+id;
			var x = try f(id,iid,e) catch( e : Dynamic ) {
				neko.Lib.rethrow("Error while parsing "+file+"@"+id+" : "+Std.string(e));
			}
			h.set(id,x);
			if( i != null )
				i.set(iid,x);
			if( l != null )
				l.add(x);
		}
		return this;
	}

	public function getName( id : String ) {
		var inst = h.get(id);
		if( inst == null )
			throw "No '"+id+"' found in "+file;
		return inst;
	}

	public function getId( id : Int ) {
		var inst = if (i != null) i.get(id)  else h.get(Std.string(id)) ;
		if( inst == null )
			throw "No "+(try Tools.makeName(id) catch( e : Dynamic ) "???")+" (#"+id+") found in "+file;
		return inst;
	}

	public function iterator() {
		if( l == null )
			return h.iterator();
		return l.iterator();
	}
	
	
	public function keys() {
		return h.keys() ;
	}

}