class Map {

	static var g : flash.display.Graphics;

	static function generate() {
		g.clear();
		haxe.Log.clear();
		var t0 = flash.Lib.getTimer();
		var gen = new data.MapGenerator();
		gen.generate(500,300);
		g.lineStyle(1,0,0.5);
		g.drawRect(0,0,gen.width,gen.height);
		var nedges = 0;
		for( p in gen.places )
			for( l in p.links ) {
				g.moveTo(p.x,p.y);
				g.lineTo(l.x,l.y);
				nedges++;
			}
		var cities = 0;
		var a = new Array();
		for( p in gen.places ) {
			if( p.city ) cities++;
			g.beginFill(p.city ? 0xFF0000 : 0xFFFFFF );
			g.drawCircle(p.x,p.y,2);
			a.push({ _x : p.x, _y : p.y, _isCity : p.city, _n : p.links.map(function(p) return p.id) });
		}
		var str = gen.serialize();
		try flash.system.System.setClipboard(str) catch( e : Dynamic ) {};
		trace("Size : "+gen.width+" x "+gen.height);
		trace("Time : "+(flash.Lib.getTimer() - t0));
		trace(cities+" / "+gen.places.length+" , "+nedges+" edges"+" , "+str.length+" bytes");
	}

	static function main() {
		var mc = new flash.display.Sprite();
		mc.x = 50;
		mc.y = 70;
		flash.Lib.current.addChild(mc);
		g = mc.graphics;
		generate();
		mc.stage.addEventListener(flash.events.MouseEvent.CLICK,function(_) generate());
	}

}