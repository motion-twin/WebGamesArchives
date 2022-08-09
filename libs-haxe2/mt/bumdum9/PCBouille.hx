package mt.bumdum9;
import mt.bumdum9.Lib;

class PCBouille extends flash.display.MovieClip{//}
	
	static var reg = ~/^(p|col|overlay)([0-9]+)/;

	public var caracs:Array<Int>;
	public var colors:Array<Int>;
	public var pal:Array<Array<UInt>>;

	var fridge:Array<PC>;

	public static var TRACE = false;
	
	public function new() {
		super();
		caracs = [];
		colors = [];
		fridge = [];
	}
	
	// COMMANDS
	
	public function scanPal(pc:PC) {

		var mcp = pc.get("_pal").mc;
		if( mcp == null ) return;
		if( mcp != null ) {
			
			mcp.parent.removeChild(mcp);
			
			var bmp = new flash.display.BitmapData(Std.int(mcp.width), Std.int(mcp.height), true, 0);
			bmp.draw(mcp);
			pal = [];
			var ec = 2;
			for( y in 0...12 ) {
				var a :Array<UInt>= [];
				for( x in 0...100 ) {
					var col = bmp.getPixel32(x * ec, y * ec);
					if( col <= 0xFFFFFF ) break;
					var o = Col.colToObj32(col);
					a.push( Col.objToCol( { r:o.r, g:o.g, b:o.b } ) );
				}
				if( a.length == 0 ) break;
				pal.push(a);
			}
		}
	}
	
	public function set(a) {
		caracs = a;
	}
	public function setColors( a:Array<Int> ) {
		colors = [];
		if( a != null ){
			var id = 0;
			for( n in a ) {
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
	}
	
	// APPLY
	public function apply(pc) {
		chainSkin(pc);
	}
	
	function chainSkin(pc:PC) {
		
		if( pc.name != null && !pc.freeze )	skin(pc);
		var a = pc.children();
		for( pc in a ) chainSkin(pc);
		
	}
	
	public function skin(pc:PC) {
		var mc = pc.mc;
		
		
		if( pc.name.substr(0, 1) != "_" ) return;
		
		pc.freeze = true;
		fridge.push(pc);
		
		var str = pc.name.substr(1);
		while(reg.match( str )) {
			str = reg.matchedRight();
			var id = Std.parseInt(reg.matched(2));
			switch( reg.matched(1) ) {
				case "p" :
					var n = caracs[id] % pc.totalFrames;
					pc.goto( n + 1, false );
					pc.sync();
					
				case "col" :
					
					var inc = -255;
					var o = Col.colToObj( colors[id] );
					if( TRACE ) trace(o);
					var ct = new flash.geom.ColorTransform(1,1,1,1, o.r + inc, o.g + inc, o.b + inc, 0);
					//trace("!!"+pc.name+"  "+colors[id] );
					mc.transform.colorTransform = ct;
					
				case "overlay" :
					var mult = 2;
					var inc = -128*mult;
					var o = Col.colToObj( colors[id] );
					var ct = new flash.geom.ColorTransform(mult, mult, mult, 1, o.r + inc, o.g + inc, o.b + inc, 0);
					mc.transform.colorTransform = ct;
			}
		}
		
	}
	
	public function unfreezeAll() {
		for( f in fridge ) f.freeze = false;
		fridge = [];
	}
	
	
//{
}



	
