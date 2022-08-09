import Common;
import mt.bumdum.Lib;



class Pix {//}

	public var x:Int;
	public var y:Int;
	public var gid:Int;

	public var root:flash.MovieClip;


	var redPix:flash.MovieClip;	// DEBUG
	var mcNormal:flash.MovieClip;	// DEBUG

	public function new(mc) {

		root = mc;
		x = 0;
		y = 0;
	}

	// UPDATE
	public function updatePos(){
		root._x = x;
		root._y = y;
	}

	// TOOLS
	public function seekGround(di,flOut:Bool,?max:Int){

		//var flOut = Game.me.isFree(x,y);
		//var inc = if(flOut) -1; else 0;

		if(max==null)max = 100;
		var d = Cs.DIR[di];
		for( i in 1...max ){
			var nx = x+d[0]*i;
			var ny = y+d[1]*i;
			if( Game.me.isFree(nx,ny) != flOut )return i;
		}
		return null;
	}
	public function gotoNext(sens){
		Pix.movePoint(this,sens);
		updatePos();

	}


	/*
	public function getNormal(?range){
		if(range==null)range = 3;
		var a = [];
		for( i in 0...2 ){
			var sens = i*2-1;
			var p = {x:x,y:y,gid:gid,sens:sens};
			for( n in 0...range ){
				Pix.movePoint(p,sens);
				a.push(p.gid);
			}
		}

		var dx = 0;
		var dy = 0;
		for( di in a ){
			var d = Cs.DIR[di];
			dx += d[0];
			dy += d[1];
		}
		return Math.atan2(dy,dx)+3.14;
	}

	*/
	//
	public function kill(){
		root.removeMovieClip();
	}

	// STATIC TOOLS
	static public function movePoint(p:Point,sens){

		var fwd = Cs.getDir(p.gid-sens);
		var d = Cs.DIR[fwd];
		var gd = Cs.DIR[p.gid];
		var nx = p.x+d[0];
		var ny = p.y+d[1];
		if( !Game.me.isFree(nx,ny) ){
			p.gid = fwd;
			//p.gid = Cs.getDir(p.gid+sens);
			movePoint(p,sens);
		}else{
			var gx = nx+gd[0];
			var gy = ny+gd[1];
			if(Game.me.isFree(gx,gy)){
				p.x = gx;
				p.y = gy;
				p.gid = Cs.getDir(p.gid+sens);
			}else{
				p.x = nx;
				p.y = ny;
			}
		}

	}

	public function getNormal(?p:Point,?range){
		if(p==null)p = this;
		if(range==null)range = 3;
		var a = [];
		for( i in 0...2 ){
			var sens = i*2-1;
			var np = { x:p.x, y:p.y,gid:p.gid};
			for( n in 0...range ){
				Pix.movePoint(np,sens);
				a.push(np.gid);
			}
		}

		var dx = 0;
		var dy = 0;
		for( di in a ){
			var d = Cs.DIR[di];
			dx += d[0];
			dy += d[1];
		}
		return Num.hMod(Math.atan2(dy,dx)+3.14,3.14);
	}

	// DEBUG
	function showAngle(a:Float){
		if(gid==null)return;
		if(mcNormal==null)mcNormal = Game.me.dm.attach("mcNormal",Game.DP_PARTS);
		mcNormal._x = root._x;
		mcNormal._y = root._y;
		mcNormal._rotation = a/0.0174;
	}
	function showPix(){
		if(redPix==null)redPix = Game.me.dm.attach("mcRedPix",Game.DP_PARTS);
		redPix._x = x;
		redPix._y = y;
	}




//{
}











