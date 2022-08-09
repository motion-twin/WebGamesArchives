package en.tur;

class Burner extends en.Turret {
	var range			: Int;
	
	public function new(tcx,tcy) {
		super(tcx,tcy);
		initLife(15);
		range = 95;
		showBar = true;
		barOffsetY = -2;
		
		sprite.setFrame(1);
		fx.explode(xx,yy);
		
		fx.burn(xx,yy);
	}
	
	public override function update() {
		super.update();
		
		if( !cd.hasSet("autoHit", 30) ) {
			hit(1);
			cd.unset("shield");
		}
		
		if( !cd.hasSet("tick", 16) ) {
			fx.burnGround(xx,yy, range);
			for(e in getMobsInRange(range)) {
				fx.burn(e.xx, e.yy);
				e.hit(2);
				fx.burnHit(e.xx, e.yy-10);
			}
		}
		sprite.alpha = 1;
	}
}


