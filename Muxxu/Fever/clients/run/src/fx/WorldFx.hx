package fx;
import mt.bumdum9.Lib;
class WorldFx extends mt.fx.Fx{//}
	
	
	var h:world.Hero;
	var isl:world.Island;
	
	public function new() {
		super();
		h = World.me.hero;
		isl = World.me.island;
	}
	
	function addFx(sp:flash.display.Sprite) {
		isl.dm.add(sp, world.Island.DP_FX);
	}
	function addElement(sp:flash.display.Sprite) {
		isl.dm.add(sp, world.Island.DP_ELEMENTS);
	}
//{
}








