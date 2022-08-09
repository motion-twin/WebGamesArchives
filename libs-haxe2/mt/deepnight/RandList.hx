package mt.deepnight;

class RandList<T> {
	public var allValuesReadOnly	: Array<T>;
	var drawList					: Array<{proba:Int, value:T}>;
	var fdrawList					: Array<T>;
	public var total(default,null)	: Int;
	public var defProba				: Int;
	var fastDraw					: Bool;
	
	public function new(?list:Array<T>) {
		drawList = new Array();
		fastDraw = false;
		fdrawList = new Array();
		allValuesReadOnly = new Array();
		defProba = 100;
		total = 0;
		if (list!=null)
			for (e in list)
				add(e,1);
	}
	
	// Crée une RandList en utilisant les metadata d'un enum comme proba
	public static function fromEnum<T>( e : Enum<T>, ?metaFieldName="proba") : RandList<T> {
		var n = Type.getEnumName(e);
		var r = new mt.deepnight.RandList<T>();
		var a = haxe.rtti.Meta.getFields(e);
		for( k in Type.getEnumConstructs(e) ){
			var p = Type.createEnum(e,k);
			r.add(p, Reflect.field(Reflect.field(a,k), metaFieldName)[0]);
		}
		return r;
	}
	
	// active la pré-génération de la table de tirage = init plus lente mais tirage plus rapide
	public function setFastDraw() {
		fastDraw = true;
		fdrawList = new Array();
		
		// conversion des données actuelles, si il y en a
		for (e in drawList)
			for (i in 0...e.proba)
				fdrawList.push(e.value);
	}
	
	public function add(e:T, ?proba:Null<Int>) {
		allValuesReadOnly.push(e);
		var proba = proba==null ? defProba : proba;
		if(fastDraw)
			for( i in 0...proba )
				fdrawList.push(e);
		else {
			drawList.push( { proba:proba, value:e } );
			total += proba;
		}
	}
	
	public function remove(e:T) {
		if( fastDraw )
			fdrawList.remove(e);
		else {
			var i = 0;
			while( i<drawList.length ) {
				if ( drawList[i].value == e ) {
					total -= drawList[i].proba;
					allValuesReadOnly.remove(e);
					drawList.splice(i,1);
				} else
					i++;
			}
		}
	}
	
	public function draw(?randFunc:Int->Int) : T {
		if (randFunc == null)
			randFunc = Std.random;
		if (fastDraw) {
			return fdrawList[randFunc(fdrawList.length)];
		} else {
			var n = randFunc(total);
			var prev = 0;
			for (e in drawList) {
				if ( n < prev + e.proba )
					return e.value;
				prev += e.proba;
			}
			return null;
		}
	}
	
	inline public function length() {
		return allValuesReadOnly.length;
	}
	
	inline public function count() {
		return drawList.length;
	}
	
	public function toString() {
		var list = new List();
		for (e in drawList)
			list.add(e.value + " => " + Math.round(1000 * e.proba / total) / 10 + "%");
		return list.join("\n");
	}
}

