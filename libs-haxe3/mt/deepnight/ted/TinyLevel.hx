package mt.deepnight.ted;

typedef DataFormat = {
	var wid		: Int;
	var hei		: Int;
	var layers	: Array<{ id:String, content:Array<String> }>;
}

class TinyLevel<T> {
	static var DATA_VERSION = 1;

	var enumType		: Enum<T>;
	public var wid		: Int;
	public var hei		: Int;
	var layers			: Map<String, Array<Array<Bool>> >;

	public function new(cellEnum:Enum<T>, w,h) {
		enumType = cellEnum;
		wid = w;
		hei = h;
		layers = new Map();
	}

	public function isEmpty() {
		for(l in layers)
			for(cx in 0...wid)
				for(cy in 0...hei)
					if( l[cx][cy] )
						return false;
		return true;
	}

	inline function id(e:T) {
		return Std.string(e);
	}

	inline function fromId(id:String) : T {
		return Type.createEnum(enumType, id);
	}

	function initLayer(e:T) {
		var map = new Array();
		for(cx in 0...wid) {
			map[cx] = new Array();
			for(cy in 0...hei)
				map[cx][cy] = false;
		}

		layers.set( id(e), map );
	}

	inline function getLayer(e:T) {
		if( !layers.exists( id(e) ) )
			initLayer(e);

		return layers.get( id(e) );
	}


	//public function changeSize(dw:Int, dh:Int) {
		//var old = haxe.Unserializer.run( haxe.Serializer.run(layers) );
		//wid+=dw;
		//hei+=dh;
	//}


	public function get(cx,cy) {
		if( !inBounds(cx,cy) )
			return [];

		var all = [];
		for(id in layers.keys()) {
			var l = layers.get(id);
			if( l[cx][cy]==true )
				all.push( fromId(id) );
		}

		return all;
	}

	public function add(cx,cy, e:T) {
		if( !has(cx,cy,e) )
			getLayer(e)[cx][cy] = true;
	}

	public function pan(dx,dy, ?e:T) {
		var targets = e!=null ? [ id(e)=>getLayer(e) ] : layers;
		for(l in targets) {
			var old = [];
			for(cx in 0...wid)
				old[cx] = l[cx].copy();

			for(cx in 0...wid)
				for(cy in 0...hei)
					if( inBounds(cx-dx, cy-dy) )
						l[cx][cy] = old[cx-dx][cy-dy];
					else
						l[cx][cy] = false;
		}
	}


	public inline function inBounds(cx,cy) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}


	public function serialize() {
		var all = [];
		for( id in layers.keys() ) {
			var e = fromId(id);
			var list = [];
			for(cy in 0...hei)
				for(cx in 0...wid)
					if( has(cx,cy, e) )
						list.push(cx+","+cy);
			all.push({ id:id, content:list });
		}

		var data : DataFormat = {
			wid		: wid,
			hei		: hei,
			layers	: all,
		}

		var hj = new mt.deepnight.HaxeJson( DATA_VERSION );
		hj.serialize(data);
		var raw = hj.getSerialized();
		flash.system.System.setClipboard(raw);
		return raw;
		//return haxe.zip.Compress.run(haxe.io.Bytes.ofString(raw), 9);
	}

	public static function unserialize<T>(cellEnum:Enum<T>, raw:String) : TinyLevel<T> {
		var hj = new mt.deepnight.HaxeJson( DATA_VERSION );
		hj.unserialize(raw);

		var data : DataFormat = hj.getUnserialized();
		var l = new TinyLevel(cellEnum, data.wid, data.hei);
		for(layer in data.layers) {
			for(c in layer.content) {
				l.add( Std.parseInt(c.split(",")[0]), Std.parseInt(c.split(",")[1]), Type.createEnum(cellEnum, layer.id) );
			}
		}
		return l;
	}

	public function remove(cx,cy, e:T) {
		getLayer(e)[cx][cy] = false;
	}

	public function removeAll(cx,cy) {
		for( l in layers )
			l[cx][cy] = false;
	}

	public function has(cx,cy, e:T) {
		return getLayer(e)[cx][cy]==true;
	}
}

