import mt.bumdum.Lib;

class BlocManager {//}

	public var dx:Int;
	public var dy:Int;
	public var max:Int;
	
	
	public var list:Array<Bloc>;
	public var grid:Array<Array<Bloc>>;
	public var dm:mt.DepthManager;	
	
	public var groups:Array<Array<Bloc>>;
	
	public var root:flash.MovieClip;
	
	
	
	
	public function new(mc,m){
		max = m;
		list = [];
		grid = [];
		root = mc;
		dx = 0;
		dy = 0;
		dm = new mt.DepthManager(root);
		for( x in 0...max ){
			grid[x] = [];
			for( y in 0...max ){
				grid[x][y] = null;
			}			
		}
		
		root.cacheAsBitmap = true;
		Filt.glow(root, 3,5, 0 );
	}
	
	
	// GRID
	public function insertInGrid(b:Bloc){
		grid[b.x+dx][b.y+dy] = b;
	}
	public function removeFromGrid(b:Bloc){
		if(grid[b.x+dx][b.y+dy]!=b)return;
		grid[b.x+dx][b.y+dy] = null;
	}

	// GROUPS
	public function getGroups(f){
		//trace("GENGROUP!");
		var groups = [];
		for(b in list )b.gid=null;
		
		
		var dir = [[0,1],[1,0]];
		for( x in 0...max ){
			for( y in 0...max ){
				var b = grid[x][y];
				if(b!=null){
					if( b.gid==null){
						b.gid = groups.length;
						groups.push([b]);
					}
					var a = groups[b.gid];
					//trace("["+(x-dx)+","+(y-dy)+"]"+b.gid+":"+a.length);
					for( d in dir ){
						var b2 = grid[x+d[0]][y+d[1]];
						
						if( f(b,b2) ){
							if(b2.gid==null){
								b2.gid = b.gid;
								a.push(b2);
							}else if(b2.gid != b.gid){
								var a2 = groups[b2.gid];
								groups[b2.gid] = null;
								for( b3 in a2 ){
									b3.gid = b.gid;
									a.push(b3);
								}
								
								
							}
						}
						
					}
					
					
				}				
			}
		}

		
		
		/* TRACE
		var i = 0;
		for( list in groups ){
			for( b in list ){
				var mc:{>flash.MovieClip, field:flash.TextField} = cast b.root;
				//if(i!=b.gid)trace("error!");
				mc.field.text = Std.string(i);
			}
			i++;
		}
		//*/
		
		return groups;
		
	}
	public function getFalls(){
		var done = [];
		for( x in 0...max)done[x]=[];
		traceNeighbours(dx,dy,done);
		/*
		for( x in 0...max){
			var str = "";
			for( y in 0...max){
				if(done[x][y]==null) str += "X"; else str += "O";
			}
			trace(str);
		}
		*/
		var a = [];
		for( b in list ){
			if(done[b.x+dx][b.y+dy]==null)a.push(b);
		}
		return a;
	}
	public function traceNeighbours(x,y,done){
		done[x][y] = true;
		for( d in Game.DIR ){
			var nx = x+d[0];
			var ny = y+d[1];
			if(done[nx][ny]==null){
				
				var b = grid[nx][ny];
				if( b!=null )traceNeighbours(nx,ny,done);
			}
		}
		
	}
	
	
	// ROTATION
	public function checkRotate(bm,dx,dy){
	
		for( b in list ){
			var nx = dx -b.y;
			var ny = dy +b.x;
			if( !bm.isFree(nx,ny) ){
				return false;
			}
		}
		return true;
	}	
	public function rotate(){
		for( b in list ){
			b.setPos(-b.y,b.x);
		}
	}
	
	// TOOLS
	public function isOut(x,y,?m){
		if(m==null)m=0;
		return x<m || x>= max-m || y<m || y>= max-m;		
	}
	public function isFree(x,y){
		return grid[x+dx][y+dy] == null && !isOut(x+dx,y+dy);
	}
	
//{
}