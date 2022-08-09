package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class MagicAttack extends Action {//}
	
	public var agg:Hero;
	public var trg:Monster;
	public var focusSequence:Bool;
	
	var waver:fx.morph.Waver;
	public function new(agg,?trg) {
		super();
		this.agg = agg;
		this.trg = trg;
		focusSequence = agg.folk.haveAnim("magic");
	}
	
	override function init() {
		super.init();
		if( focusSequence ){
			agg.folk.play("magic",true);
			spc = 0.02;
			waver = new fx.morph.Waver(1);
		}else {
			start();
		}
		
	}
	
	public function start() {
		nextStep();
		if ( focusSequence ) {
			agg.folk.anim.gotoAndPlay("release");
			for ( p in part.Focus.ALL ) {
				p.trg = null;
				var pos = agg.folk.getCenter();
				var dx = p.x - pos.x;
				var dy = p.y - pos.y;
				p.an = Math.atan2(dy, dx);
				p.asp = 3 + Math.random() * 3;
				p.fadeType = 2;
				p.timer = 10 + Std.random(10);
				
			}
			waver.fade(0.1);
		}
		
		
		
	}
	
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				
				var mc = new FxDustTwinkle();
				var p = new part.Focus( mc );
				p.setFolkTarget(agg.folk,40,3+Math.random()*2);
				if ( coef == 1 ) start();

			default :

				updateSpell();
		}
		
		/*

		*/
		
	}
	public function updateSpell() {
		
	}
	
	
	public function fail() {
		
		kill();
	}
	
	// TOOLS
	public function checkResistance() {
		return false;
	}
	public function getMagicImpact(n) {
		return n;
	}
	
//{
}






