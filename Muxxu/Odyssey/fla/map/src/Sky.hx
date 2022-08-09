class Sky {

	public var b : flash.display.BitmapData;
	public var zoom : Float;
	public var speed : Float;
	var balpha : flash.display.BitmapData;
	var perlin : FPerlin;
	var anim : Int;
	var odx : Float;
	var ody : Float;
	var t : Float;
	var animSkip : Int;
	var wind : Int;
	
	public function new(w,h,wind) {
		b = new flash.display.BitmapData(w, h, true);
		balpha = new flash.display.BitmapData(w, h, true);
		perlin = new FPerlin(w, h);
		perlin.setGradientAlpha([
			{ v : -1., c : 0xFFFFFFFF },
			{ v : 0., c : 0x809AB2B6 },
			{ v : 1., c : 0xFFFFFFFF }
		]);
		speed = 1.0;
		anim = 1;
		zoom = 1.0;
		animSkip = 4;
		t = 3;
		this.wind = wind;
	}
	
	function initPalette( colors : Array<Int> ) {
		var pal = [];
		for( i in 0...256 ) {
			var pos = (i / 256) * (colors.length - 1);
			var p = Std.int(pos);
			pos = 1 - pos + p;
			var c0 = colors[p];
			var c1 = colors[p + 1];
			var r = Std.int((c0 >> 16) * pos + (c1 >> 16) * (1 - pos));
			var g = Std.int(((c0 >> 8) & 0xFF) * pos + ((c1 >> 8) & 0xFF) * (1 - pos));
			var b = Std.int((c0 & 0xFF) * pos + (c1 & 0xFF) * (1 - pos));
			pal.push((r << 16) | (g << 8) | b);
		}
		return pal;
	}
	
	function initPaletteLevels( colors : Array<{ v : Int, c : Int }> ) {
		var pal = [];
		var index = 0;
		for( i in 0...256 ) {
			while( index < colors.length && i >= colors[index].v )
				index++;
			pal.push(colors[index-1].c);
		}
		return pal;
	}
	
	public function setAlpha( bmp : flash.display.BitmapData, x : Int, y : Int ) {
		balpha.copyPixels(bmp, new flash.geom.Rectangle(x, y, balpha.width, balpha.height), new flash.geom.Point(0, 0));
	}
	
	public function update(dx, dy) {
		t += mt.Timer.deltaT * speed / (zoom * 20);
		anim++;
		
		if( odx == dx && ody == dy && anim % animSkip != 0 )
			return;
		
		var a = wind * Math.PI / 4;
		perlin.init(541, dx + t * Math.cos(a), dy + t * Math.sin(a), t * 2);
		perlin.clear();
		var z = zoom * 0.5;
		perlin.add3D(z / 16, 0.8);
		perlin.add3D(z / 8, 0.4);
		perlin.add3D(z / 4, 0.25);
		perlin.mergeGradientAlpha();
		b.setPixels(b.rect, perlin.getPixels());
		b.copyPixels(b, b.rect, new flash.geom.Point(0, 0), balpha);
	
		
		odx = dx;
		ody = dy;
	}
		
}