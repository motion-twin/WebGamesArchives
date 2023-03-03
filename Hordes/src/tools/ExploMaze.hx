package tools;
import tools.MazeGenerator;

class ExploMaze
{
	public var width(default, null) :Int;
	public var height(default, null):Int;
	public var rooms(default, null):Int;
	var maze : MazeGenerator;
	public function new( pWidth : Int, pHeight : Int, pRooms:Int)
	{
		width = pWidth;
		height = pHeight;
		rooms = pRooms;
		//
		maze = new MazeGenerator( width, height );
		maze.excludeBorders = true;
		maze.randomJoinProba = 5;
		maze.disableOpenArea = true;
	}
	
	public function getMaxDistance() {
		return maze.maxDistance;
	}
	
	public function generate( fromX, fromY ) {
		maze.init();
		maze.generate(fromX, fromY);
		placeRooms();
	}

	public function getData() {
		return maze.getData();
	}
	
	function placeRooms() {
		var roomCount = rooms;
		var minDistance = 3;
		var data = maze.getData();
		var rooms = new List();
		var pas = Lambda.array( { iterator : function() : Iterator<Int> return minDistance...maze.maxDistance } );
		while ( roomCount > 0 ) {
			var pa = pas[Std.random(pas.length)];
			pas.remove(pa);
			var ln = [];
			for ( i in 0...maze.height )
			for ( j in 0...maze.width )
				if ( data[i][j].distance == pa && data[i][j].special == MazeNodeSpecialType.None )
					ln.push(data[i][j]);
			
			for ( t in ln.copy() )
			for ( r in rooms )
				if ( (Math.abs(t.x - r.x) + Math.abs(t.y - r.y)) <= minDistance ) {
					ln.remove(t);
					break;
				}
			
			if ( ln.length != 0 ) {
				var t = ln[Std.random(ln.length)];
				t.special = MazeNodeSpecialType.Room;
				rooms.add(t);
				roomCount --;
			}
		}
	}
}