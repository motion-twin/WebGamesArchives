class Minimap {

	public var root : flash.display.MovieClip;
	var bmp : flash.display.BitmapData;
	var tmp : flash.display.BitmapData;
	var bar : {> flash.display.MovieClip, sub : flash.display.MovieClip };
	var mc : flash.display.Sprite;
	var bmc : flash.display.Bitmap;
	var updated : Bool;
	var zones : flash.display.MovieClip;
	var north : flash.display.MovieClip;
	var mx : Int;
	var my : Int;

	static var swimFilter = new flash.filters.ColorMatrixFilter([
		0.7,0,0,0,0,
		0,0.7,0,0,0,
		0,0,2,0,0,
		0,0,0,1,0,
	]);

	public function new(root) {
		this.root = root;
		bmp = new flash.display.BitmapData(256,256,false,0x44526F);
		tmp = new flash.display.BitmapData(256,256,false,0);
		bmc = new flash.display.Bitmap(bmp);
		mc = new flash.display.Sprite();
		mc.scaleX = mc.scaleY = 3;
		mc.x = 95;
		mc.y = 117;
		mc.addChild(bmc);
		root.addChild(mc);

		zones = flash.Lib.attach(__unprotect__("zones"));
		zones.scaleX = zones.scaleY = 0.5;
		zones.visible = false;
		mc.addChild(zones);

		var mask = flash.Lib.attach(__unprotect__("mapmask"));
		mask.x = mc.x;
		mask.y = mc.y;
		root.addChild(mask);

		north = flash.Lib.attach(__unprotect__("north"));
		north.x = mc.x;
		north.y = mc.y;
		north.visible = false;
		root.addChild(north);

		var cross = flash.Lib.attach(__unprotect__("cross"));
		cross.x = mc.x;
		cross.y = mc.y;
		root.addChild(cross);

		bar = cast flash.Lib.attach(__unprotect__("bar"));
		bar.x = 19;
		bar.y = 32;
		root.addChild(bar);
		_set(0,0,0,0,false,[]);
	}

	public function _showDir() {
		north.visible = true;
	}

	public function _draw( bytes : haxe.io.Bytes, mx : Int, my : Int ) {
		var data = bytes.getData();
		data.uncompress();
		data.position = 0;
		tmp.setPixels(tmp.rect,data);
		updated = true;
		this.mx = mx;
		this.my = my;
	}

	public function _set( x : Int, y : Int, a : Float, f : Float, swim : Bool, pts : Array<{_x:Int,_y:Int,_c:Int}> ) {
		bmc.x = -(128+x);
		bmc.y = -(128+y);
		var zx = (mx + x) >> 5;
		var zy = (my + y) >> 5;
		zones.x = -((x + mx) - (zx << 5));
		zones.y = -((y + my) - (zy << 5));
		mc.rotation = -a * 180 / Math.PI - 90;
		north.rotation = mc.rotation + 180; // actually south
		bar.sub.scaleX = f;
		bar.filters = swim ? cast [swimFilter] : [];
		for( p in pts )
			bmp.setPixel32(p._x,p._y,p._c);
		if( updated ) {
			var old = bmp;
			bmp = tmp;
			tmp = old;
			bmc.bitmapData = bmp;
			updated = false;
			zones.visible = true;
		}
	}

	static function main() {
		var inst = new Minimap(flash.Lib.current);
		var ctx = new haxe.remoting.Context();
		ctx.addObject("api",inst);
		haxe.remoting.FlashJsConnection.connect("cnx",null,ctx);
		var t = new haxe.Timer(1000);
	}

}
