package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import Protocol;
import api.AKApi;
import haxe.rtti.Meta;

class Bonus extends mt.fx.Fx {
	
	var type:PowerUp;
	var root:SP;
	
	function getWeight(bonus:PowerUp) {
		var a = haxe.rtti.Meta.getFields(PowerUp) ;
		var weight = Reflect.field(a, Std.string(bonus)).weight[0];
		switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION:
				switch( bonus )
				{
					//on ne veut pas du bonus de temps et de multiplicateur de points en mode progression / levelup
					case PowerUp.TEMPO, PowerUp.MULTI : weight = 0;
					default:
				}
			case GM_LEAGUE:
		}
		return weight;
	}

	public function new() {
		super();
		var sum = 0;
		var all = Type.allEnums(PowerUp);
		for( p in all ) {
			sum += getWeight(p);
		}
		
		var id = Game.me.seed.random(sum);
		for( m in all ) {
			id -= getWeight(m);
			if( id <= 0 ) {
				type = m;
				break;
			}
		}
		
		#if dev
		if( Cs.TEST_BONUS != null ) type = Cs.TEST_BONUS;
		#end
		
		// GFX
		root = new SP();
		Game.me.dm.add(root, Game.DP_BADS);
		
		root.graphics.lineStyle(3, 0xFFFFFF);
		root.graphics.drawCircle(0, 0, 13);
		Filt.glow(root, 8, 2, 0xFF00FF);
		root.blendMode = flash.display.BlendMode.ADD;
		
		var el = new EL();
		el.goto(Type.enumIndex(type), "powerup");
		el.scaleX = el.scaleY = 2;
		el.x = el.y = 1;
		root.addChild(el);
		
		do randomPos() while(getHeroDist() < 120);
		#if sound
		Sfx.play(17, 0.75);
		#end
		var e = new mt.fx.Spawn(root, 0.1, false, true);
		e.curveIn(0.5);
	}
	
	override function update() {
		super.update();
		
		if( getHeroDist() < 24 ) {
			#if sound
			Sfx.play(18, 2);
			#end
			Game.me.hero.addPower(type);
			kill();
		}
		
	}
	
	inline public function getHeroDist() {
		var dx = root.x - Game.me.hero.x;
		var dy = root.y - Game.me.hero.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	public function randomPos() {
		var ma = 36;
		root.x = ma + Game.me.seed.random(Game.WIDTH - 2 * ma);
		root.y = ma + Game.me.seed.random(Game.HEIGHT - 2 * ma);
	}
	
	override function kill() {
		root.parent.removeChild(root);
		super.kill();
	}
	
}
