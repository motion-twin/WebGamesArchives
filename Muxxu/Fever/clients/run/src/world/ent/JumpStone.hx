package world.ent;
import Protocole;




class JumpStone extends world.Ent {//}
	
	var dir:Int;
	var el:pix.Element;
	
	public  function new(island, sq, di) {
		depth = world.Island.DP_GROUND;
		super(island, sq);
		type = EJumpStone(di);
		dir = di;
		
		el = new pix.Element();
		el.drawFrame(Gfx.world.get(0, "jump_stone"));
		addChild(el);

	}
	

	override function heroIn() {
		var data = world.Loader.me.data;
		if( data._rainbows > 0 || island.isSafe() ) {
			World.me.hero.initJumpArrow(dir);
		}else {
			world.Inter.me.displayHint(Lang.NO_MORE_RAINBOW);
		}
	}

	override function getProtectValue() {
		var d = Cs.DIR[dir];
		var np = WorldData.getPos(island.px + d[0], island.py + d[1]);
		var data = WorldData.me.getIslandData(np.x, np.y);
		return ( data.dif  > island.data.dif )?3: -3;
		
	}
	
	override function onComplete() {
		el.drawFrame(Gfx.world.get(1, "jump_stone"));
	}
	
	
//{
}








