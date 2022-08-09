package mt.bumdum.gen;
//import mt.bumdum.Lib;

typedef Coord = {
	x:Int,
	y:Int,
}


class World {//}


	public var or : Room;


	public function new(seed){

		or = new Room(seed,-1);

	}


	public function getRoom( x,y ){

		var a = coordToPos(x,y);

		// GENERATION PARENT
		var room = or;
		for( i in 0...a.length)room = room.getParent();

		// GOTO ROOM
		while( a.length>0 ){
			var p = a.pop();
			var grid = room.getGrid();
			room = grid[p.x][p.y];
		}

		return room;

	}


	// POS
	public function posToCoord( a:Array<Coord> ){
		var nx = 0;
		var ny = 0;
		for( i in 0...a.length ){
			var p = a[i];
			var d = Std.int(Math.pow(Room.SUB,i));
			nx += (p.x-10)*d;
			ny += (p.y-10)*d;
		}
		return {x:nx,y:ny};
	}
	public function coordToPos( nx, ny ){

		var a = [];
		var id = 1;
		while( nx!=0 || ny!=0 ){
			var d = Std.int(Math.pow(Room.SUB,id));
			var d2 = Std.int(Math.pow(Room.SUB,id-1));

			var dx = Std.int( hMod(nx,d*0.5) );
			var dy = Std.int( hMod(ny,d*0.5) );

			nx -= dx;
			ny -= dy;

			a.push( { x:10+Std.int(dx/d2), y:10+Std.int(dy/d2) } );
			id++;
		}
		return a;


	}


	// TOOLS
	public function hMod(n:Float,mod:Float){

		//*
		if(n>=mod){

			var m = Std.int((n-mod)/(mod*2))+1 ;
			return n - m*mod*2;
		}
		if(n<-mod){
			var m = Std.int(-(n-mod)/(mod*2))+1 ;
			return n - m*mod*2;
		}
		/*/

		while(n>=mod)n-=mod*2;
		while(n<-mod)n+=mod*2;

		//*/
		return n;
	}




//{
}















