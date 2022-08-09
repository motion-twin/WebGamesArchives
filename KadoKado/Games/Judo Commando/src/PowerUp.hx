import Protocole;
import mt.bumdum.Lib;

class PowerUp extends Ent {//}

	var btype:Bonus;
	var timer:Int;

	public function new(bt){
		super(Game.me.dm.attach("mcBonus",Game.DP_BONUS));
		type = BONUS;
		ray = 0.25;

		btype = bt;
		/*
		if( Game.me.hero.life<10 ){
			if( Std.random(Cs.PROBA_YAKITORI) == 0 )	btype = Yakitori;
			if( Std.random(Cs.PROBA_BURGER) == 0 )		btype = Burger;
		}
		*/


		root.gotoAndStop(Type.enumIndex(btype)+1);
		switch(btype){
			case Gem(tag) :
				root.smc.gotoAndStop(Type.enumIndex(tag)+1);
			default:

		}

		timer = 150;

	}

	override function update(){
		super.update();

		if( Math.random()*50 < 1 )root.smc.smc.play();
		if(timer--<=0)vanish();


	}

	override function land(){
		if( Math.abs(vy)< 1 ){
			oy = 1-ray;
			stopPhys();
		}
	}

	public function activate(){
		switch(btype){
			case Gem(tag) :
				var index = Type.enumIndex(tag);
				Game.me.playInfo._g[index]++;
				Game.me.tags.set(index,true);
				Game.me.fxScore(root._x,root._y,Cs.SCORE_GEM);
				Game.me.updateGems(index);
			case Burger :
				Game.me.playInfo._b[1]++;
				Game.me.hero.incLife(3);
			case Yakitori :
				Game.me.playInfo._b[0]++;
				Game.me.hero.incLife(1);


		}

		for( i in 0...8 ){
			var p = new mt.bumdum.Phys(Game.me.dm.attach("fxTwinkle",Game.DP_FX));
			p.x = root._x + Std.random(11)-5;
			p.y = root._y + Std.random(11)-5;
			p.weight = -(0.05+Math.random()*0.05);
			p.frict = 0.92;
			p.timer = 10+Math.random()*15;
			p.sleep = Math.random()*12;
			p.root._visible = false;
			Cs.randomize(p.root);
			p.root.play();
			p.updatePos();
			p.fadeType = 1;

		}


		kill();
	}

	function vanish(){
		Game.me.fxAttach("mcVanish",root._x,root._y-1);
		kill();
	}






//{
}




















