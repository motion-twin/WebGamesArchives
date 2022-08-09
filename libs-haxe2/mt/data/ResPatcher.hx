package mt.data;
import format.swf.Data.SWFTag;

class ResPatcher {

	var data : format.swf.Data.SWF;
	var indexes : IntHash<Int>;
	var names : Hash<Int>;

	public function new(r) {
		data = new format.swf.Reader(r).read();
		indexes = new IntHash();
		names = new Hash();
		for( i in 0...data.tags.length )
			switch(data.tags[i]) {
			case TBinaryData(id,data):
				indexes.set(id,i);
			case TSymbolClass(cl):
				for( c in cl )
					if( c.className.substr(0,6) == "_res._" )
						names.set(c.className.substr(6),c.cid);
			default:
			}
	}

	public function listResources() {
		return Lambda.array({ iterator : names.keys });
	}

	public function replace( res : String, data : haxe.io.Bytes ) {
		res = res.split(".").join("_");
		var cid = names.get(res);
		if( cid == null )
			return false;
		var idx = indexes.get(cid);
		if( idx == null ) throw "assert";
		this.data.tags[idx] = TBinaryData(cid,data);
		return true;
	}

	public function write(w) {
		new format.swf.Writer(w).write(data);
	}
	
	public function dumpNames( t)
	{
		neko.Lib.println(names.get(t));
		neko.Lib.println(data.tags[indexes.get(names.get(t))]);
	}

	#if macro
	public static function mods( swf : String, cache : String, out : String ) {
		var f = neko.io.File.read(swf);
		var r = new ResPatcher(f);
		f.close();
		var h : Hash<{ bytes : haxe.io.Bytes }> = haxe.Unserializer.run(neko.io.File.getContent(cache));
		var ods = cache.split("/").pop();
		ods = ods.split(".cache").join(".ods");
		for( mods in h.keys() ) {
			if( mods.substr(0,6) == "_enum.") continue;
			var sign = haxe.Md5.encode(ods + "@"+ mods);
			if( !r.replace(sign, h.get(mods).bytes) )
				throw "Could not replace resource "+mods+":"+sign;
		}
		var f = neko.io.File.write(out);
		r.write(f);
		f.close();
	}
	
	public static function xml( swf:String,xmls:Array<String>,symbols:Array<String>, out:String){
		mt.gx.Debug.assert(xmls.length == symbols.length,"both array shoud be samesize and contain xml file and its target symbol");
		var f = neko.io.File.read(swf);
		var r = new ResPatcher(f);
		f.close();
		
		var i = 0;
		for(xml in xmls)
		{
			var rsc = symbols[i];
			var new_txt = neko.io.File.getContent( xml );
			var new_bytes = haxe.io.Bytes.ofString( new_txt );
			if( !r.replace(rsc,new_bytes) )
				throw "Could not replace resource "+rsc;
			i++;
		}
		
		var f = neko.io.File.write(out);
		r.write(f);
		f.close();
		
		return 0;
		}
	#end

}














