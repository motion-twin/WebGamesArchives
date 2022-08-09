package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class God extends Action {//}
	
	
	var focusSequence:Bool;
	var hero:Hero;
	var waver:fx.morph.Waver;
	var godShade:gfx.God;
	var godType:Int;
	
	public function new(h,type) {
		super();
		hero = h;
		godType = type;
		focusSequence = hero.folk.haveAnim("magic");
	}
	override function init() {
		super.init();
		if( focusSequence ){
			hero.folk.play("magic",true);
			spc = 0.015;
		}else {
			start();
		}
		
		godShade = new gfx.God();
		godShade.gotoAndStop(godType + 1);
		//godShade.gotoAndStop(2);
		var b = godShade.getBounds(godShade);
		Scene.me.dm.add(godShade, Scene.DP_UNDER_FX);
		godShade.x = hero.folk.x;
		godShade.y = hero.folk.y - b.top;
		
		godShade.blendMode = flash.display.BlendMode.OVERLAY;
		
		var move = new mt.fx.Tween( godShade, godShade.x, hero.folk.y, spc );
		move.curveIn(0.3);
		
		
		
	}
	
	override function update() {
		super.update();
		
		switch(step) {
			case 0 :
				var ray = 30;
				var p = new mt.fx.Part( new FxFluo() );
				p.setPos(hero.folk.x + Math.random() * ray * 2 - ray, Scene.HEIGHT);
				Scene.me.dm.add(p.root, (Std.random(2)==0)?Scene.DP_UNDER_FX:Scene.DP_FOLKS);
				p.weight = -(0.05 + Math.random() * 0.1);
				p.timer = 10 + Std.random(20);

				p.root.blendMode = flash.display.BlendMode.ADD;
				p.fadeType = 2;
				if ( coef == 1 ) start();
				
			default :
			
				updatePrayer();
		}
		
	}
	
	
	//
	public function start() {
		nextStep();
		if ( focusSequence ) {
			hero.folk.anim.gotoAndPlay("release");
			//hero.folk.anim.addEndEvent( callback( hero.folk.play, "stand", null, false) );
		}
		
		var t = 40;
		new mt.fx.Tween( godShade, godShade.x, godShade.y - 16, 1/t);
		new mt.fx.Vanish( godShade, t, t, true);
	}
	
	public function updatePrayer() {
		
	}
	

	
	

	
	//
	


	
	
//{
}