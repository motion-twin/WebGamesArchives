class World {

	#if tora
	static inline var SIZE = 256;
	#else
	static inline var DIVIDE = 1;
	static inline var SIZE = 2048 >> (DIVIDE - 1);
	#end
	public static inline var IMAX = 256;
	static inline var TOT_SIZE = SIZE + IMAX * 2;
	static var P0 = new flash.geom.Point(0,0);

	public var hmap : flash.display.BitmapData;
	public var zmap : flash.display.BitmapData;
	var seed : Int;
	var islands : List<{ x : Int, y : Int, kind : Int, dist : Int }>;

	public function new(seed) {
		this.seed = seed;
	}

	function alloc(k,p) {
		var m = new flash.display.BitmapData(SIZE+IMAX*2,SIZE+IMAX*2);
		m.perlinNoise(k,k,1,seed,false,true,4,false,[p]);
		seed += 10000;
		var pixels = m.getVector(m.rect);
		m.dispose();
		return pixels;
	}

	public function dispose() {
		hmap.dispose();
		zmap.dispose();
	}

	public function generate(sx,sy) {
		init(sx,sy);
		finish();
	}

	function init(sx:Int,sy:Int) {
		var p = new flash.geom.Point(sx-IMAX,sy-IMAX);
		hmap = new flash.display.BitmapData(TOT_SIZE,TOT_SIZE);
		hmap.perlinNoise(64,64,3,seed,false,true,4,false,[p,p,p]);
		var vmap = alloc(256,p);
		var cmap = alloc(512,p);
		var nmap = alloc(16,p);
		var hpixels = hmap.getVector(hmap.rect);
		for( addr in 0...TOT_SIZE*TOT_SIZE ) {
			var h = hpixels[addr] & 0xFF;
			var v = vmap[addr] & 0xFF;
			var c = cmap[addr] & 0xFF;
			var n = nmap[addr] & 0xFF;
			var h0 = h;
			h -= 64;
			h = Std.int(h * h / 64);
			h += (v - 128) * 3;
			if( c < 128 )
				h += (c - 128) * 4;
			h = Std.int(h * 0.6);
			if( h > 255 ) h = 255;
			if( h < 0 ) h = 0;
			h += (n - 128) >> 2;
			if( h > 255 ) h = 255;
			if( h < 0 ) h = 0;
			// encode color
			var col = h | (h << 8) | (h << 16);
			hpixels[addr] = 0xFF000000 | col;
		}
		hmap.setVector(hmap.rect,hpixels);
		zmap = new flash.display.BitmapData(TOT_SIZE,TOT_SIZE,true,0);
		zmap.lock();
		zmap.threshold(hmap,hmap.rect,P0,">",200,0xFFFE0000,0xFF,false);
		islands = new List();
		for( x in 0...TOT_SIZE )
			for( y in 0...TOT_SIZE ) {
				var c = zmap.getPixel(x,y);
				if( c != 0xFE0000 ) continue;
				// locate and erase island
				zmap.floodFill(x,y,0xFF00FE00);
				var r = zmap.getColorBoundsRect(0xFFFFFFFF,0xFF00FE00,true);
				zmap.floodFill(x,y,0);
				if( r.width < 3 || r.height < 3 )
					continue;
				// draw random shape starting from island center
				var px = Std.int(r.left + r.width / 2);
				var py = Std.int(r.top + r.height / 2);
				var seed = (((py+sy)*SIZE*60491+(px+sx)) & 0xFFFFFF) ^ this.seed;
				var rnd = new mt.Rand(0);
				rnd.initSeed(seed);
				var dx = (px + sx) / 50.0;
				var dy = (py + sy) / 50.0;
				var dist = Std.int(Math.pow(1+Math.sqrt(dx*dx+dy*dy),0.5)-1);
				if( dist < 0 ) dist = 0;
				for( k in 0...5+rnd.random(30) ) {
					var x = px, y = py;
					for( k in 0...1000 ) {
						var dx = x-px;
						var dy = y-py;
						if( dx <= -IMAX || dx >= IMAX || dy <= -IMAX || dy >= IMAX )
							break;
						zmap.setPixel32(x,y,0xFF808080);
						switch( rnd.random(4) ) {
						case 0: x--;
						case 1: x++;
						case 2: y--;
						case 3: y++;
						}
					}
				}
				islands.add({ x : px, y : py, kind : rnd.random(0xFFFF), dist : dist });
			}
	}

	function finish() {
		// fill island types with proper tile id
		for( i in islands ) {
			#if tora
			var dist = i.dist;
			if( dist >= 25 ) dist = 0xF else if( dist > 0xE ) dist = 0xE;
			zmap.floodFill(i.x,i.y,(i.kind+1) | (dist << 16) | 0xFF000000);
			#else
			var COLORS = [0xFFFFFF,0xFF0000,0x00FF00,0x0000FF,0xFFFF00,0x00FFFF,0xFF00FF];
			zmap.floodFill(i.x,i.y,COLORS[i.kind%COLORS.length] | 0xFF000000);
			#end
		}
		#if !tora
		return;
		#end
		// smooth shapes
		var bytes = zmap.getPixels(zmap.rect);
		flash.Memory.select(bytes);
		for( s in [3,3,4] )
			smooth(s);
		while( smooth(2) ) {
		}
		bytes.position = 0;
		zmap.setPixels(zmap.rect,bytes);
		// remove small water holes
		for( x in 0...TOT_SIZE )
			for( y in 0...TOT_SIZE ) {
				var c = zmap.getPixel(x,y);
				if( c != 0 ) continue;
				zmap.floodFill(x,y,0xFF00FE00);
				var r = zmap.getColorBoundsRect(0xFFFFFFFF,0xFF00FE00,true);
				if( r.width > 5 && r.height > 5 )
					zmap.floodFill(x,y,0x01FFFFFF); // real hole
				else {
					var xx = Std.int((r.left == 0 ) ? r.right : r.left - 1);
					var yy = Std.int((r.top == 0 ) ? r.bottom : r.top - 1);
					zmap.floodFill(x,y,zmap.getPixel32(xx,yy));
				}
			}
		zmap.colorTransform(zmap.rect,new flash.geom.ColorTransform(1,1,1,2,0,0,0,-200));
		// calculate water-distance-map
		var dist = zmap.clone();
		dist.colorTransform(dist.rect,new flash.geom.ColorTransform(0,0,0,1,255,255,255));
		dist.applyFilter(dist,dist.rect,P0,new flash.filters.GlowFilter(0,1,8,8,1,3,true));
		hmap.draw(new flash.display.Bitmap(dist),new flash.geom.Matrix(),null,flash.display.BlendMode.MULTIPLY);
		dist.dispose();
	}

	function smooth( k : Int ) {
		var found = false;
		for( x in 1...TOT_SIZE-1 )
			for( y in 1...TOT_SIZE-1 ) {
				var addr = (x+(y*TOT_SIZE)) << 2;
				var cur : Int = flash.Memory.getI32(addr);
				var other = 0;
				var sum = 0;
				var col : Int;
				for( dx in -1...2 )
					for( dy in -1...2 ) {
						col = flash.Memory.getI32(addr + ((dx+dy*TOT_SIZE) << 2));
						if( col == cur )
							sum++;
						else
							other = col;
					}
				if( sum < k ) {
					flash.Memory.setI32(addr,other);
					found = true;
				}
			}
		return found;
	}

	#if !tora

	static var root : flash.display.Sprite;

	static function click(_) {
		root.scaleX = root.scaleY = 0.25;
		while( root.numChildren > 0 ) {
			var bmp = flash.Lib.as(root.removeChildAt(0),flash.display.Bitmap);
			if( bmp != null ) bmp.bitmapData.dispose();
		}
		var seed = Std.random(100000);
		for( x in 0...(1<<(DIVIDE-1)) )
			for( y in 0...(1<<(DIVIDE-1)) ) {
				var w = new World(seed);
				w.generate(x*SIZE,y*SIZE);

				// reduce size
				var htmp = new flash.display.BitmapData(SIZE,SIZE);
				var rect = new flash.geom.Rectangle(IMAX,IMAX,SIZE,SIZE);
				htmp.copyPixels(w.hmap,rect,P0);
				w.hmap.dispose();
				w.hmap = htmp;
				var ztmp = new flash.display.BitmapData(SIZE,SIZE);
				ztmp.copyPixels(w.zmap,rect,P0);
				w.zmap.dispose();
				w.zmap = ztmp;

				// display
				var zmap = new flash.display.Bitmap(w.zmap);
				zmap.x = x * SIZE;
				zmap.y = y * SIZE;
				root.addChild(zmap);
				var hmap = new flash.display.Bitmap(w.hmap);
				hmap.x = x * SIZE;
				hmap.y = y * SIZE;
				hmap.alpha = 0.5;
				hmap.blendMode = flash.display.BlendMode.MULTIPLY;
				root.addChild(hmap);
			}
	}

	static function main() {
		haxe.Log.setColor(0xFF0000);
		root = new flash.display.Sprite();
		flash.Lib.current.addChild(root);
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.CLICK,click);
		click(null);
	}
	#end

}