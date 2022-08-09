package ac;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;



class MonsterDeath extends Action {//}
	

	var monster:Monster;
	public function new(mon:Monster) {
		super();
		spc = 0.1;
		monster = mon;
		Game.me.xpsum += mon.data.lvl;
	}
	
	override function init() {
		super.init();
	
		if ( !monster.folk.visible ) {
			monster.folk.kill();
			nextStep();
			return;
		}
		
		if ( !monster.folk.haveAnim("die")) {
			endAnim();
			return;
		}
		
		monster.folk.play("die");
		monster.folk.anim.autoLoop = false;
		monster.folk.anim.addEndEvent( endAnim );
	}
	
	
	// UPDATE
	override function update() {
		super.update();
		
		switch(step) {
			case 0 :
				monster.pan.alpha = 1 - coef;
				//if ( coef == 1 ) nextStep();

			case 1 :
				if (timer == 20) {
					
				
					
					for ( h in Game.me.heroes ) {
						if ( h.have(SLAUGHTERER) ) {
							add( new ac.hero.Regeneration(h,3) );
							add( new Fall() );
						}
						if ( h.have(SPOLIATION) ) {
							//add( new ac.hero.Regeneration(h,3) );
							add( new ac.hero.Steal(h, monster, 1) );
							add( new Fall() );
						}
						if ( h.have(SEA_FIGHT) ) {
							add( new ac.hero.SelfBubble(h) );
						}
					}
					
					monster.kill();
					
					if ( game.opponents.length > 0 ) 	add( new ac.NextMonster(false) );
					else								add( new ac.Victory() );
					onEndTasks = kill;
				}

			
		}
		
			
	}
	
	function endAnim() {
		nextStep();
	
		var a = Tools.slice( monster.folk, 24 );
		
		for( p in a ) {
			Scene.me.dm.add(p.root, Scene.DP_FX);
			p.vx = Math.random();
			p.weight = -(0.1 + Math.random() * 0.1);
			p.frict = 0.99;
			p.fadeType = 2;
			p.timer = 10 + Std.random(20);
			new mt.fx.Sleep(p, null, Std.int(p.y) - 60);//Scene.HEIGHT);
			
		}
		
		monster.folk.kill();
		
	}


	
	
//{
}