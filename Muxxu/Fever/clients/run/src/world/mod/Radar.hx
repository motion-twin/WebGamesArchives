package world.mod;
import Protocole;
import mt.bumdum9.Lib;

class Radar extends world.Mod{//}
	
	static var COLOR_EXPLORE = 	0x008800;
	static var COLOR_BG = 		0x004400;
	
	var skin:pix.Element;
	var map:flash.display.Sprite;
	var mcPoints:flash.display.Sprite;
	var island:world.Island;
	var timer:Int;
	
	public function new() {
		ww = 128;
		hh = 128;
		super();
		timer = 0;
		
		island = World.me.hero.island;
		y -= 27;
		skin = new pix.Element();
		skin.drawFrame(Gfx.mod.get("radar"),0,0);
		dm.add(skin, 0);
		
		
		// MAP
		var map = new flash.display.Sprite();
		dm.add(map, 0);
		map.graphics.beginFill(COLOR_BG);
		map.graphics.drawRect(0, 0, ww, hh);
		
		// MASK
		var msk = new flash.display.Sprite();
		msk.graphics.beginFill(0xFF0000);
		//msk.graphics.drawCircle(0, 0, 56);
		msk.graphics.drawCircle(0, 0, 52);
		msk.x = ww * 0.5;
		msk.y = hh * 0.5;
		dm.add(msk, 0);
		map.mask = msk;
		
		// GRID
		var mc = new flash.display.Sprite();
		mc.blendMode = flash.display.BlendMode.OVERLAY;
		var ec = 4;
		var xmax = Std.int(ww / ec);
		var ymax = Std.int(hh / ec);
		var ddx = 2;
		var ddy = 2;
		mc.graphics.lineStyle(1, 0xFFFFFF, 0.2 );
		for( x in 0...xmax) {
			mc.graphics.moveTo(ddx+x*ec,0);
			mc.graphics.lineTo(ddx+x*ec,hh);
		}
		for( y in 0...ymax) {
			mc.graphics.moveTo(0,ddy+y*ec);
			mc.graphics.lineTo(ww,ddy+y*ec);
		}
		map.addChild(mc);
		
		mcPoints = new flash.display.Sprite();
		map.addChild(mcPoints);
		
		var gfx = map.graphics;
		var ray = 4;
		var max = 1 + 2 * ray;
		for( dx in 0...max ) {
			for( dy in 0...max ) {
				var pp = WorldData.getPos(island.px + dx - ray, island.py + dy - ray);
					
				var status = world.Loader.me.getIslandStatus(pp.x, pp.y);
				//var datas = world.Loader.me.laby.getRoom(px, py);
				var data = WorldData.me.getIslandData(pp.x,pp.y);

				var p = getCenter(dx - ray, dy - ray);
				var rr = 5;
				var ec = 12;
				
				// PATH
				for( di in 0...2 ) {
					var d = Cs.DIR[di];
					var np = WorldData.getPos(pp.x + d[0], pp.y + d[1]);
					var nsta = world.Loader.me.getIslandStatus(np.x, np.y);
					if( !data.walls[di] && (status != ISL_UNKNOWN || nsta != ISL_UNKNOWN) ) {
						var color = COLOR_EXPLORE;
						//gfx.lineStyle(4, color, 1, false, null, flash.display.CapsStyle.SQUARE);
						gfx.lineStyle(4, color, 1);
						var n = 2;
						gfx.moveTo(p.x+d[0]*(rr-n), p.y+d[1]*(rr-n));
						gfx.lineTo(p.x + d[0] * (rr * 2 - n), p.y + d[1] * (rr * 2 - n));
				
					}
				}
				
				// ROOM
				var pmax = data.geo.monsters.length;
				if( data.rew != null ) pmax++;
				var color = 0;
				
				switch(status) {
					case ISL_UNKNOWN :
						 color= 0;
						/*
						 color = COLOR_EXPLORE;
						pmax -= 0;
						// POINTS
						
						var side = 1 + Std.int( Math.sqrt(pmax));
						var ce = -side;
						for( i in 0...pmax ) {
							var po = new flash.display.Sprite();
							po.graphics.beginFill(0x88FF88);
							po.graphics.drawRect(0, 0, 1, 1);
							po.x = ce+p.x + (i % side) * 2;
							po.y = ce+p.y + Std.int(i / side) * 2;
							mcPoints.addChild(po);
						}
						*/
						
					case ISL_EXPLORE(a,rew) :
						color = COLOR_EXPLORE;
						pmax -= a.length;
						// POINTS
						var side = 1 + Std.int( Math.sqrt(pmax));
						var ce = -side;
						for( i in 0...pmax ) {
							var po = new flash.display.Sprite();
							po.graphics.beginFill(0x00FF00);
							po.graphics.drawRect(0, 0, 1, 1);
							po.x = ce+p.x + (i % side) * 2;
							po.y = ce+p.y + Std.int(i / side) * 2;
							mcPoints.addChild(po);
						}
				
					case ISL_DONE :
						color = COLOR_EXPLORE;
				}
				if( color > 0 ) {
					gfx.lineStyle();
					gfx.beginFill(color);
					gfx.drawRect(p.x - rr, p.y - rr, rr * 2, rr * 2);
				}
				
			}
		}
	
		// HERO
		var p = getCenter(0, 0);
		var el = new pix.Element();
		el.drawFrame(Gfx.fx.get("scan_hero"));
		el.x = p.x;
		el.y = p.y;
		map.addChild(el);
		new mt.fx.Blink(el, -1, 8, 4);
		
		// COORDS
		var f = Cs.getField(0x00FF00, 8, -1);
		var mid = Std.int(WorldData.me.size * 0.5);
		f.text = "[" + (island.px - mid) + "][" + (island.py - mid) + "]";
		f.x = Std.int( (ww-f.textWidth) * 0.5) -1;
		f.y = hh - 22;
		addChild(f);
		f.filters = [new flash.filters.GlowFilter(0x004400,1,2,2,40) ];
				
		
	}
	

	public function getCenter(x,y) {
		var ec = 12;
		return { x:ww*0.5+x * ec,	y:hh*0.5+y * ec };
		
	}

	
	override function update(e) {
		super.update(e);
		/*
		timer++;
		if( timer == 24 ) {
			timer++;
			var fx = new mt.fx.Flash(mcPoints);
			fx.glow(3, 4);
			timer = 0;
		}
		*/
	}
	
	override function click(e) {
		super.click(e);
		kill();
	}
	
	
	
//{
}








