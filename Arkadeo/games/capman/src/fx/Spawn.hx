package fx;
import mt.bumdum9.Lib;
import Protocol;

/**
 * make Bads spawn
 */
class Spawn extends mt.fx.Sequence {
	
	var bid:Int;
	var square:Square;
	
	/**
	 * @param	bid		Bad id
	 */
	public function new(bid:Int) {
		super();
		this.bid = bid;
		square = Game.me.getFreeRandomSquare();
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				square.fxTwinkle();
				if( timer == 40 ) {
					nextStep();
					var b = Game.me.spawnBad(bid);
					b.setSquare(square.x, square.y);
					b.seekDir();
					b.starDust = 40;
					
					var e = new mt.fx.ShockWave(32, 64, 0.05);
					e.curveIn(0.5);
					var pos = square.getCenter();
					e.setPos(pos.x, pos.y);
					Level.me.dm.add(e.root,Level.DP_FX);
					Col.setColor(e.root, 0x00FF88);
					e.root.blendMode = flash.display.BlendMode.ADD;
					
					kill();
				}
		}
		
	}
}
