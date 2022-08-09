package mt.flash;

class Memory {

	var d : flash.utils.Dictionary;
	var classes : flash.utils.Dictionary;
	var stack : Array<Dynamic>;
	public var size : Int;
	public var nobjects : Int;

	public function new( o : Dynamic ) {
		d = new flash.utils.Dictionary();
		classes = new flash.utils.Dictionary();
		d[cast true] = true;
		d[cast false] = true;
		stack = [o];
		size = 0;
		nobjects = 0;
	}

	function buildClassVars( c : Class<Dynamic> ) {
		var xml : Dynamic = untyped __global__["flash.utils.describeType"](c).factory;
		var xvars = xml.child("variable");
		var vars = new Array<String>();
		for( i in 0...xvars.length() )
			vars.push(untyped xvars[i].attribute("name").toString());
		return vars;
	}

	public function process( count ) {
		while( stack.length > 0 ) {
			var o : Dynamic = stack.pop();
			if( o == null ) continue;
			if( d[o] ) continue;
			d[o] = true;
			if( untyped __is__(o,Int) ) continue;
			nobjects++;
			if( untyped __is__(o,Float) ) {
				size += 4; // 1 object + 4 additional bytes
				continue;
			}
			else if( untyped __is__(o,Array) ) {
				var a : Array<Dynamic> = o;
				size += a.length * 4;
				stack = stack.concat(a);
			} else if( untyped __is__(o,String) ) {
				var s : String = o;
				size += s.length * 2; // UTF-16
			} else if( untyped __is__(o,flash.display.BitmapData) ) {
				var b : flash.display.BitmapData = o;
				size += b.width * b.height * 4;
			} else if( untyped __is__(o,flash.utils.Dictionary) ) {
				var keys : Array<Dynamic> = untyped __keys__(o);
				size += keys.length * 12; // (k,v,ptr) pairs ?
				stack = stack.concat(keys);
				for( k in keys )
					stack.push(o[k]);
			} else {
				var c = null;
				try {
					c = Type.getClass(o);
				} catch( e : Dynamic ) {
					// in case some resource has been loaded
					// Type.getClass will fail
				}
				var vars : Array<Dynamic>;
				if( c == null )
					vars = Reflect.fields(o);
				else {
					vars = classes[cast c];
					if( vars == null ) {
						vars = buildClassVars(c);
						classes[cast c] = vars;
					}
				}
				size += 4 * vars.length;
				for( v in vars )
					stack.push(o[v]);
			}
			count--;
			if( count < 0 )
				return false;
		}
		size += nobjects * 4;
		return true;
	}

	public static function size( o : Dynamic ) : Int {
		var m = new Memory(o);
		while( !m.process(100000) ) {
		}
		return m.size;
	}

	public static function count( o : Dynamic ) : Int {
		var m = new Memory(o);
		while( !m.process(100000) ) {
		}
		return m.nobjects;
	}

}