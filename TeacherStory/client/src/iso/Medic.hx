package iso;

class Medic extends Iso {
	var mc			: lib.Infirmiere;
	
	public function new() {
		super();
		
		mc = new lib.Infirmiere();
		sprite.addChild(mc);
		mc.y+=25;
		mc.scaleX = -1;
		setAnim("stand");
		headY = 20;
	
		fl_static = false;
		speed = 0.1;
	}
	
	public override function goto(pt, ?speedMul=1.0) {
		super.goto(pt, speedMul);
		setAnim("walk");
	}
	
	public function setAnim(?k="stand") {
		mc.gotoAndStop(k);
		try {
			var smc : flash.display.MovieClip = Reflect.field(mc._sub, "_sub");
			smc.stop();
		}catch(e:Dynamic) {}
	}
	
	override function onArrive() {
		super.onArrive();
		setAnim();
		man.cm.signal("medic");
	}
	
	public override function update() {
		super.update();
		
		var mouth : flash.display.MovieClip = Reflect.field(mc._sub, "_sub");
		if( mouth!=null )
			if( cd.has("talking") ) {
				if( !cd.has("mouth") ) {
					var last = mouth.currentFrame;
					var f = 0;
					do {
						f = Std.random(mouth.totalFrames)+1;
					} while( f==last );
					mouth.gotoAndStop(f);
					cd.set("mouth", Std.random(2)+3);
				}
			}
			else
				mouth.gotoAndStop(1);
	}
}

