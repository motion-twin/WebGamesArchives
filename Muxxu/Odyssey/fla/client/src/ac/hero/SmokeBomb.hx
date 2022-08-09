package ac.hero;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;




class SmokeBomb extends Action {//}
	
	

	var hero:Hero;

	
	public function new(hero) {
		super();
		this.hero = hero;
		
		

		
	}
	override function init() {
		super.init();
		for ( h in Game.me.heroes )  add( new Regeneration(h, 999) );
	}
	
	public function escape() {
		nextStep();
		for ( h in Game.me.heroes ) {
			for( i in 0...12 ){
				var mc = new FxCloud();
				var p = Scene.me.getPart(mc);
				//var pos = Tools.getMcPos(hero.folk, 12);
				var pos = h.folk.getRandomBodyPos();
				if ( pos != null ) p.setPos(pos.x, pos.y);
				p.weight = -(0.05 + Math.random() * 0.1);
				mc.gotoAndPlay(Std.random(6) + 1);
				p.timer = 30;
				p.setScale(0.5 + Math.random() * 0.8);
			}
		}
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				if ( tasks.length == 0 ) escape();
				
			case 1 :
				if ( timer == 6 ) {
					nextStep();
					
					for ( h in Game.me.heroes ) {
						h.folk.setSens( -1);
						h.folk.play("run");
					}
				
				}
				
			case 2 :
				for ( h in Game.me.heroes ) h.folk.x -= 12;
				
				if ( timer == 36 ) {
					Game.me.end(false);
				}
			
			
		}

	}



	
	
//{
}