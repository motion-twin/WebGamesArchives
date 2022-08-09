import Protocole;
import mt.bumdum9.Lib;
import proc.Laby ;


typedef RoomData = { room:LabyRoom, geo:IslandGeo, x:Int, y:Int, uid:Int };
typedef RoomOverload = { rew:_Reward, statue:Int };

enum LoadStep {
	GEN_LABY;
	GEN_KEYS;
	GEN_END;
}


class WorldData {//}

	public static var COEF_PORTAL = 0.077;

	public var size:Int ;

	var lbg:proc.LabyGen ;
	public var laby:proc.Laby ;
	var overload:Array < Array < RoomOverload >> ;
	var step:LoadStep;
		
	var chest:Array<{x:Int,y:Int}>;
	var seed:mt.Rand;
	var runId:Int;
	var kstep:Int;
	public var rooms:Array<RoomData>;
	public  var statues:Array<RoomData>;
	
	public var wid:mt.flash.Volatile<Int>;
	public var ready:Bool;
	public var links:Array<{sx:Int,sy:Int,ex:Int,ey:Int}>;
	public static var me:WorldData;
	
	
	public function new(wid) {
		me = this;
		this.wid = wid;
		size = 100 + wid * 20;
	}
	
	public function init() {
		ready = false;
		step = GEN_LABY;
		
		lbg = new proc.LabyGen(WorldData.me.size, WorldData.me.size, 0 );
		lbg.snakeCoef = 0;
		lbg.lock = 10;
		lbg.loopX = true;
		lbg.loopY = true;
		var mid = Std.int(WorldData.me.size * 0.5);
		lbg.startPos = { x:mid, y:mid };
		lbg.breakLimit = 100;
		
		lbg.launch();
	}
	
	public function update() {
		
		switch(step) {
			
			case GEN_LABY :
				lbg.update();
				if( lbg.ready ) {
					laby = new proc.Laby(lbg);
					initKeyGenerator();
				}
			
			case GEN_KEYS :
				updateKeyGenerator();
				
			case GEN_END:

			
		}
		
	}
	
	function initKeyGenerator() {
		step = GEN_KEYS;
		seed = new mt.Rand(33+wid);
				
		rooms = [];
		overload = [];
		runId = 0;
		kstep = 0;
		links = [];
		
		for( x in 0...WorldData.me.size ) {
			overload[x] = [];
			for ( y in 0...WorldData.me.size ) {
				if( wid > 0 ){
					var room = laby.getRoom(x, y);
					room.dif += wid * 10;
				}
				overload[x][y] = { rew:null, statue:-1 };
			}
		}
		
	}
	function updateKeyGenerator() {
		
		switch(kstep) {
			case 0:

				for( i in 0...800 ) {
					checkLaby();
					if( runId == Math.pow(WorldData.me.size, 2) ) {
						addCustomRewards();
						buildChestList();
						kstep++;
						break;
					}
				}
				
			case 1:
	
				for( i in 0...61 ) {
					if( chest.length == 0 ) {
						end();
						break;
					}
					placeNextKey();
				}
					
		}
		

		
	}

	function checkLaby() {
		var size = WorldData.me.size;
		var x = runId % size;
		var y = Std.int(runId/size);
		var room = laby.getRoom(x, y);
		var geo = getIslandGeo(x, y, room);
		overload[x][y].rew = geo.nativeReward;
		rooms.insert(seed.random(rooms.length), { room:room, geo:geo, x:x, y:y, uid:runId } );
		runId++;
	}
	
	public function addCustomRewards() {
		
		// HEARTS && CARTRIDGES;
		var f = function(a:RoomData, b:RoomData) {
			if( a.room.dif < b.room.dif ) return -1;
			if( a.room.dif == b.room.dif ) {
				if( a.uid < b.uid ) return -1;
				return 1;
			}
			return 1;
		}
		rooms.sort(f);
		var difMax = rooms[rooms.length-1].room.dif;
	
		// HEARTS
		var max = Data.EXTRA_HEARTS*4;
		var hearts = [];
		for( i in 0...max ) {
			var c = Math.pow(i / max, 2.5);
			hearts.push( c );
		}
		
		// CARTRIDGES
		var cartridges = [];
		for( i in 0...Data.CARTRIDGE_MAX ) {
			var c = Math.pow(i / Data.CARTRIDGE_MAX, 1.5);
			var start = 0.03;
			c = start + c * (1 - start);
			cartridges.push( c );
		}
		
		// ITEMS
		var max = 21;
		var items = [];
		var cons = Type.getEnumConstructs(_Item);
		for( id in 0...max ) items.push( { type:Type.createEnum(_Item, cons[id]), dif:Data.ITEMS_POS[id] } );
		var f = function(a:{type:_Item,dif:Float}, b:{type:_Item,dif:Float}) {
			if( a.dif < b.dif ) return -1;
			if( a.dif == b.dif ) trace( "items dif equal error ! ("+a.dif+")" );
			return 1;
		}
		items.sort(f);
		
		// RUNES
		var rmax = 7;
		var runes = [];
		for( i in 0...rmax ) runes.push( { dif:(i / rmax) + seed.rand() * 0.035, type:[Rune_5, Rune_1, Rune_0, Rune_2, Rune_4, Rune_6, Rune_3][i] } );
		var runepos = [];
		
		// PORTAL
		var room = rooms[ Std.int(rooms.length * COEF_PORTAL) ];
		overload[room.x][room.y].rew = Portal;
		
		// STATUES
		var statueCoefs = [];
		for( i in 0...Data.STATUE_MAX )statueCoefs.push( (i / Data.STATUE_MAX) + seed.rand() * 0.024 );
			
		// ----------------------------------------------------------- //
		
		statues = [];
		for( id in 0...rooms.length ) {
			var room = rooms[id];
			var ov = overload[room.x][room.y];
			if( room.geo.wallSum < 3 || Common.isChest(ov.rew) ) continue;
			var coef = id / rooms.length;
			
			if( statueCoefs.length > 0 ) {
				if( coef > statueCoefs[0] ) {
					var add = true;
					for( o in statues ){
						var dx = o.x - room.x;
						var dy = o.y - room.y;
						if( Math.abs(dx) + Math.abs(dy) < 24) {
							add = false;
							break;
						}
					}
					if( add ){
						//ov.statue = Data.STATUE_MAX-(statues.length+1);
						ov.statue = statues.length;
						statueCoefs.shift();
						statues.push(room);
					}
				}
			}
			
			if( runes.length > 0 ) {
				if( coef > runes[0].dif  ) {
					var ec = 2 + Std.int(40 * coef);
					var add = true;
					for( p in runepos ) {
						var dx = Math.abs(room.x-p.x);
						var dy = Math.abs(room.y - p.y);
						if( Math.abs(dx) < ec && Math.abs(dy) < ec ) {
							add = false;
							break;
						}
					}
					if( add ){
						ov.rew = Item(runes[0].type);
						runes.shift();
						runepos.push( { x:room.x, y:room.y } );
						continue;
					}
				}
			}
			
			if( items.length > 0 ) {
				if( coef > items[0].dif  ) {
					ov.rew = Item(items[0].type);
					items.shift();
					continue;
				}
			}
			
			if( hearts.length > 0 ) {
				//room.room.dif
				if( coef > hearts[0] ) {
					ov.rew = Heart;
					hearts.shift();
					continue;
				}
			}
			
			if( cartridges.length > 0 ){
				if( coef > cartridges[0]  ) {
					ov.rew = Cartridge(Data.CARTRIDGE_MAX-cartridges.length);
					cartridges.shift();
					continue;
				}
			}
	
		}
			
	}
	
	function buildChestList() {
		
		// CHEST
		chest = [];
		for( room in rooms ) {
			var rew = overload[room.x][room.y].rew;
			if( Common.isChest(rew) ) chest.push( { x:room.x, y:room.y } );
		}
		

	}
	function placeNextKey() {
		
		var pos = chest.pop();
		var chestRoom = laby.getRoom(pos.x, pos.y);
		
		var ray = 4;
		var max = ray * 2 + 1;
		var a = [];
		
		for( dx in 0...max ) {
			for( dy in 0...max ) {
				var p = getPos(pos.x + dx - ray, pos.y + dy - ray);
				var rew = overload[p.x][p.y].rew;
				var room = laby.getRoom(p.x, p.y);
				
				var ddif = Math.abs(room.dif - chestRoom.dif);
				var score = Math.abs(ddif - 3);
				
				if( rew == null )						score += 10;
				else if( Common.isChest(rew) || rew == Key ) 	score += 1000;
				
				
				a.push({ x:p.x, y:p.y, score:score });
				
				//if( !isChest(rew) && rew != Key ) a.push( { x:nx, y:ny, room:laby.getRoom(nx, ny) } );
			}
		}
		
		var  f = function(a:{ x:Int, y:Int, score:Float }, b:{ x:Int, y:Int, score:Float }) {
			if( a.score < b.score ) return -1;
			if( a.score == b.score ) {
				var aa = a.x * 100 + a.y;
				var bb = b.x * 100 + b.y;
				if( aa < bb ) return -1;
				return 1;
			}
			return 1;
		}
		
		Arr.shuffle(a,seed);
		a.sort(f);
		
		var first = a[0];
		overload[first.x][first.y].rew = Key;
		

		
	}
	
	function end() {
		step = GEN_END;
		ready = true;
	}
	
	// GEO
	static function getIslandGeo(x, y, room:LabyRoom ) {
		
		var seed = new mt.Rand(x * WorldData.me.size + y);
		
		for( i in 0...3 ) seed.rand();
		
		// SIZE
		var dx = x - WorldData.me.size*0.5;
		var dy = y - WorldData.me.size*0.5;
		var dist = Math.abs(dx) + Math.abs(dy);
		var coef = dist / WorldData.me.size;
		var size = Std.int( ( 20 + coef * 40 ) * (0.75+seed.rand()*0.5) );
		
		// MONSTERS - MAX
		var cm = 0.5 + (seed.rand() * 2 - 1) * 0.2;
		cm -= 0.3 * Math.max( 1 - coef * 5, 0);
		var monsterMax = Std.int( size * cm );
		if( monsterMax < 1 ) monsterMax = 1;
		
		// MONSTERS - WEIGHT
		var a  = [];
		var sum = 0;
		for( data in Data.DATA._monsters ) {
			var mid = (data._rangeTo + data._rangeFrom) * 0.5;
			var ray = (data._rangeTo - data._rangeFrom) * 0.5;
			var c = 1 - Math.abs(room.dif - mid) / ray;
			var w = Std.int(Num.mm(0, c, 1) * data._weight);
			if( room.dif > data._rangeTo ) w = 2;
			a.push( { id:data._id, weight:w });
			sum += w;
		}
		
		// MONSTERS - DRAW
		var monsters = [];
		for( i in 0...monsterMax ) {
			var rnd = seed.random(sum);
			var n = 0;
			var mid = 0;
			for( o in a ) {
				n += o.weight;
				if( n > rnd ) {
					monsters.push(o.id);
					break;
				}
			}
		}
		
		// REWARDS
		var reward:_Reward = null;
		var wallSum = 0;
		for( di in 0...4 ) if( room.walls[di] )wallSum++;
		
		
		
		if( seed.random([0,100,10,1][wallSum]) == 0 ) {
			if( seed.random(5) == 0 ) {
				var rnd = seed.random(12);
				switch(rnd) {
					case 0, 1, 2, 3, 4 : 	reward = Ice;
					case 5, 6, 7 : 			reward = IBonus(Volt);
					case 8, 9 :				reward = IBonus(Tornado);
					case 10 :				reward = IBonus(Fireball);
					case 11 :				reward = IceBig;
				}
								
			}else {
				var rnd = seed.random(10);
				switch(rnd) {
					case 0, 1, 2, 3, 4, 5 : 	reward = GBonus(Leaf);
					case 6, 7, 8 :				reward = GBonus(Knife);
					case 9 :					reward = GBonus(Cheese);

				}
			}
		}

		//
		var o:IslandGeo = { size:size, monsters:monsters, nativeReward:reward, wallSum:wallSum };
		
		
		
		return o;
	}
	
	// TOOLS
	public function getIslandData(x, y) {
		var room = laby.getRoom(x, y);
		var dif = Math.min(room.dif / 100,1);
		var geo = getIslandGeo(x, y, room );
		var ov = overload[x][y];
		var walls = room.walls.copy();
		var data:IslandData = {	geo:geo, dif:dif, walls:walls, rew:ov.rew, statue:ov.statue };

		// PORTAIL
		if( data.rew == Portal ) {
			//trace("!!");
			data.geo.monsters = [];
			dif = 1;
			geo.size = 29; //22, 27, 28
		}
		
		// START
		if( x == Std.int(WorldData.me.size*0.5) && y == Std.int(WorldData.me.size*0.5) ) {
			data.geo.monsters = [0, 0];
			data.geo.size = 60;
		}
		
		return data;
	}
	public function getLimits() {
		var a  = [];
		for( x in 0...WorldData.me.size ) {
			for( y in 0...WorldData.me.size ) {
				var data = getIslandData(x, y);
				a.push( getIslandLim(data) );
			}
		}
		return a;
	}
	public function getIslandLim(data:IslandData) {
		return { lim:data.geo.monsters.length, rew:data.rew };
		/*
		var lim = data.geo.monsters.length;
		if( data.rew == null ) return lim;
		switch(data.rew) {
			case Portal :
			default :		lim++;
		}
		return lim;
		*/
	}
	
	//
	static public function getPos(x, y) {
		var n = WorldData.me.size;
		if( x >= n  ) 	x -= n;
		if( y >= n  ) 	y -= n;
		if( x < 0  ) 	x += n;
		if( y < 0  ) 	y += n;
		return { x:x, y:y };
	}
	
	
//{
}












