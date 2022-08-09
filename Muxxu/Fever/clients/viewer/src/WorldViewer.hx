import Protocole;
import mt.bumdum9.Lib;

class WorldViewer extends flash.display.Sprite{//}
	
	static var EC = 280;	// /320
	
	static var DISPLAY_MONSTERS = 		false;
	
	static var DISPLAY_CHESTS = 		true;
	static var DISPLAY_SMALL_REWARDS = 	false;
	static var DISPLAY_BIG_REWARDS = 	false;
	
	static var DISPLAY_KEYS = 			false;
	static var DISPLAY_HEARTS = 		false;
	static var DISPLAY_CARTRIDGES =		false;
	static var DISPLAY_ITEMS = 			true;
	static var DISPLAY_STATUES = 		false;
	
	static var mcw = 1600;
	static var mch = 900;
	
	var map:flash.display.Sprite;
	
	var grid:Array<Array<flash.display.Sprite>>;
	var work:Array<{x:Int,y:Int}>;
	var mid:Int;
	var lbg:proc.LabyGen;
	var step:Int;
	var icons:Array<pix.Element>;
	var loader:world.Loader;
	var wdata:WorldData;

	
	
	public function new() {
		super();
		flash.Lib.current.addChild(this);
		
		click = false;
		icons = [];
		
		// MAP
		map = new flash.display.Sprite();
		map.scaleX = map.scaleY = 0.5;
		addChild(map);
		
		
		// LOADER
		loader = new world.Loader(0);
		step = 0;
		wdata = loader.wdata;
		// LABY
		/*
		lbg = Common.getLabyGen();
		lbg.launch();
		step = 0;
		*/

		root.addEventListener(flash.events.Event.ENTER_FRAME, update);
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, mouseDown);
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, mouseUp);
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, mouseWheel);
		
	}
	
	
	var rid:Int;
	function update(e) {
		switch(step) {

			
			case 0 :	//  LOADER
				loader.update();
				if( wdata.ready ) {
					loader.hide();
					initExpand();
				}
				
			case 1 :	// EXPAND
			

				var start = Date.now().getTime();
				rid = 0;
				while( Date.now().getTime() - start < 2 ) {
					expand();
					if( work.length == 0 ) {
						step++;
						break;
					}
					
					var a = wdata.links;
					if( a.length > 0 ) {
						var o = a.pop();
						var pa = getIslandPos(o.sx, o.sy);
						var pb = getIslandPos(o.ex, o.ey);
						map.graphics.lineStyle(1, 0xFF0000);
						map.graphics.moveTo(pa.x,pa.y);
						map.graphics.lineTo(pb.x,pb.y);
					}
				}
					

				
				
				
			case 2 :
				
				/*
				for( i in 0...1200 ) {
					var x = rid % WorldData.me.size;
					var y = Std.int(rid/WorldData.me.size);
					var sprite = grid[x][y];
					var p = sprite.localToGlobal(new flash.geom.Point(sprite.x, sprite.y));
					var ray = 0;
					sprite.visible = p.x > -ray && p.y > -ray && p.x < Cs.mcw + ray && p.y < Cs.mcrh + ray;
					
					rid++;
					if( rid == WorldData.me.size * WorldData.me.size ) rid = 0;
				}
				*/
				
		}
		
		for( el in icons ) 	el.scaleX = el.scaleY = Math.max(  1 / map.scaleX, 4 );

		control();
	
	}
		
	function initExpand() {
		step++;
		grid = [];
		for( x in 0...WorldData.me.size ) grid[x] = [];
		mid = Std.int(WorldData.me.size * 0.5);
		work = [ { x:mid, y:mid } ];
		
	}
	function expand() {
		
		var p = work.shift();
		var room = wdata.laby.getRoom(p.x, p.y);
		var color = Col.getRainbow2(room.dif / 100);
		
		var sprite = getOverview( p.x, p.y, color );
		
		var pos = getIslandPos(p.x, p.y);
		sprite.x = pos.x;
		sprite.y = pos.y;
		map.addChild(sprite);
		grid[p.x][p.y] = sprite;
		
		
		// NEI

		for( di in 0...4 ) {
			if( !room.walls[di] ) {
				// NEXT
				var next = getNext( p.x, p.y, di );
				
				//
				if( grid[next.x][next.y] != null ) continue;
				var add = true;
				for( p in work ) {
					if( p.x == next.x && p.y == next.y ) {
						add = false;
						break;
					}
				}
				if( !add ) continue;
				
				work.push(next);
				
				// TRACE
				map.graphics.lineStyle(10, color , 1);
			
				var bx = pos.x ;
				var by = pos.y;
				
				map.graphics.moveTo(bx, by);
				var d = Cs.DIR[di];
				map.graphics.lineTo(bx+d[0]*EC, by+d[1]*EC );
				
			}
		}

	}
	function getIslandPos(x,y) {
		return {
			x : (x - mid) * EC,
			y : (y - mid) * EC,
		}
	}
	function getNext(x, y, di) {

		var d = Cs.DIR[di];
		x += d[0];
		y += d[1];
		
		var k = WorldData.me.size;
		if( x >= k ) x -= k;
		if( y >= k ) y -= k;
		if( x < 0 ) x += k;
		if( y < 0 ) y += k;
		
		return { x:x, y:y };
	}
	
	// GFX
	function getIslandScreenshot(x,y) {
		return null;
		/*
		var room = loader.laby.getRoom(x, y);
		var color = Col.getRainbow2(room.dif / 100));
		
		
		var sprite = new flash.display.Sprite();
		
		var island = new world.Island(x, y, 0, 0, ISL_UNKNOWN, room );
			

		if( grid[x][y] != null ) trace("error");
		
		var bmp = new flash.display.Bitmap();
		bmp.bitmapData = new flash.display.BitmapData(160, 160, true, 0);
		var m = new flash.geom.Matrix();
		m.scale(0.5, 0.5);
		bmp.bitmapData.draw(island, m);

		
		bmp.scaleX = bmp.scaleY = 2;
		
		island.kill();
		bmp.filters = [ new flash.filters.GlowFilter(color,1,8,8,20)];
		bmp.x = -160;
		bmp.y = -160;
		sprite.addChild(bmp);
		
		return sprite;
		*/
			
	}
	function getOverview(x,y, color) {
		
	var idata = wdata.getIslandData(x, y);
		//
		
		//var room = wdata.laby.getRoom(x, y);
		var geo = idata.geo;
		var sprite = new flash.display.Sprite();
		sprite.scaleX = sprite.scaleY = 2;
		sprite.cacheAsBitmap = true;
		//return sprite;
		
		var box = new flash.display.Sprite();
		var side = 32;
		
		// MONSTERS
		if( DISPLAY_MONSTERS ){
			var id = 0;
			var ec = 16;
			var max = Math.ceil(Math.sqrt(geo.monsters.length));
			side = max * ec;
			var ma = -max * ec * 0.5;
			for( mid in geo.monsters ) {
				var el = new pix.Element();
				var data = Data.DATA._monsters[mid];
				var fr = Gfx.monsters.getAnim(data._anim).getCurrentFrame();
				el.drawFrame(fr,0,0);
				el.x = ma + (id%max) * ec;
				el.y = ma +Std.int(id / max) * ec;
				if( fr.height > 16 ) el.y -= fr.height - 16;
				box.addChild(el);
				id++;
			}
		}
		
		// REWARD
		var rew = idata.rew;
		if( rew != null ){
			if( DISPLAY_CHESTS && Common.isChest(rew) ) {
				side = 100;
				color = 0xFF0000;
			}
			
			var displayBig = false;
			switch(rew) {
				case Key : 				displayBig =  DISPLAY_KEYS;
				case Heart : 			displayBig =  DISPLAY_HEARTS;
				case Cartridge(id) : 	displayBig =  DISPLAY_CARTRIDGES;
				case Item(type) : 		displayBig =  DISPLAY_ITEMS;
				case Portal : 			displayBig =  DISPLAY_ITEMS;
				default:
			}
			if( DISPLAY_BIG_REWARDS ) displayBig = true;

			if( displayBig ) {
				var fr = world.ent.Reward.getFrame(rew);
				var el = new pix.Element();
				el.drawFrame(fr);
				box.addChild(el);
				el.scaleX = el.scaleY = 10;
				icons.push(el);
			}
		}
		
		// STATUES
		if( DISPLAY_STATUES && idata.statue > -1 ) {
			var fr = Gfx.world.get("statue");
			var el = new pix.Element();
			el.drawFrame(fr);
			box.addChild(el);
			el.scaleX = el.scaleY = 10;
			icons.push(el);
		}
		
		
		// BG
		var ray = Math.sqrt(Math.pow(side, 2) / 2);
		sprite.graphics.beginFill(color);
		sprite.graphics.drawCircle(0, 0, ray);
		sprite.graphics.endFill();
		
		// REWARD
		if( DISPLAY_SMALL_REWARDS && rew != null ) {
			var el = new pix.Element();
			el.drawFrame( world.ent.Reward.getFrame(rew) );
			el.x = side*0.5;
			el.y = side*0.5;
			box.addChild(el);
			var col = Col.brighten(color, 50);
			sprite.graphics.beginFill(col);
			sprite.graphics.lineStyle(2, color);
			sprite.graphics.drawCircle(side*0.5, side*0.5, 11 );
			sprite.graphics.endFill();
		}
		
		
		
		
		sprite.addChild(box);
		
		
		//
		
		
		
		return sprite;
		
	}
	
	// A BOUGER
	/*
	function getRewardFrame(rew:_Reward) {
	
		switch(rew) {
			case Item(item) :		return Gfx.inter.get( Type.enumIndex(item), "item");
			case IBonus(b) :		return Gfx.inter.get( Type.enumIndex(b), "bonus_island");
			case Heart:				return Gfx.inter.get( 6, "bonus_ground");
			case IceBig:			return Gfx.inter.get( 2, "bonus_ground");
			case Ice:				return Gfx.inter.get( 1, "bonus_ground");
			case Key:				return Gfx.inter.get( 0, "bonus_ground");
			case GBonus(b) :		return Gfx.inter.get( Type.enumIndex(b), "bonus_game");
		}
		return null;
	}
	*/
	
	
	// MOUSE
	var click:Bool;
	var drag: { x:Float, y:Float };
	function mouseUp(e) {
		click = false;
	}
	function mouseDown(e) {
		//if( !click ) onClick();
		click = true;
	}
		
	function control() {
		if( click ) {
			if( drag == null ) drag = { x:map.x-mouseX, y:map.y-mouseY };
			
			map.x = drag.x + mouseX;
			map.y = drag.y + mouseY;
			
		}
		
		
		if( !click && drag != null ) drag = null;
		
	}
	
	function mouseWheel(e:flash.events.MouseEvent) {

		var scale = map.scaleX ;
		var coef = 1+e.delta * 0.05;
		scale *= coef;
		var lim = 0.02;
		if( scale < lim ) scale = lim;
		map.scaleX = map.scaleY = scale;
		
		
		var mx = mcw * 0.5;
		var my = mch * 0.5;
		
		var dx = map.x - mx;
		var dy = map.y - my;
		map.x = mx + dx * coef;
		map.y = my + dy * coef;
		
	}
	
	
//{
}














