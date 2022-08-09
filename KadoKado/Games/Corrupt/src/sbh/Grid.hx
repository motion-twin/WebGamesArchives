package sbh;

class Grid extends SpriteBehaviour {//}


	var px:Int;
	var py:Int;
	var id:Int;

	public function new( sp, id:Int ){
		this.id = id;
		if(grid[id]==null)initPlan(id);
		super(sp);
	}
	override function update(){
		updateGridPos();

	}

	// GRID POS
	function updateGridPos(){
		var npx = getPX(sp.x);
		var npy = getPY(sp.y);
		if( npx!=px || npy!=py ){
			removeFromGrid();
			px = npx;
			py = npy;
			insertInGrid();
		}
	}
	function insertInGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				grid[id][gx][gy].push(this);
			}
		}
	}
	function removeFromGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				grid[id][gx][gy].remove(this);
			}
		}
	}

	// TOOLS
	public function getNeighbours(plan){
		var list = [];
		for( gr in grid[plan][px][py] )if( gr!= this )list.push(gr);
		return list;
	}

	// STATIC
	static public var WIDTH = 300;
	static public var HEIGHT = 300;
	static public var CS = 30;
	static public var XMAX = 0;
	static public var YMAX = 0;

	static public var grid:Array<Array<Array<Array<sbh.Grid>>>>;

	static public function init(cs,w,h){
		CS  = cs;
		WIDTH = w;
		HEIGHT = h;
		XMAX = Math.ceil( WIDTH / CS );
		YMAX = Math.ceil( HEIGHT / CS );
		grid = [];


	}
	static public function initPlan(id){
		grid[id] = [];
		for( x in 0...XMAX ){
			grid[id][x] = [];
			for( y in 0...YMAX )grid[id][x][y] = [];
		}
	}

	// TOOLS
	static function getPX(x:Float){
		return Std.int( x/CS );
	}
	static function getPY(y:Float){
		return Std.int( y/CS );
	}





//{
}

