package mt.data;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class CachedData {

	#if macro
	static var cachedFiles = new Hash();
	
	public static function get( fileName : String, parseData : haxe.io.Input -> Dynamic, encode : Bool ) {
		var file = Context.resolvePath(fileName);
		var path = file.split(".");
		if( path.length > 1 )
			path.pop();
		var cache = path.join(".") + ".cache";
		var str;
		if( cachedFiles.exists(file) )
			str = cachedFiles.get(file);
		else if( neko.FileSystem.exists(cache) && neko.FileSystem.stat(cache).mtime.getTime() > neko.FileSystem.stat(file).mtime.getTime() )
			str = neko.io.File.getContent(cache);
		else {
			try neko.FileSystem.deleteFile(cache) catch( e : Dynamic ) { };
			var t = haxe.Timer.stamp();
			var f = neko.io.File.read(file, true);
			var data = parseData(f);
			var s = new haxe.Serializer();
			s.useEnumIndex = true;
			s.serialize(data);
			str = s.toString();
			f.close();
			if( encode )
				str = CachedData.encode(fileName,str);
			var f = neko.io.File.write(cache, true);
			f.writeString(str);
			f.close();
			trace("Rebuilt '"+fileName+"' data in " + Std.int((haxe.Timer.stamp() - t)*100)/100+"s");
		}
		cachedFiles.set(file, str);
		return { expr : EConst(CString(str)), pos : Context.currentPos() };
	}
	
	static function encode( file : String, data : String ) {
		var key = haxe.Md5.encode(file).substr(0, 5);
		var buf = haxe.io.Bytes.ofString(data);
		var s = initKey(key);
		var codea = s.get(0);
		var codeb = s.get(1);
		for( i in 0...buf.length ) {
			var cc = buf.get(i);
			var ec = cc ^ s.get(i&0xFF);
			buf.set(i,(ec == 0) ? cc : ec);
			codea = (codea + ec) % 65521;
			codeb = (codeb + codea) % 65521;
		}
		var code = codea ^ (codeb << 8);
		var crc = ENCODE.charAt(code & 63) + ENCODE.charAt((code>>6) & 63) + ENCODE.charAt((code>>12) & 63) +  ENCODE.charAt((code>>18) & 63);
		return key + crc + haxe.Serializer.run(buf);
	}
	
	#end
	
	static var ENCODE = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_";

	static function initKey( key : String ) {
		var s = haxe.io.Bytes.alloc(256);
		for( i in 0...256 )
			s.set(i,i&127);
		var j = 0;
		var klen = key.length;
		for( i in 0...256 ) {
			j = (j + s.get(i) + key.charCodeAt(i % klen)) & 127;
			var tmp = s.get(i);
			s.set(i,s.get(j));
			s.set(j,tmp);
		}
		return s;
	}
	
	public static function decode( data : String ) {
		var t = haxe.Timer.stamp();
		var s = initKey(data.substr(0, 5));
		var crc = data.substr(5, 4);
		var buf : haxe.io.Bytes = haxe.Unserializer.run(data.substr(9));
		var codea = s.get(0);
		var codeb = s.get(1);
		for( i in 0...buf.length ) {
			var ec = buf.get(i);
			var cc = ec ^ s.get(i&0xFF);
			buf.set(i, (cc == 0) ? ec : cc);
			if( cc == 0 ) ec = 0;
			codea = (codea + ec) % 65521;
			codeb = (codeb + codea) % 65521;
		}
		var code = codea ^ (codeb << 8);
		if( crc.charCodeAt(0) != ENCODE.charCodeAt(code & 63) ||
			crc.charCodeAt(1) != ENCODE.charCodeAt((code>>6)&63) ||
			crc.charCodeAt(2) != ENCODE.charCodeAt((code>>12)&63) ||
			crc.charCodeAt(3) != ENCODE.charCodeAt((code >> 18) & 63) )
			throw "Corrupted data";
		return buf.toString();
	}
	
}