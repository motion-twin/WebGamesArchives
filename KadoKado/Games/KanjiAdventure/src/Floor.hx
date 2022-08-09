import Protocol;

typedef Room = {rx:Int,ry:Int,dif:Int,stair:{x:Int,y:Int}};

class Floor {//}
	public static var DP_FX = 	2;
	public static var DP_SQUARE = 	1;
	public static var DP_GROUND = 	0;

	var flTrader:Bool;

	public var id:Int;

	public var sx:Int;
	public var sy:Int;
	public var rsx:Int;
	public var rsy:Int;

	public var grid:Array<Array<Square>>;
	public var rooms:Array<Array<Room>>;

	public var ents:Array<Ent>;
	public var bads:Array<ent.Bad>;

	public var ground:flash.display.BitmapData;

	public var brush:flash.MovieClip;
	var root:flash.MovieClip;
	public var dm:mt.DepthManager;

	public var seed:mt.Rand;


	public function new(id){
		this.id = id;
		root = Game.me.dm.empty(Game.DP_MAP);
		dm = new mt.DepthManager(root);

		flTrader = false;
		ents = [];
		bads = [];

		sx = Std.int(Cs.XMAX*0.5);
		sy = Std.int(Cs.YMAX*0.5);

		genGrid();
		draw();

		for( e in ents ){

			e.display();
		}


		hide();

	}
	public function update(){

	}

	// GENERATION
	public function genGrid(){

		//haxe.Log.clear();
		seed = new mt.Rand(Game.me.did+id);

		// GRID
		grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				grid[x][y] = new Square(x,y);
			}
		}


		var dfl = Game.me.floors[id-1];

		// STAIR
		var to = 0;
		while(true){
			rsx = seed.random(Cs.RX);
			rsy = seed.random(Cs.RY);
			if(id==0 && rsx!=1 && rsy!=1 ) break;
			if(id!=0 && Math.abs(rsx-dfl.rsx)+Math.abs(rsy-dfl.rsy) >= 2 )break;
		}

		// ROOMS
		rooms = [];
		for( rx in 0...Cs.RX ){
			rooms[rx] = [];
			for( ry in 0...Cs.RY ){
				genRoom(rx,ry);
			}
		}

		// STAIR DOWN;
		/*
		if( dfl!= null ){
			var sq = grid[dfl.sx][dfl.sy];
			sq.setType(STAIR_DOWN);
		}
		*/



		//
		//while(ents.length>1)ents[seed.random(ents.length)].kill();


		// CORRIDORS
		//*
		var srx = 0;
		var sry = 0;
		var erx = Cs.RX;
		var ery = Cs.RY;

		for( rx in 0...Cs.RX ){
			var x = Cs.WALL+rx*(Cs.RM*2+1)+Cs.RM;
			var sy = Cs.WALL+Cs.RM;
			var ey  = Cs.YMAX-sy;
			for( y in sy...ey ){
				var sq = grid[x][y];
				if(sq.type==WALL)sq.setType(GROUND);
			}
		}
		for( ry in 0...Cs.RY ){
			var y = Cs.WALL+ry*(Cs.RM*2+1)+Cs.RM;
			var sx = Cs.WALL+Cs.RM;
			var ex  = Cs.XMAX-sx;
			for( x in sx...ex ){
				var sq = grid[x][y];
				if(sq.type==WALL)sq.setType(GROUND);
			}
		}
		//*/


	}
	public function genRoom(px,py){

		var cx = getc(px);
		var cy = getc(py);

		var rx = 1+seed.random(Cs.RM);
		var ry = 1+seed.random(Cs.RM);

		var flStairUp = px == rsx && py == rsy;
		var flFirstRoom = px == 1 && py == 1 && id==0;

		// COULOIR PROBA

		var flCorridor = seed.random(12)==0 && !flStairUp && !flFirstRoom;
		if(flCorridor){
			rx = 0;
			ry = 0;
		}

		if(flFirstRoom){
			rx = 1;
			ry = 1;
		}


		// CHECK DOWN
		var dfl = Game.me.floors[id-1];
		var underRoom = dfl.rooms[px][py];
		if( underRoom.stair!=null ){
			rx = underRoom.rx;
			ry = underRoom.ry;
			var sq = grid[underRoom.stair.x][underRoom.stair.y];
			sq.setType(STAIR_DOWN);
		}

		var room:Room = { rx:rx, ry:ry, dif:0, stair:null };
		rooms[px][py] = room;


		// DIG ROOM
		var list = [];
		for( x in 0...(rx*2+1) ){
			for( y in 0...(ry*2+1) ){
				var px = cx+x-rx;
				var py = cy+y-ry;
				var sq = grid[px][py];
				if(sq.type==WALL){
					sq.setType(GROUND);
					list.push(sq);
				}
			}
		}


		// CORRIDOR
		/*
		var lnk = 0;
		for( i in 0...2 ){
			var d = Cs.DIR[0];
			var nb = rooms[px-d[0]][-d[1]];

		}
		*/

		if(flCorridor)return;




		// CLEAN CORRIDOR POS
		var list2 = list.copy();
		var i = 0;
		while( i < list2.length ){
			var sq = list2[i];
			if( sq.x == cx || sq.y == cy )list2.splice(i--,1);
			i++;
		}
		if(list2.length==0){
			trace("ERROR LIST2 !");
			return;
		}

		// STAIR_UP
		if( flStairUp ){
			var index = seed.random(list2.length);
			var sq = list2[index];
			list2.splice(index,1);

			sq.setType(STAIR_UP);
			sx = sq.x;
			sy = sq.y;
			room.stair = {x:sq.x,y:sq.y};
			list.remove(sq);
		}

		// MARCHAND
		if( list2.length>0 && !flTrader ){
			if(  (seed.random(36)==0 && id>0) || ( Cs.FIRST_TRADER && flFirstRoom )  ){

				flTrader = true;
				var trader = new ent.Trader();

				var index = seed.random(list2.length);
				var sq = list2[index];
				list2.splice(index,1);

				trader.setFloor(this);
				trader.setPos(sq.x,sq.y);
				list.remove(sq);
			}

		}


		// MONSTER
		var dif = id+1;
		var sum = 0;
		if( underRoom.stair!=null || flFirstRoom || flCorridor || seed.random(12)==0 ) dif = 0;
		while( sum<dif  ){
			var bid = seed.random( dif-sum );
			if( bid>7 )bid = 7;
			sum += (bid+1);

			var bad = new ent.Bad( bid );
			var index = seed.random(list.length);
			var sq = list[index];
			list.splice(index,1);

			bad.setFloor(this);
			bad.setPos(sq.x,sq.y);

			if(list.length==0)break;
		}


		/*
		var max = 1;
		while( seed.random(8)==0 )max++;
		for( i in 0...max ){


			list.splice(index,1);
			var bn = id;
			if( seed.random(3)==0 )bn++;
			if( seed.random(3)==0 )bn--;
			while( seed.random(10)==0 )bn++;
			if(bn<0)bn=0;
			if(bn>6)bn=6;

			var bad = new ent.Bad( bn );
			bad.setFloor(this);
			bad.setPos(sq.x,sq.y);
			if(list.length==0)break;
		}
		*/


		// TREASURE
		var max = 0;
		if(Math.random()*2.5>1)max++;
		while( seed.random(10)==0 )max++;
		if( max > list.length )max = list.length;
		if( max > id+1 )max = id+1;
		if( flFirstRoom )max = 0;
		for( i in 0...max ){
			var index = seed.random(list.length);
			var sq = list[index];
			list.splice(index,1);
			var id = Cs.getRandomItem();
			sq.itemId = id;
			if( Cs.isUnique(id) )Cs.PROBA_ITEMS[id] = 0;
		}



	}

	// DRAW
	public function draw(){
		// GROUND
		ground = new flash.display.BitmapData( Cs.XMAX*Cs.CS, Cs.YMAX*Cs.CS, false, Cs.COL_BG );
		var mc = dm.empty(DP_GROUND);
		mc.attachBitmap(ground,0);

		// DRAW
		brush = dm.attach("mcSquare",0);
		for( y in 0...Cs.YMAX ){
			for( x in 0...Cs.XMAX ){
				grid[x][y].draw(this);
			}
		}
		brush.removeMovieClip();


	}

	// TRACK
	public function buildTracks(){
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.XMAX ){
				//grid[x][y].setHeat(null);
				grid[x][y].heat = null;
			}
		}
		var ssq = Game.me.hero.sq;
		mark( ssq, 0, Game.me.huntMax );
	}
	public function mark(sq,heat,max){
		//sq.setHeat(heat);
		sq.heat = heat;
		if(heat==max)return;
		for( d in Cs.DIR ){
			var nx = sq.x + d[0];
			var ny = sq.y + d[1];
			var nsq = grid[nx][ny];
			if(  nsq.isFree()  && ( nsq.heat==null || nsq.heat> heat+1 ) ){
				mark(nsq,heat+1,max);
			}
		}

	}

	//
	public function show(){
		root._visible = true;
	}
	public function hide(){
		root._visible = false;
	}

	//
	public function getBad(x,y){
		var e:ent.Bad = cast grid[x][y].ent;
		if( e.flBad )return e;
		return null;
	}


	// SCROLL
	public function scroll(ent:Ent){


		//root._x = Cs.mcw*0.5 - ( (ent.sq.x+0.5)*Cs.CS + ent.root._x );
		//root._y = Cs.mch*0.5 - ( (ent.sq.y+0.5)*Cs.CS + ent.root._y );

		root._x = Cs.mcw*0.5 - ( ent.root._x  + ent.root._parent._x );
		root._y = Cs.mcw*0.5 - ( ent.root._y  + ent.root._parent._y );

	}

	//
	public function getc(rx){
		return Cs.WALL+rx*(Cs.RM*2+1)+ Cs.RM;
	}




//{
}