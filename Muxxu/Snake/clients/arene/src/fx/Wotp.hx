package fx;
import Protocole;

class Wotp extends Fx {//}
	
	public static var GRAVEYARD:Array<Int> = [];

	public function new() {
		super();
		if ( GRAVEYARD.length == 0 ) kill();
	}
	
	override function update() {
		super.update();
	
		if ( Game.me.gtimer % 6 > 0 || Game.me.fruits.length > 100 ) return;
		
		var fr = Fruit.get(GRAVEYARD.pop());
		fr.specialSpawn();
		fr.light = true;
		var p = Stage.me.getRandomPos(20, 40);
		fr.setPos(p.x, p.y);
		
		if ( GRAVEYARD.length == 0 ) kill();
		
		
		var p = Part.get();
		p.sprite.setAlign(0.5, 0.8);
		p.sprite.setAnim( Gfx.fx.getAnim("wisp") );
		Stage.me.dm.add(p.sprite, Stage.DP_FX);
		p.x = fr.x;
		p.y = fr.y+4;
		p.timer = 40;
		p.fadeType = 2;
		p.fadeLimit = 20;
		//p.sprite.blendMode = flash.display.BlendMode.OVERLAY;
		
		
		
	}
	

	
//{
}












