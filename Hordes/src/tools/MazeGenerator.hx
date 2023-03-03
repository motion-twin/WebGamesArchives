package tools;

enum MazeNodeType {
	Wall;
	Path;
}

enum MazeNodeSpecialType {
	None;
	Room;
}

typedef MazeNode = {
	var type : MazeNodeType;
	var distance : Int;
	var x : Int;
	var y : Int;
	var special : MazeNodeSpecialType;
}

class MazeGenerator 
{
	public var width(default, null) :Int;
	public var height(default, null):Int;
	var data : Array<Array<MazeNode>>;
	var invalidatedMax : Bool;
	var cachedMax : Int;
	public var excludeBorders : Bool;
	public var minStep : Int;
	public var randomStepLength : Int;
	public var randomExitProba : Null<Int>;
	public var randomJoinProba : Null<Int>;
	public var disableOpenArea : Bool;
	public var maxDistance(getMaxDistance, null):Int; 
	
	public function new(pWidth: Int, pHeight:Int) 
	{
		width = pWidth;
		height = pHeight;
		invalidatedMax = true;
		//
		minStep = 3;
		maxDistance = 0;
		excludeBorders = false;
		randomStepLength = 2;
		randomExitProba = null;
		randomJoinProba = null;
		disableOpenArea = false;
		init();		
	}
	
	function getMaxDistance() {
		if ( invalidatedMax ) {
			invalidatedMax = false;
			cachedMax = 0;
			for ( i in 0...height)
			for ( j in 0...width)
				if ( data[i][j].distance > cachedMax ) cachedMax = data[i][j].distance;
		}
		return cachedMax;
	}
	
	public function init() {
		data = [];
		for ( i in 0...height) {
			data[i] = [];
			for ( j in 0...width)
				data[i][j] = { distance:0, y : i, x : j, type : Wall, special : None };
		}
	}
	
	public function getData() {
		return data;
	}
	
	
	inline function checkCoord(tx, ty) {
		if( excludeBorders ) 
			return ( ty >= 1 && ty < height - 1 && tx >= 1 && tx < width - 1 ) ;
		else
			return ( ty >= 0 && ty < height && tx >= 0 && tx < width ) ;
	}
	
	inline function isWall(n) {
		return switch( n.type ) {
			case Wall: true;
			default:false;
		}
	}
	
	function updateDistance(node : MazeNode) {
		invalidatedMax = true;
		var neighbors = [];
		for ( d in [{ x:1, y:0 }, { x:0, y:1 }, { x: -1, y:0 }, { x:0, y: -1 }] ) {
			if ( checkCoord( node.x + d.x, node.y + d.y ) ) {
				var n2 = data[node.y + d.y][node.x + d.x];
				if ( isWall(n2) ) continue;
				if ( (n2.distance + 1) < node.distance ) node.distance = n2.distance + 1;
				neighbors.push(n2);
			}
		}
		for ( n in neighbors )
			if ( n.distance > (node.distance + 1) )
				updateDistance( n );
	}
	
	
	public function generate(fromX, fromY) {
		invalidatedMax = true;
		var head = data[fromY][fromX];
		head.type = Path;
		
		var walker = new List();
		walker.add( head );
		
		var dirs = [ { x:1, y:0 }, { x:0, y:1 }, { x: -1, y:0 }, { x:0, y: -1 } ];
		var d;
		var dTime = 0;
		
		while ( walker.length > 0 ) {
			dTime --;
			if ( dTime < 0 ) {
				d = dirs[1+Std.random(dirs.length-1)];
				dirs.remove(d); dirs.unshift(d);
				dTime = minStep + Std.random(randomStepLength);
			}					
			var next = null;
			for ( dir in dirs ) {
				//force some random exit
				if ( randomExitProba != null && Std.random(randomExitProba) == 0 ) continue;
				//
				var ty = head.y + dir.y;
				var tx = head.x + dir.x;
				if ( checkCoord(tx, ty) ) {
					next = data[ty][tx];
					if ( isWall(next) ) {
						var wallsCount = 0;
						var wdir = { x:0, y:0 };
						for ( dir in dirs ) {
							var ty = next.y + dir.y;
							var tx = next.x + dir.x;
							if ( !checkCoord(tx, ty) || isWall(data[ty][tx]) ) {
								wallsCount ++;
								wdir.x += dir.x * dir.x;
								wdir.y += dir.y * dir.y;
							}
						}
						if ( wallsCount < 3 ) {
							if ( randomJoinProba != null && (Std.random(randomJoinProba) == 0 && (!disableOpenArea || (wallsCount == 2 && (wdir.x == 0 || wdir.y == 0) ))) ) {
								next.type = Path;
								next.distance = head.distance + 1;
								//we break path, so we need to update distance of nodes !
								updateDistance(next);
							}
							next = null;
						}
					} else {
						next = null;
					}
				}
				if ( next != null ) break;
			}
			//
			if ( next == null ) {
				head = walker.pop();
				dTime = 0;
			} else {
				next.type = Path;
				next.distance = head.distance + 1;
				walker.add(next);	
				head = next;
			}			
		}
	}
}