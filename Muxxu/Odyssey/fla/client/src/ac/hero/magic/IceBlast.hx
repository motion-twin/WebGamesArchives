package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class IceBlast extends ac.hero.MagicAttack {//}
	
	var hero:Hero;
	var com:Combo;
	
	public function new(hero, com:Combo) {
		
		super(hero,Game.me.monster);
		this.hero = hero;
		this.com = com;
		focusSequence = false;
	}
	override function start() {
		super.start();
		var e = new fx.Projectile(hero.folk, game.monster.folk, 1);
		e.onFinish = apply;
		hero.board.damageBreath(com.power);
		
	}
	
	
	// UPDATE
	public function apply() {
	
		trg.hit( { value:com.power, types:[ICE(com.time),MAGIC], source:cast hero } );	//o_O
		kill();
	}
	
	//
	


	
	
//{
}