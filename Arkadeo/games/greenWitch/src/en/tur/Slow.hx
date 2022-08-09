package en.tur;

class Slow extends en.Turret {
	static var RANGE = api.AKApi.const(140);
	static inline var COLOR = 0x0CE416;
	
	var halo		: flash.display.Bitmap;
	
	
	public function new(tcx,tcy) {
		super(tcx,tcy);
		initLife(15);
		showBar = true;
		barOffsetY = -31;
		
		sprite.setCenter(0.52, 0.8);
		sprite.setFrame(2);
		
		// Halo
		var s = new flash.display.Sprite();
		s.graphics.beginFill(COLOR, 0.2);
		s.graphics.drawCircle(0,0, RANGE.get()*0.85);
		s.filters = [ new flash.filters.BlurFilter(32,32) ];
		halo = mt.deepnight.Lib.flatten(s, 16, true);
		halo.blendMode = flash.display.BlendMode.ADD;
		game.sdm.add(halo, Const.DP_BG_FX);
		
		fx.slowGround(xx,yy, RANGE.get(), COLOR, true);
	}
	
	public override function detach() {
		super.detach();
		halo.bitmapData.dispose();
		halo.parent.removeChild(halo);
	}
	
	public override function update() {
		super.update();
		
		if( !cd.hasSet("autoHit", 30) )
			hit(1);
		
		if( !cd.hasSet("fx", 15) )
			fx.slowGround(xx,yy, RANGE.get(), COLOR);
		
		if( !cd.hasSet("shoot", 20) ) {
			for(e in getMobsInRange(RANGE.get())) {
				e.cd.set("weakness", 30);
				e.cd.set("slow", 30);
			}
		}
		
		halo.x = xx - halo.width*0.5;
		halo.y = yy - halo.height*0.5;
	}
}

