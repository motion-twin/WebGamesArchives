class Ball{//}
	
	static var BDIR=[[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-0],[0,-1]]
	
	var x:int;
	var y:int;
	
	var gid:int;
	var type:int;
	var col:int;
	
	var dy:float;
	var root:{>MovieClip,b:MovieClip};
	var cl:{>MovieClip,b:MovieClip};
	
	var flIce:bool;
	//var exp:{x:float,y:float}
	
	
	function new(){
		flIce = false;
		dy = 0
		root = downcast(Cs.game.dm.attach("mcBall",Game.DP_BALL));
		Cs.game.bList.push(this);
		root._alpha = 45 + Math.random() * 45;
	}

	function updatePos(){
		root._x = Cs.ML + (x+0.5)*Cs.SQ
		root._y = ( Cs.MD- (y+0.5)*Cs.SQ ) + dy;
	}
	
	function setPos(nx,ny){
		Cs.game.grid[x][y] = null
		x = nx;
		y = ny
		Cs.game.grid[x][y] = this;
	}
	
	//
	function checkBlast(){
		for( var i=0; i<BDIR.length; i++ ){
			var nx = x+BDIR[i][0]
			var ny = y+BDIR[i][1]
			var b = Cs.game.grid[nx][ny]
			if( b!=null && b.flIce){
				b.unIce();
			}
		}
	}
	
	//
	
	function genClone(){
		cl = downcast(Cs.game.dm.attach("mcBall",Game.DP_BALL));
		cl._x = root._x;
		cl._y = root._y;
		setSkin(cl)
	}
	
	function removeClone(){
		cl.removeMovieClip();
		cl = null;
	}
	
	function unIce(){
		flIce = false;
		setSkin(root);
		var max = 6
		for( var i=0; i<max; i++ ){
			var p = new Part(Cs.game.dm.attach("partIceBlast",Game.DP_PART));
			var a = (i/max)*6.28 //Math.random()*6.28
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 2//0.5+Math.random()*2
			var ray = 6
			p.x = Cs.ML + (x+0.5)*Cs.SQ + ca*ray
			p.y = Cs.MD - (y+0.5)*Cs.SQ + sa*ray
			p.vx = ca*sp
			p.vy = sa*sp
			//p.weight = 0.3*Math.random()*0.2
			p.timer = 20+Math.random()*5
			p.root.gotoAndStop( string(Std.random(p.root._totalframes)+1) )
			p.root._rotation = a/0.0157
			p.fadeType = 0
		}
		
	}
	
	function setSkin(mc){
		
	}
	
	function explode(){
		kill();
	}
	
	function kill(){
		removeClone();
		Cs.game.bList.remove(this)
		Cs.game.grid[x][y] = null
		root.removeMovieClip();
	}
	

	
//{	
}