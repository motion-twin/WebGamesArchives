package mt.bumdum.gen;

import mt.bumdum.Lib;

class Room {//}

	public static var SUB = 20;

	public var sc:Int;

	// OUT
	public var x:Int;
	public var y:Int;
	public var par:Room;
	public var lnk:Array<Int>;
	var grid:Array<Array<Room>>;

	//
	public var seed:Int;

	public function new(seed,sc,?x,?y,?par){

		if( x == null) x = Std.int(SUB*0.5);
		if( y == null) y = Std.int(SUB*0.5);

		this.seed = seed;
		this.sc = sc;
		this.x = x;
		this.y = y;
		this.par = par;

		lnk = [];

	}

	public function genParent(){
		var sd = new mt.Rand(seed);
		par = new Room( sd.random(100000), sc+1 );
		par.genContent(this);
	}

	public function genContent(?child:Room){



		var sd = new mt.Rand(seed);

		// GRID
		grid = [];
		for( x in 0...SUB )grid[x] = [];

		// CHILD
		if( child == null )child = new Room( sd.random(100000), sc-1, sd.random(SUB) , sd.random(SUB) , this );
		grid[child.x][child.y] = child;
		var heads = [child];

		// GENERATION
		var to = 0;
		while(heads.length>0){
			var room = heads[sd.random(heads.length)];

			// NEIGHBOUR LIST
			var a = [];
			var di = 0;
			for( d in Cs.DIR ){
				var nx = room.x + d[0];
				var ny = room.y + d[1];
				if( isIn(nx,ny) && grid[nx][ny]==null ) a.push({x:nx,y:ny,di:di});
				di++;
			}


			if( a.length == 0 ){
				// DEAD HEAD
				heads.remove(room);
			}else{
				// NEW ROOM
				var p = a[sd.random(a.length)];
				var room2 = new Room( sd.random(100000), sc-1, p.x, p.y, this  );
				grid[p.x][p.y] = room2;
				heads.push(room2);

				// LINKS
				if( p.di < 2 ) 	room.lnk[p.di] = 	sd.random(SUB);
				else		room2.lnk[p.di-2] = 	sd.random(SUB);
			}


			if(to++>5000){
				trace("ERROR GEN CONTENT");
				break;
			}
		}


	}
	public function getLinks(){
		if( par==null )genParent();

		var a = lnk.copy();
		a[2] = par.grid[x-1][y].lnk[0] ;
		a[3] = par.grid[x][y-1].lnk[1] ;

		if( isBorder(x,y) ){
			var pl = par.getLinks();
			if( x==SUB-1 &&	pl[0] == y )	a[0] = 1;
			if( y==SUB-1 &&	pl[1] == x )	a[1] = 1;
			if( x==0 &&	pl[2] == y )	a[2] = 1;
			if( y==0 &&	pl[3] == x )	a[3] = 1;
		}
		return a;
	}

	// TOOLS
	public function getNext(dx,dy){
		var nx = x+dx;
		var ny = y+dy;

		if( isIn(nx,ny) ) return par.grid[nx][ny];

		if(nx<0)nx+=SUB;
		if(ny<0)ny+=SUB;
		if(nx==SUB)nx-=SUB;
		if(ny==SUB)ny-=SUB;

		var npar = par.getNext(dx,dy);
		if( npar.grid==null )npar.genContent();
		return npar.grid[nx][ny];
	}


	//
	public function getGrid(){
		if(grid==null)genContent();
		return grid;
	}
	public function getParent(){
		if(par==null)genParent();
		return par ;
	}

	// TOOLS
	public inline function isIn(x,y){
		return x>=0 && y>=0 && x<SUB && y<SUB;
	}
	public inline function isBorder(x,y){
		return x==0 || y==0 || x==SUB-1 || y==SUB-1;
	}



//{
}
















