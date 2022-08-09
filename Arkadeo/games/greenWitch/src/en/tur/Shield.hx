package en.tur;

class Shield extends en.Turret {
	
	public function new(tcx,tcy) {
		super(tcx,tcy);
		absorbDamageRange = 170;
		showBar = true;
		initLife(15);
		sprite.setFrame(0);
	}
	
	public override function hit(d) {
		cd.unset("shield");
		super.hit(d);
	}
}

