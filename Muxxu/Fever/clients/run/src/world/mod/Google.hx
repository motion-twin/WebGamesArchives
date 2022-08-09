package world.mod;
import Protocole;
import mt.bumdum9.Lib;

class Google extends world.Mod{//}
	

	var mon:world.ent.Monster;
	var timer:Int;
	var list:Array<McGameIcon>;
	
	
	public function new() {
		ww = 88;
		hh = 37;
		super();
		drawBg(0);
		center();

		
		var h = World.me.hero;
		mon = h.getNearestMonster(2);
		if( mon == null ) {
			kill();
			world.Inter.me.setWarning(Lang.NO_MONSTER);
			return;
		}
		
		x += (mon.sq.x-h.sq.x) * 16;
		y += (mon.sq.y-h.sq.y) * 16;
		y += 8 + Std.int(hh *0.5);
		
		//
		var max = 10;
		var size = 16;
		var a = player.Adventure.getMonsterGameList(mon.data, mon.sq.ints[0] );
		list = [];
		for( i in 0...max ) {
			var mc = new McGameIcon();
			mc.width = size;
			mc.scaleY = mc.scaleX;
			mc.y = 2 + (size + 1) * Std.int(i/5);
			mc.x = 2 + (size + 1) * (i % 5);
			Col.setPercentColor(mc, 1, 0x333333);
			mc.gotoAndStop(a[i] + 1);
			dm.add(mc, 1);
			list.push(mc);
		}
		
		
		//
		Filt.glow(mon, 2, 12, 0xFFFFFF, false);
		timer = 0;
		
	}
	
	override function update(e) {
		if( timer++ > 3 && list.length > 0) {
			timer = 0;
			var fx = new mt.fx.Flash(list.shift());
			fx.glow(2, 4);
		}
	
	}
	override function click(e) {
		super.click(e);
		mon.filters = [];
		kill();
	}
	
	


	
//{
}








