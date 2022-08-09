package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Smiley extends Fx {//}
	
	static public var list:Array<Smiley> = [];
	static public var RAY = 13;
	var card:Card;
	public var sprite:pix.Sprite;
	var shade:pix.Sprite;
	var obs:Obstacle;
	
	public function new(ca) {
		list.push(this);
		card=ca;
		super();
		sprite = new pix.Sprite();
		sprite.drawFrame(Gfx.fx.get("smiley"));
		Stage.me.dm.add(sprite, Stage.DP_FRUITS);
		
		var pos = null;
		do{
			pos = Stage.me.getRandomPos(40, 40, 15);
		}while( Game.me.gtimer < 100 && Math.abs(pos.y - sn.y) < 30 && pos.x < 150 );
		
		var ma = 40;
		sprite.x = pos.x;
		sprite.y = pos.y;
		obs = Game.me.addObstacle( sprite.x, sprite.y, RAY, collide );
		
		shade = new pix.Sprite();
		shade.drawFrame(Gfx.fx.get("smiley"));
		Col.setPercentColor(shade, 1, 0);
		shade.x = sprite.x + 3;
		shade.y = sprite.y + 3;
		Stage.me.shadeLayer.addChild(shade);

		
	}
	
	public function collide() {
		new Flash( sprite, 0.1 );
	}
	override function update() {
		super.update();
		if ( !card.active ) vanish();
		
	}
	
	public function vanish() {
		kill();
	}
	override function kill() {
		list.remove(this);
		sprite.kill();
		shade.kill();
		Game.me.removeObstacle(obs);
		
	}

	
//{
}












