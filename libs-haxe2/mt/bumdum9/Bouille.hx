package mt.bumdum9;
import mt.bumdum9.Lib;

class Bouille extends flash.display.MovieClip{//}
	
	var ready:Bool;
	var loaded:Int;
	var base:flash.display.MovieClip;
	
	var caracs:Array<Int>;
	var colIndex:Array<Int>;
	public var pal:Array<Array<Int>>;
	public var onLoadFinish:Void->Void;

	
	public function new() {
		super();
		
		loaded = 0;
		ready = false;

	}
	

	// LOADING
	var fdl:flash.display.Loader;
	public function load( url ) {
		fdl = new flash.display.Loader();
		fdl.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, onLoaded );
		fdl.contentLoaderInfo.addEventListener( flash.events.Event.INIT, onLoaded );
		fdl.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, error);
		fdl.load( new flash.net.URLRequest(url) );
	}
	function error(e) {
		//trace("url not found");
	}
	function onLoaded(e) {
		loaded++;
		if( loaded == 2 ) {
			setBase( cast fdl.content );
			if(onLoadFinish!=null)onLoadFinish();
		}
	}
	public function unload() {
		if( !ready ) return;
		removeChild(base);
		base = null;
		loaded = 0;
		ready = false;
		caracs = null;
		colIndex = null;
	}
	
	
	// COMMANDS
	public function setBase(mc) {
		
		base = mc;
		addChild(base);
		
		// SCAN PALETTE;
		var mcp:flash.display.MovieClip = cast(base)._pal;
		if( mcp != null ) {
			
			mcp.parent.removeChild(mcp);
			var bmp = new flash.display.BitmapData(Std.int(mcp.width), Std.int(mcp.height), true, 0);
			bmp.draw(mcp);
			pal = [];
			var ec = 8;
			for( y in 0...120 ) {
				var a = [];
				for( x in 0...100 ) {
					var col = bmp.getPixel32(4+x * ec, 4+y * ec);
					//if( col <= 0xFFFFFF ) break;
					if( col == 0 ) break;
					var o = Col.colToObj32(col);
					a.push( Col.objToCol( { r:o.r, g:o.g, b:o.b } ) );
				}
				if( a.length == 0 ) break;
				pal.push(a);
			}
			bmp.dispose();
		}
		
		
		ready = true;
		if( caracs != null ) apply();
	}
	
	public function set(a) {
		caracs = a;
		if( ready ) apply();
	}
	public function setColors( a:Array<Int> ) {
		colIndex = a;
		if( ready ) apply();
	}
	
	// APPLY
	function apply() {
		var skin = new BSkin();
		
		var colors = [];
		if( colIndex != null ){
			var id = 0;
			for( n in colIndex ) {
				if( pal == null || pal[id] == null  ) {
					trace("palette[" + id + "] not found");
					break;
				}
				var range = pal[id];
				n = n % range.length;
				colors.push(range[n]);
				id++;
			}
		}
		
		skin.set(base, caracs, colors );
	}
	
//{
}


class BSkin extends mt.flash.Skin {//}
	
	static var reg = ~/^(p|col|overlay)([0-9]+)/;

	var caracs:Array<Int>;
	var colors:Array<Int>;
	public function new(){
		super();
		caracs = [];
	}
	
	public function load() {
		
	}
	
	public function set(mc,caracs,?colors) {
		this.caracs = caracs;
		this.colors = colors;
		apply(mc);
		
	}
	
	override function skin(mc:flash.display.MovieClip) {
		
		if( mc.name.substr(0, 1) != "_" ) return;
		var str = mc.name.substr(1);
		
		while(reg.match( str )) {
			str = reg.matchedRight();
			var id = Std.parseInt(reg.matched(2));
			switch( reg.matched(1) ) {
				case "p" :
					var n = caracs[id] % mc.totalFrames;
					mc.gotoAndStop( n + 1 );
					
				case "col" :
					var inc = -255;
					var o = Col.colToObj( colors[id] );
					var ct = new flash.geom.ColorTransform(1,1,1,1, o.r + inc, o.g + inc, o.b + inc, 0);
					mc.transform.colorTransform = ct;
					
				case "overlay" :
					var mult = 2;
					var inc = -128*mult;
					var o = Col.colToObj( colors[id] );
					var ct = new flash.geom.ColorTransform(mult, mult, mult, 1, o.r + inc, o.g + inc, o.b + inc, 0);
					mc.transform.colorTransform = ct;
			}
		}
		
		/*
		if( mc.name.substr(0, 2) != "_p" ) return;
		var id = Std.parseInt(mc.name.substr(2));
		var n = caracs[id];
		n = n % mc.totalFrames;
		mc.gotoAndStop( n + 1 );
		*/
	
		
	}

	
	
//{
}


