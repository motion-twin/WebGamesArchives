package world;
import mt.bumdum9.Lib;
import Protocole;
import proc.Laby;

class Island extends flash.display.Sprite{//}
	
	public static var XMAX = 32;
	public static var YMAX = 32;
	public static var SIZE = 16;
	
	public static var DP_BUTS = 		10;
	public static var DP_FX = 			5;
	public static var DP_ELEMENTS = 	4;
	public static var DP_WAVES = 		3;
	public static var DP_GROUND = 		2;
	public static var DP_UNDERGROUND =	1;
	public static var DP_BG = 			0;
	
	public var px:Int;
	public var py:Int;
	
	var forceFlat:Bool;
	
	var elements:Array<IslandElement>;
	var feverHeads:Array<FeverHead>;
	
	public var seed:mt.Rand;
	public var grid:Array<Array<Square>>;
	public var squares:Array<Square>;
	var work:Array<Square>;
	
	public var monsters:Array<world.ent.Monster>;
	public var statueSquare:Square;

	public var data:IslandData;
	
	var butterflyFreq:Int;
	var win:Array<Int>;
	var winAll:Bool;
	public var ocean :Array<Square>;
		
	public var selector:pix.Sprite;
	public var activeSquare:Square;
	public var respawn:Square;
	
	public var zone:Array<Square>;
	public var dm:mt.DepthManager;
	
	public function new(x, y ) {
		super();
		
		px = x;
		py = y;
		seed = new mt.Rand(getSid());
				
		monsters = [];
		ocean = [];
		
		// STATUS
		win = [];
		winAll = false;
		

		var status = getStatus();
		switch(status) {
			case ISL_DONE :			winAll = true;
			case ISL_UNKNOWN :
			case ISL_EXPLORE(a,rew) :	for( n in a ) win.push(n);
		}
				
		
		// PROPS
		forceFlat = false;
		data = WorldData.me.getIslandData(px, py);

		//
		dm = new mt.DepthManager(this);
		
		initGrid();
		
		// GENERATION
		gen();
		butterflyFreq = 1 + Std.int( Math.pow(seed.rand(), 0.5)*70 );
		
		// NETTOYAGE
		if( winAll ) {
			for( sq in zone ) sq.win = true;
		}else {
			for( id in win ) zone[id].win = true;
		}
		
		for( sq in squares ) sq.majRealNeighbours();
		
		genElements();
		drawAll();
		genMonsters();
		
		for( sq in squares ) sq.majRealNeighbours();

		// SbutterflyFreqLECTOR
		selector = new pix.Sprite();
		selector.setAnim(Gfx.world.getAnim("selector"));
		dm.add(selector, DP_BUTS);
		selector.visible = false;
		Col.setPercentColor( selector, 1 , 0xFFFFFF);
		selector.visible = false;
		
		// INIT
		new fx.CheckIslandGrow(this);
		ssortElements();
		

		if( isSafe() ) onComplete();

	}
	public function getStatus() {
		return Loader.me.getIslandStatus(px, py);
	}
	
	
	public function getSid() {
		return px*WorldData.me.size + py;
	}
	function getSquare(id) {
		return zone[id];
	}
	
	function initGrid() {
		grid = [];
		squares = [];
		for( x in 0...XMAX ) {
			grid[x] = [];
			for( y in 0...YMAX ) {
				new Square(x, y, this);

			}
		}
		
		// NEIGHBOURS
		for( sq in squares ) {
			for( d in Cs.DIR ) {
				var nx = sq.x  + d[0];
				var ny = sq.y + d[1];
				if( isIn(nx, ny) ) {
					var n = grid[nx][ny];
					sq.nei.push( n );
					sq.dnei.push( n );
				}else {
					sq.dnei.push(null);
				}
			}
		}
	}
	function isIn(x,y) {
		return x >= 0 && x < XMAX && y >= 0 && y < YMAX;
	}
	
	// GENERATION A
	function gen() {

		//
		work = [];
		
		// INIT
		for( sq in squares ) {
			sq.floor = 0;
			sq.type = 0;
			sq.score = 0;
			sq.a = 0;
		}
		
		// BASE
		var mid = grid[Std.int(XMAX * 0.5)][Std.int(YMAX * 0.5)];
		paintSq(mid);
		for( i in 0...data.geo.size ) expand();
		
		// FIRST RAISE
		work = [];
		for( sq in squares ) if( sq.type == 1 ) work.push(sq);
		raise(1);
		
		// SECOND RAISE
		var max = 2;
		for( i in 0...max ) {
			var a = getUpRect( work );
			if( true ) {
				for( sq in work ) 	sq.score = 0;
				for( sq in a ) 		sq.score = 1;
				var b = getUpRect( work );
				for( sq in b )		if(sq.score == 0 ) a.push(sq);
			}
			work = a;
			raise(2+i);
		}
		
		
		// ZONE
		zone = [];
		var id = 0;
		for( sq in squares ) if( sq.type == 1 ) {
			zone.push(sq);
			sq.id = id;
			for( i in 0...3 ) sq.ints.push( seed.random(10000));
			id++;
		}
		
		// CHECK
		if( !checkLevel() ) gen();
		
	}
	function expand() {
		
		// SCORES
		for( sq in work ) {
			sq.score = 0;
			var di = 0;
			for( n in sq.nei ) {
				if(n.type == 1 ) sq.score += [4, 3, 4, 3][di];
				di++;
			}
		}
		work.sort(sortByScore);
		
		var index = Std.int(Math.pow(seed.rand(), 3) * work.length);
		var sq = work[index];
		work.splice(index, 1);
		
		paintSq(sq);

		
	}
	function paintSq(sq:Square) {
		sq.type = 1;
		for( n in sq.nei ) if( n.a == 0 ) {
			n.a = 1;
			work.push(n);
		}
	}
	function sortByScore(a:Square,b:Square) {
		if( a.score > b.score ) return -1;
		return 1;
	}
	function raise(f) {
		var a = [];
		
		// ALL CLIFF
		for( sq in work ) {
			sq.type = 2;
			sq.floor = f - 1;
		}
		
		// UP ALL
		for( sq in work ) {
			if( sq.y == 0 ) return;
			var usq = grid[sq.x][sq.y - 1];
			a.push(usq);
			usq.type = 1;		// HERE
			usq.floor = f;
		}
		
		// LADDER
		for( sq in a ) 	work.remove(sq);
		var b = work.copy();
		for( sq in b ) {
			var bot = sq.dnei[1];
			if( bot != null ) {
				if( bot.type == 3 ) {
					work = [sq];
					break;
				}
				if( bot.type != 1 )	work.remove(sq);
			}
		}
		if( work.length > 0 && f > 1 ){
			var sq = work[seed.random(work.length)];
			sq.type = 3;
		}
		
		//
		work = a;

	}
	function getZoneBounds(a:Array<Square>) {
		var box = {	xMin:99,	yMin:99,	xMax: -99,	yMax: -99 };
		
		
		for( sq in a ) {
			if( sq.x  < box.xMin )	box.xMin = sq.x;
			if( sq.x  > box.xMax )	box.xMax = sq.x;
			if( sq.y < box.yMin ) 	box.yMin = sq.y;
			if( sq.y > box.yMax ) 	box.yMax = sq.y;
		}
		return box;
	}
	function getUpRect(a:Array<Square>) {
		var box = getZoneBounds(a);
		
		var width = box.xMax - box.xMin;
		var height = Std.int((box.yMax - box.yMin) * (0.1+seed.rand()*0.5));
		
		var mx = seed.random(width-1);
		//var mx = Std.int(width * 0.75);
		width -= mx;
		var start = seed.random(mx);
		

		box.xMin += start;
		box.xMax -= mx;
		box.yMax = box.yMin + height;
		
		var b = [];
		for( sq in a ) {
			if( sq.x >= box.xMin && sq.x<= box.xMax && sq.y >= box.yMin && sq.y <= box.yMax )
				b.push(sq);
		}
		
		return b;
		
		
		
	}
	function checkLevel() {
		
		for( i in 0...2){
			for( sq in squares ) sq.majRealNeighbours();
			for( sq in squares ) sq.score = 0;
			
			work = [zone[0]];
			while(work.length > 0) explore();
			
			var a = [];
			for( sq in zone ) if( sq.score == 0 ) a.push(sq);
			if( a.length > 0 ){
				if( i == 0 ) linkZone(a);
				if( i == 1 ) {
					/*
					for( sq in squares ) {
						if( sq.type == 0 || sq.score != 0 ) continue;
						var sp = new pix.Element();
						dm.add(sp, 10);
						sp.drawFrame(Gfx.world.get(3),0,0);
						sp.x = sq.x * 16;
						sp.y = sq.y * 16;
						sp.alpha = 0.5;
					}
					*/
					
					return false;
				}
			}
		
		}
		return true;
		
		
	}
	function explore() {
		var sq = work.shift();
		sq.score = 1;
		for( nsq in sq.rnei ) {
			if( nsq.score == 1 ) continue;
			work.push(nsq);
		}

	}
	function linkZone(a:Array<Square>) {
		for( sq in zone ) sq.score = 2;
		for( sq in a ) sq.score = 1;
		
		for( sq in a ) {
			for( i in 0...2 ) {
				var di = [1, 3][i];
				var nsq = sq.dnei[di];
		
				if( nsq != null && nsq.floor > 0 && nsq.type == 2 ) {
					var nsq2 = nsq.dnei[di];
					if( nsq2 != null && nsq2.score == 2 ) {
						nsq.type = 3;
						return true;
					}
				}
			}
		}
		return false;
	}
		
	// GENERATION B
	function genElements() {
		
		// JUMP STONE
		for( di in 0...4 ) {
			if( !data.walls[di] ){
				var box = getZoneBounds(zone);
				var a = [];
				var k = 0;
				while( a.length == 0 ){
					for( sq in zone ) {
						var ok = false;
						switch(di) {
							case 0 :	ok = sq.x == box.xMax-k;
							case 1 :	ok = sq.y == box.yMax-k;
							case 2 :	ok = sq.x == box.xMin+k;
							case 3 :	ok = sq.y == box.yMin+k;
						}
						if( sq.ent != null ) ok = false;
						if( ok ) a.push(sq);
					}
					k++;
				}
				
				
				var sq = a[seed.random(a.length)];
				new world.ent.JumpStone( this, sq, di);
			}
		}
		
		// BONUS
		genBonus();
		
		// GFX ELEMENTS
		for( sq in zone ) {
			if( sq.ent != null ) continue;
			for( type in 0...2 ) {
				
				
				switch(type) {
					case 0 :
						if( seed.random(24) == 0 ) 		sq.addElement(type,"elements_dirt_medium", seed.random(5), 4);
						else if( seed.random(8) == 0 ) 	sq.addElement(type,"elements_dirt_small", seed.random(8), 8);
						
					case 1 :
						for( i in 0... 3 ) 				sq.addElement(type,"elements_grass_medium", seed.random(5), 7);
				}
				

			}
		}
		
		
		
	}
	function genBonus() {
		var rew = data.rew;
		if( rew == null ) return;
		
		//PORTAL
		if( rew == Portal ) {
			new world.ent.Portal(this,zone[8]);
			return;
		}
		
		// NORMAL
		var sq = getCornerSquare();
		new world.ent.Reward(this, sq, rew );
		
		// STATUE
		if( data.statue >= 0 ) statueSquare = getWideSquare();
		
	}
	function genMonsters() {
		#if dev
		if( Cs.NO_MONSTER ) return;
		#end
		
		// SQUARE LIST
		var a = [];
		for( sq in zone ) {
			sq.score = 0;
			if( sq.ent == null ) a.push(sq);
		}
		
		// SQUARE SCORES
		for( sq in a ) {
			for( nsq in sq.dnei ) {
				sq.score += seed.random(3);
				if( nsq.ent != null ) {
					sq.score += nsq.ent.getProtectValue();
				}
			}
		}
		
		Arr.shuffle(a, seed);
		a.sort(sortByScore);
		
		var b = [];
		for( mid in data.geo.monsters ) {
			var sq = a.shift();
			b.push(sq);
			for( nsq in sq.dnei ) nsq.score-=2;
			a.sort(sortByScore);
			if( a.length == 0 ) break;
		}
		
		for( mid in data.geo.monsters ) {
			var sq = b.shift();
			if( sq.win ) continue;
			var mon = new world.ent.Monster(this, sq, mid );
			if( b.length == 0 ) break;
		}
		
		// PORTAL : SARGON
		if( data.rew == Portal && world.ent.Portal.me.pow == Data.RUNE_MAX ) 	new world.ent.Monster(this, world.ent.Portal.me.sq.dnei[1], 11 );
	
	
		// STATUE
		displayStatue(false);
			
	}
	
	// GENERATION TOOLS
	function getCornerSquare() {
		var a = [];
		for( sq in zone ) {
			if(sq.ent != null || sq.type != 1 ) continue;
			a.push(sq);
		}
		Arr.shuffle(a, seed );
		var f = function(a:Square, b:Square) {
			if( a.rnei.length < b.rnei.length ) return -1;
			return 1;
		}
		a.sort(f);
		return a[0];
	}
	function getWideSquare() {
		var a = [];
		for( sq in zone ) if( sq.isWide() ) a.push(sq);
		if( a.length == 0 ) return null;
		return a[seed.random(a.length)];
		
	}
	
	
	
	// SORT
	public function ssortElements() {
		dm.ysort(DP_ELEMENTS);
	}

	// DRAW
	var ground:flash.display.Sprite;
	public var grass:flash.display.Bitmap;
	public var dirt:flash.display.Bitmap;
	public var dirtMask:flash.display.Sprite;
	function drawAll() {
		ground = new flash.display.Sprite();
		dm.add(ground, DP_GROUND);
		
		dirt = new flash.display.Bitmap();
		grass = new flash.display.Bitmap();
		
		var dirtBox = new SP();
		dirtBox.addChild(dirt);
		ground.addChild(grass);
		ground.addChild(dirtBox);
						
		dirt.bitmapData = getMap(0);
		grass.bitmapData = getMap(1);
		
		dirtMask = new flash.display.Sprite();
		dirtBox.addChild(dirtMask);
		dirt.mask = dirtMask;
		
		// LAG SI BCP DE MONSTRE
		Filt.glow(dirtBox, 3, 1, 0x440000, true);
		
		
		
	}
	function getMap(style) {

		var map = new flash.display.BitmapData(XMAX * SIZE, YMAX * SIZE, true, 0);
		for( sq in squares ) {
			
			switch(sq.type ) {
				case 0:
				case 1:
					var n = 0;
					var id = 1;
					for( nsq in sq.dnei ) {
						if( nsq != null && (nsq.type == 1 || nsq.type == 2) && nsq.floor >= sq.floor) 	n += Std.int(Math.pow(2, id));
						id = (id+1)%4;
					}
					var fr = Gfx.world.get( n, (style==0)?"dirt":"grass" );
					fr.drawAt(map, sq.x * SIZE, sq.y * SIZE);
					sq.score = n;
					
				case 2, 3:
					if( style == 1 ){
						sq.score = sq.dnei[3].score;
						var fr = Gfx.world.get( sq.score, "cliff" );
						if( sq.floor == 0 ) {
							for( i in 0...2 ){
								var el = new pix.Element();
								el.drawFrame(fr,0,0);
								el.x = sq.x * 16;
								el.y = (sq.y+i) * 16;
								dm.add(el, DP_BG);
							}
							continue;
						}
						
						fr.drawAt(map, sq.x * SIZE, sq.y * SIZE);
						
		
						// LADDER
						if( sq.type == 3 ) {
							var ladder = Gfx.world.get( "ladder" );
							ladder.drawAtWithAlpha( map,sq.x* SIZE, sq.y * SIZE);
						}
						
					}
					
				default :
					var fr = Gfx.world.get( sq.type );
					fr.drawAt(map, sq.x * SIZE, sq.y * SIZE);
			}
			
			

		}
		
		return map;
		
	}
	
	// UPDATE
	public function update() {
		
		
		if( monsters.length > 0 && Std.random(10) == 0 ) {
			var mon = monsters[Std.random(monsters.length)];
			mon.playRandomAnim();
		}
		
		// HEADS
		for( h in feverHeads ) h.update();
		
		updateOcean();
	}
	
	// TOOLS

	public function mapDistanceFrom(sq:Square) {
		for( sq in squares ) sq.score = -1;
		sq.score = 0;
		work = [sq];
		while(work.length > 0 ) {
			var sq = work.shift();
			for( nsq in sq.rnei ) {
				if( nsq.score > -1 ) continue;
				nsq.score = sq.score + 1;
				if( nsq.isBlock() ) {
					nsq.score = nsq.isTrig()?99:-1;
					
				}else {
					work.push( nsq );
				}
			}
			//mark(sq);
		}

		//for(sq in squares ) if( sq.isWalkable() ) sq.mark();
	}
	public function seekJumpStone(dir) {
		for( sq in zone ) {
			if( sq.ent == null ) continue;
			switch( sq.ent.type ) {
				case EJumpStone(di) : if( di == dir ) return sq;
				default :
			}
		}
		return null;
	}

	
	// OCEAN
	public function attachOcean() {
		
		var bot = 0;
		for( sq in zone ) if(sq.y > bot ) bot = sq.y;
		
		
		// HEADS
		feverHeads = [];
		var seed = new mt.Rand(getSid());
		seed.random(2000);
		var max = 12 + seed.random(50);
		//var max = 850 + seed.random(8);
		//var max = 0;
		for( i in 0...max ) {
			var x = seed.random(XMAX-1);
			var y = seed.random(YMAX);
			var sq = grid[x][y];
			if( sq.type != 0 ) continue;
			var ok = true;
			for( dx in -2...2 ) {
				for( dy in -4...4 ) {
					var nx = x + dx ;
					var ny = y + dy ;
					if( isIn(nx, ny) ) {
						var nsq = grid[nx][ny];
						if( nsq.feverHead != null || nsq.type != 0 ) {
							ok = false;
							break;
						}
					}
				}
			}
			if( !ok ) continue;
			
			var h = new FeverHead(this, sq, seed);
			dm.add(h, DP_BG);
			feverHeads.push(h);
		}
		
		// WAVES
		for( x in 0...XMAX ) {
			for( y in 0...YMAX ) {
				var sq = grid[x][y];
				if( sq.type != 0 ) continue;
				ocean.push(sq);
				var el = getWave(sq);
				var up = grid[x][y - 1];
				/*
				if( up != null && ( up.type != 0 || up.feverHead !=null ) ) {
					var front = getWave(sq);
					front.drawFrame(Gfx.world.get(1,"waves_3"),0,2);
					dm.add(front, DP_WAVES);
				}
				*/
				/*
				if( grid[x][y+1] != null && grid[x][y+1].type!=0 ) {
					var border = new pix.Element();
					border.drawFrame(Gfx.world.get(2,"waves_3"),0,0);
					border.y = 16;
					el.addChild(border);
				}
				*/
				dm.add(el, DP_BG);
			}
		}
		
		

		
		//
		dm.ysort(DP_BG);
		paintOcean(true);
		
	}
	function getWave(sq) {
		var el = new pix.Element();
		el.drawFrame(Gfx.world.get("waves_3"),0,0);
		//el.drawFrame(Gfx.world.get(Std.random(3),"clouds"),0,0);
		el.x = sq.x * 16;
		el.y = sq.y * 16;
		sq.pushOcean(el);
		
		return el;
	}
	
	public static function getSynchro(x,y) {
		return (x * 2 + y);
	}
	public function paintOcean(init=false) {
		
		var mc = new McMiniGradient();
		var bmp = new flash.display.BitmapData(XMAX, YMAX, false, 0);
		
		for( mon in monsters ) {
			var m = new flash.geom.Matrix();
			m.scale(2, 2);
			m.translate(mon.sq.x+2, mon.sq.y);
			bmp.draw(mc,m);
		}
		for( x in 0...XMAX ) {
			for( y in 0...YMAX ) {
				var c = 1-bmp.getPixel(x, y) / 0xFFFFFF ;
				var sq =  grid[x][y];
				if( sq.oceans != null ) {
					if( sq.feverHead != null ) 	sq.feverHead.setSink(c);
					sq.setSwell(1 - c, init);
				}
			}
		}
		bmp.dispose();
		

		
	}
	
	public function updateOcean() {
		var speed = 40;
		var dec = (World.me.timer % speed) / speed;
		for( sq in ocean ) {
			sq.updateSwell();
			var freq = 48 - sq.swell * 24;
			var c = (getSynchro(sq.x, sq.y)%freq) / freq + dec;
			for(oc in sq.oceans ) {
				//if( sq.x == 0 && sq.y == 0 ) trace(Math.cos(c * 6.28) ) ;
				var amp = 1+sq.swell * 7;
				oc.y = sq.y * 16 + Math.round( Math.cos(c * 6.28) * amp );
			}
		}
	}
	
	// ONKILL MONSTER
	public function onDestroyMonster() {
		paintOcean();
		if( isSafe() ) {
			onComplete();
			displayStatue(true);
		}
		
	}
	public function onComplete() {
		spawnButterflies();
		for( sq in zone ) if( sq.ent != null ) sq.ent.onComplete();
		
	}
	
	function displayStatue(anim:Bool) {
		//trace("[" + px + ";" + py + "] displayStatue(" + anim + ")");
		if( monsters.length > 0 || statueSquare == null ) return;
		
		var ent = new world.ent.Statue( this, statueSquare,data.statue);
		if( anim ) {
			//trace("!");
			new fx.SpawnStatue(ent);
		}
		
	}
	
	//
	public function isSafe() {
		return monsters.length == 0;
	}
	
	
	// BUTTERFLIES
	public function spawnButterflies() {
		var colors = 10;
		for( sq in zone ) if( sq.isWalkable() && sq.ints[0] % butterflyFreq == 0 ) new world.gfx.Butterfly(this,sq,(sq.ints[1]%colors)/colors);
	
	}
	
	// ON

	
	
	// INTERFACE
	public function rollOver(x, y) {
		if(!isIn(x, y)) return;
		var sq = grid[x][y];
		if( activeSquare == sq ) return;
		unselectSquare();
		selectSquare(sq);
	}
	function selectSquare(sq:Square) {
		selector.x = (sq.x + 0.5) * 16;
		selector.y = (sq.y + 0.5) * 16;
		
		selector.visible = sq.isReachable();
		activeSquare = sq;
		
		Col.setPercentColor(selector, 1, 0xFFFFFF);
		
	
	}
	function unselectSquare() {
		if( selector !=null ) selector.visible = false;
		activeSquare = null;
	}
	
	// GET
	public function get(x, y) {
		if( !isIn(x, y) ) return null;
		return grid[x][y];
	}
	public function getName() {

		return Lang.ISLAND+" ["+Std.int(px-WorldData.me.size*0.5)+","+Std.int(py-WorldData.me.size*0.5)+"]";
	}
	public function getNextIslandPos(di) {
		var d = Cs.DIR[di];
		var nx = px + d[0];
		var ny = py + d[1];
		nx = Std.int( Num.sMod(nx, WorldData.me.size));
		ny = Std.int( Num.sMod(ny, WorldData.me.size));
		return { x:nx, y:ny };
	}
	
	// KILL
	public function kill() {
	
		if( selector != null ) selector.kill();
		while( monsters.length > 0 ) monsters.pop().kill();
		
		dirt.bitmapData.dispose();
		grass.bitmapData.dispose();
		
		
		if( parent != null ) parent.removeChild(this);
		
		mt.flash.Gc.run();	}
	

	
//{
}








