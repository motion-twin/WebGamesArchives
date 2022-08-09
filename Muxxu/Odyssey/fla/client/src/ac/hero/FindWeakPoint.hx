package ac.hero;
import Protocole;
import mt.bumdum9.Lib;

private typedef WPRound = { sp:SP, coef:Float };

class FindWeakPoint extends Action {//}
	
	var hero:Hero;
	var trg:Monster;
	var rounds:Array<WPRound>;
	
	public function new(hero,trg) {
		super();
		this.hero = hero;
		this.trg = trg;
	}
	override function init() {
		super.init();
		rounds = [];
		
		
	}
	
	
	override function update() {
		super.update();
		
		var a = rounds.copy();
		for ( o in a ) {
			o.sp.scaleX *= o.coef;
			o.sp.scaleY = o.sp.scaleX;
			if ( o.sp.scaleX < 0.25 ) {
				rounds.remove(o);
				o.sp.parent.removeChild(o.sp);
				new mt.fx.Flash(trg.folk, 0.1);
			}
		}
				
		switch(step) {
			case 0:

				if ( timer%5 == 0 ) {
					var sp = new SP();
					Scene.me.dm.add(sp, Scene.DP_UNDER_FX);
					
					var size = 92;
					var ec = 4;
					
					sp.graphics.beginFill(0xFFFFFF);
					sp.graphics.drawCircle(0, 0, size);
					sp.graphics.drawCircle(0, Math.random()*ec, size-ec);
					sp.graphics.endFill();
					sp.rotation = Math.random() * 360;
					
					var pos = trg.folk.getCenter();
					sp.x = pos.x;
					sp.y = pos.y;
					
					Filt.glow(sp, 10, 1, 0x00FFFF);
					sp.blendMode = flash.display.BlendMode.ADD;
					
					
					rounds.push( { sp:sp, coef:0.9 + Math.random() * 0.05 } );
				}
				if ( timer > 40 ) nextStep();
				
			case 1 :
				if ( rounds.length == 0 ) {
					trg.addStatus(STA_WEAK_POINT);
					kill();
				}
			
		}
		
	}
	
	//
	


	
	
//{
}