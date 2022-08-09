package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class PinkRibbon extends CardFx {//}
	
	
	var ribbon:pix.Element;

	
	public function new(ca) {
		super(ca);
		ribbon = new pix.Element();
		ribbon.drawFrame(Gfx.fx.get("pink_ribbon"));
		
		Stage.me.dm.add(ribbon, Stage.DP_SNAKE);
	}
	

	override function update() {
		super.update();
		
		var n = sn.length - 10;
		var o = sn.getRingData(n);
		
		ribbon.visible = sn.isRingIn(o.ring);
		ribbon.x = o.ring.x;
		ribbon.y = o.ring.y;
		ribbon.rotation = o.a / 0.0174 + 90;
		ribbon.scaleX = ribbon.scaleY = 0.75 * o.ring.size;
		
		checkCols();
			

		
	}
	
	public function checkCols() {
		
		var ray = 10*ribbon.scaleX;
		var rect = new flash.geom.Rectangle(ribbon.x - ray, ribbon.y - ray, ray * 2, ray * 2);
		// FRUITS
		var a = Game.me.fruits.copy();
		for( fr in a ) {
			if( fr.hitTest2(rect) && !fr.dummy) {
				Game.me.have(PINK_RIBBON, true);
				new FruitToTarget(fr, 10,sn);
			}
		}
		
		// BONUS
		var a = Game.me.bonus.copy();
		for( b in a ) if( b.hitTest2(rect) ) b.trig();
		
	}
	

	override function kill() {
		ribbon.kill();
		super.kill();
	}

	
//{
}












