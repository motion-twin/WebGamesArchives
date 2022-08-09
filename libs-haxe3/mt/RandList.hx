package mt;

class RandList<T> {
	public var totalProba(default, null)	: Int;

	var drawList			: Array<{proba:Int, value:T}>;
	var defaultRandom		: Int->Int;

	public function new(?rndFunc:Int->Int, ?arr:Array<T>) {
		if( rndFunc!=null )
			defaultRandom = rndFunc;
		else
			defaultRandom = Std.random;

		totalProba = 0;
		drawList = new Array();

		if( arr != null )
			addArray(arr);
	}

	public function clear() {
		totalProba = 0;
		drawList = [];
	}

	// Crée une RandList en utilisant les metadata d'un enum comme proba
	public static function fromEnum<T>( e : Enum<T>, ?metaFieldName = "proba" ) : RandList<T> {
		var n = Type.getEnumName(e);
		var r = new mt.RandList<T>();
		var meta = haxe.rtti.Meta.getFields(e);

		for ( k in Type.getEnumConstructs(e) ) {
			var p = Type.createEnum(e, k);
			r.add( p, Reflect.field( Reflect.field(meta,k), metaFieldName )[0] );
		}

		return r;
	}


	#if flash
	public static function fromMap<T>(m:Map<T,Int>) : RandList<T> {
		var r = new RandList();
		for(k in m.keys())
			r.add(k, m.get(k));
		return r;
	}
	#end

	public function add(elem:T, ?proba=1) {
		if( proba<=0 )
			return this;

		// Add to existing if this elem is already there
		for(e in drawList)
			if( e.value==elem ) {
				e.proba+=proba;
				totalProba+=proba;
				return this;
			}

		drawList.push( { proba:proba, value:elem } );
		totalProba += proba;

		return this;
	}

	public function addArray(arr:Array<T>, ?proba=1) {
		for(i in 0...arr.length) {
			var e = arr[i];
			if( contains(e) )
				continue;

			var n = 1;
			for(j in i+1...arr.length)
				if( arr[j]==e )
					n++;

			add(e, n*proba);
		}
	}

	public function contains(search:T) {
		for(e in drawList)
			if( e.value==search )
				return true;

		return false;
	}

	public function remove(search:T) {
		totalProba = 0;

		var i = 0;
		while( i<drawList.length )
			if( drawList[i].value == search )
				drawList.splice(i,1);
			else {
				totalProba += drawList[i].proba;
				i++;
			}

		return this;
	}

	public function draw(?rndFunc:Int->Int) : Null<T> {
		var n = rndFunc==null ? defaultRandom(totalProba) : rndFunc(totalProba);

		var prev = 0;
		for (e in drawList) {
			if ( n < prev + e.proba )
				return e.value;

			prev += e.proba;
		}

		return null;
	}

	public inline function getItems() {
		return drawList.map( function(e) return e.value );
	}

	public function getProba(v:T) {
		for(e in drawList)
			if( e.value==v )
				return e.proba;
		return 0;
	}

	public inline function length() return drawList.length;
	public inline function isEmpty() return drawList.length==0;

	public function toString() {
		var list = new List();

		for (e in drawList)
			list.add(Std.string(e.value) + " => " + Math.round(1000 * e.proba / totalProba) / 10 + "%");

		return list.join(" | ");
	}
}

