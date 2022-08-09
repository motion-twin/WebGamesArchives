package ac.mon;
import Protocole;
import mt.bumdum9.Lib;



class MagicAttack extends Action {//}
	
	public var agg:Monster;
	public var trg:Hero;
	public var focusSequence:Bool;
	
	
	public function new(agg,trg) {
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
		}
		
	}
	
	public function end() {
		step = 212;
		if ( trg.have(MANA_LEAK) ) add( new ac.hero.Regeneration(trg,2,[MECHA_CRYSTAL,MECHA_CRYSTAL]));
		
		
	}
	
	
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				
				var mc = new FxDustTwinkle();
				var p = new part.Focus( mc );
				p.setFolkTarget(agg.folk,40,3+Math.random()*2);
				if ( coef == 1 ) start();
				
			case 212 :
				if ( tasks.length == 0 ) kill();

			default :
				updateSpell();
		}
		
	}
	public function updateSpell() {
		
	}
	
	
	public function fail() {
		trg.board.fxArmor();
		kill();
	}
	
	// TOOLS
	public function checkResistance() {
		return Std.random(100) < trg.getMagicResistance();
	}
	public function getMagicImpact(n) {
		return Math.round( n * Math.max(1 - trg.getMagicResistance() * 0.01,0) );
	}
	
//{
}






