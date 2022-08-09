package world.mod;
import Protocole;
import mt.bumdum9.Lib;

private typedef Vig = {mc:McGameIcon,id:Int};

class Book extends world.Mod{//}
	
	static var SIZE = 16;
	static var MA = 1;
	static var COL = 10;
	static var MAX = 100;
	
	var vigs:Array<Vig>;
	var cursor:SP;
	var sign:pix.Element;
	
	public function new() {
		ww = MA*4 + SIZE*COL + MA*(COL-1);
		hh = ww;
		super();
		
		drawBg(0);
		
		//
		vigs = [];
		for( i in 0...MAX ) {
			var mc = new McGameIcon();
			mc.width = SIZE;
			mc.scaleY = mc.scaleX;
			var pos = getPos(i);
			mc.x = pos.x;
			mc.y = pos.y;
			mc.gotoAndStop(i + 1);
			dm.add(mc, 1);
			vigs.push({mc:mc,id:i});
		}
		//
		cursor = new SP();
		dm.add(cursor, 1);
		cursor.visible = false;
		cursor.graphics.lineStyle(1, 0xFFFFFF);
		cursor.graphics.drawRect(0, 0, SIZE, SIZE);
		Filt.glow(cursor, 2, 200, 0);
		//
		sign = new pix.Element();
		sign.drawFrame(Gfx.inter.get("no_entry"));
		dm.add(sign, 2);
		
		// DEFAULT
		placeSign( World.me.params.noEntry );

	}
	

	var sel:Vig;
	override function update(e) {
		super.update(e);
		var vig = getMouseVig();
		if( vig == null && sel != null ) rollOut();
		if( vig != null && vig != sel ) {
			if( sel != null ) rollOut();
			rollOver(vig);
		}
		
	}
	function getMouseVig() {
		var ss = SIZE * 0.5;
		for( o in vigs ) {
			var dx = o.mc.x + ss - mouseX;
			var dy = o.mc.y + ss - mouseY;
			if( Math.abs(dy) < ss+1 && Math.abs(dx) < ss+1 ) return o;
		}
		return null;
	}
	
	function rollOver(vig:Vig) {
		sel = vig;
		cursor.visible = true;
		cursor.x = sel.mc.x;
		cursor.y = sel.mc.y;
	}
	function rollOut() {
		sel = null;
		cursor.visible = false;
	}

	function placeSign(id:Int) {
		var pos = getPos(id);
		sign.x = pos.x + 8;
		sign.y = pos.y + 8;
	}
	
	function getPos(i) {
		return {
			x: MA * 2 + (SIZE + MA) * (i % COL),
			y: MA*2 + (SIZE + MA) * Std.int(i/COL),
		}
	}

	
	override function click(e) {
		super.click(e);
		if( sel == null ) {
			kill();
			return;
		}
		World.me.params.noEntry = sel.id;
		World.me.saveParams();
		placeSign(sel.id);
	}
	
	
	
//{
}








