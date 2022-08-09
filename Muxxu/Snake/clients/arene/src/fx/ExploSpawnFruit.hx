package fx;
import Protocole;
import mt.bumdum9.Lib;


class ExploSpawnFruit extends Fx {//}
	
	var type:FTag;
	
	public function new(x,y,t,max) {
		type = t;
		super();
		var cr = 3;
		
		for( i in 0...max ) {
			var a = ((i + Game.me.seed.rand()) / max) * 6.28;
			var speed = 3 + Game.me.seed.rand() * 2;
			var p = Part.get();
			p.sprite.setAnim(Gfx.fx.getAnim("spark_dust_pulse"));
			Stage.me.dm.add(p.sprite, Stage.DP_FX );
			p.launch(a, speed, -(4+Game.me.seed.rand()*2));
			p.x = x;
			p.y = y;
			p.dropShade();
			p.weight = 0.2;
			p.frict = 0.95;
			var me = this;
			p.onGroundBounce = function() { me.bounce(p); };
		}
		
	}
	

	override function update() {
		super.update();
	}
	
	function bounce(p:Part) {
		
		var rank = Game.me.getRandomFruitRank();
		rank = Fruit.getNearest( rank, type);
		var fr = Fruit.get(rank);
		fr.x = p.x;
		fr.y = p.y;
		fr.updatePos();
		fr.specialSpawn();
		
		//
		p.kill();
	}
	
	
//{
}












