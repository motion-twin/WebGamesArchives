package seq;
import mt.bumdum9.Lib;
import Protocol;
import api.AKApi;
import api.AKProtocol;

class BonusPop  extends mt.fx.Sequence {
	
	var count : Int;
	var nextPop : Int;
	inline static var FRAME_PER_SECOND = 30;
	public function new() {
		super();
		count = 1;
		nextPop = (20 + Game.me.rnd(10) ) * FRAME_PER_SECOND;
	}
	
	override function update() {
		super.update();
		//TODO
		if( Game.me.gtimer == nextPop )
		{
			doPopBonus();
			count++;
			nextPop += count * (20 + Game.me.rnd(10) ) * FRAME_PER_SECOND;
		}
	}
	
	function doPopBonus(?k:BonusKind) {
		if( k == null )
			k = Type.createEnumIndex( BonusKind, [0,0,1][Game.me.rnd(3)] );
		var ent = new ent.Bonus(k);
	}
}
