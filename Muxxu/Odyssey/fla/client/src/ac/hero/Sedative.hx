package ac.hero;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;




class Sedative extends Action {//}
	
	

	var hero:Hero;
	var tablet:MC;
	
	public function new(hero) {
		super();
		this.hero  = hero;
		
	}
	override function init() {
		super.init();
		hero.folk.play("atk", launch,true);
		
		
	}
	
	override function update() {
		super.update();
		
		
		if ( step == 1 && timer > 16 ) kill();
	}

	function launch() {
		
		tablet = new GameIcons();
		tablet.gotoAndStop( Type.enumIndex(TABLET) + 1 );
		Scene.me.dm.add(tablet, Scene.DP_FX);
		
		var pos = hero.folk.getCenter();
		tablet.x = pos.x + 10;
		tablet.y = pos.y + 10;
		
		var dest = game.monster.folk.getCenter();
		
		var e = new mt.fx.Tween(tablet, dest.x, dest.y,0.05 );
		e.setSin(60);
		e.onFinish = impact;
		
	}
	
	function impact() {
		tablet.parent.removeChild(tablet);
		var mon = game.monster;
		mon.fxHit();
		
		for( i in 0...3 ) mon.firstChain.unshift(AC_SLEEP);
		mon.majInter();
		nextStep();
	}


	
	
//{
}