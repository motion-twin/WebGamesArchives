package fx;
import mt.bumdum9.Lib;
using mt.bumdum9.MBut;
import Protocol;

class Egg extends mt.fx.Sequence {
	
	var square:Square;
	var skin:gfx.Egg;
	var bonus :Bonus;

	public function new(sq, comboLength:Int) {
		super();
		square = sq;
		
		if( comboLength > Cs.COMBO_MINIMUM ) {
			bonus = new Bonus(sq, [Bonus.BONUS_ANIMALS_ESCAPE, Bonus.BONUS_POINTS_MULT, Bonus.BONUS_QUIETNESS]);
		} else {
			bonus = new Bonus(sq, [Bonus.BONUS_BOMB]);
		}
		bonus.mc.visible = false;
		
		// SKIN
		skin = new gfx.Egg();
		Game.me.dm.add(skin, Game.DP_GROUND);
		var pos = square.getCenter();
		skin.x = pos.x;
		skin.y = pos.y;
		skin.stop();
	}
	
	override function update() {
		super.update();
		switch( step ) {
			case 0 :
				if( timer == 50 ) {
					skin.play();
					nextStep();
				}
			case 1 :
				if( timer == 20 ) {
					bonus.mc.visible = true;
					new mt.fx.Spawn(bonus.mc, 0.1, false, true);
				}
				if( timer == 40 ) {
					skin.parent.removeChild(skin);
					kill();
				}
		}
	
	}

}