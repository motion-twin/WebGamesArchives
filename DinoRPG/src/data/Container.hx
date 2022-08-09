package data;

class Container<T, X : haxe.xml.Proxy<Dynamic,T>> {

	var file : String;
	var h : Hash<T>;
	var l : List<T>;
	var i : IntHash<T>;
	public var list(default, null) : X;

	public function new( ?ordered, ?noid ) {
		h = new Hash();
		if( !noid )
			i = new IntHash();
		if( ordered )
			l = new List();
		list = cast new haxe.xml.Proxy(h.get);
	}

	public function add( id : String, x : T ) {
		if( h.exists(id) )
			throw "Duplicate id : "+id;
		h.set(id, x);
		if( i != null )
			i.set(Tools.makeId(id), x);
		if( l != null )
			l.add(x);
	}

	public function parse( file : String, f : String -> Int -> haxe.xml.Fast -> T, ?elementsName:String ) {
		this.file = file;
		var xml = Data.xml(file);
		var elements = elementsName != null ? xml.elementsNamed(elementsName) : xml.elements();
		for( e in elements ) {
			var e = new haxe.xml.Fast(e);
			var id = e.att.id;
			var iid = ( i != null ) ? Tools.makeId(id) : 0;
			if( h.exists(id) )
				throw "Duplicate id in "+file+" : "+id;
			var x = try f(id, iid, e) catch( e : Dynamic ) {
				neko.Lib.rethrow("Error while parsing file"+file+"@id:"+id+", error: "+Std.string(e));
			}
			h.set(id, x);
			if( i != null )
				i.set(iid, x);
			if( l != null )
				l.add(x);
		}
		return this;
	}

	public function existsName( id:String){
		return h.exists( id );
	}
	
	public function existsId( id:Int){
		return i.exists( id );
	}
	
	public function getName( id : String ) {
		var inst = h.get(id);
		if( inst == null )
			throw "No '"+id+"' found in "+file;
		return inst;
	}

	public function getId( id : Int ) {
		var inst = i.get(id);
		if( inst == null )
			throw "No "+(try Tools.makeName(id) catch( e : Dynamic ) "???")+" (#"+id+") found in "+file;
		return inst;
	}

	public function iterator() {
		if( l == null )
			return h.iterator();
		return l.iterator();
	}
}