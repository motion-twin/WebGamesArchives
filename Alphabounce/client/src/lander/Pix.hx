package lander;


import mt.bumdum.Lib;


class Pix {//}

	public var x:Int;
	public var y:Int;
	public var gid:Int;

	public var root:flash.MovieClip;

	var redPix:flash.MovieClip;	// DEBUG
	var mcNormal:flash.MovieClip;	// DEBUG

	public function new(x,y,gid,?mc) {

		root = mc;
		this.x = x;
		this.y = y;
		this.gid = gid;
	}

	// UPDATE
	public function updatePos(){
		root._x = x;
		root._y = y;
	}


	//
	public function kill(){
		root.removeMovieClip();
	}

	// STATIC TOOLS
	static public function movePoint(p:Pix,sens){
		var fwd = Cs.getDir(p.gid-sens);
		var d = Cs.DIR[fwd];
		var gd = Cs.DIR[p.gid];
		var nx = p.x+d[0];
		var ny = p.y+d[1];
		if( !lander.Game.me.isLandingFree(nx,ny,0xFFFF0000) ){
			p.gid = fwd;
			movePoint(p,sens);
		}else{
			var gx = nx+gd[0];
			var gy = ny+gd[1];
			if(lander.Game.me.isLandingFree(gx,gy,0xFFFF0000)){
				p.x = gx;
				p.y = gy;
				p.gid = Cs.getDir(p.gid+sens);
			}else{
				p.x = nx;
				p.y = ny;
			}
		}
	}

	public function getNormal(?p:Pix,?range){
		if(p==null)p = this;
		if(range==null)range = 3;
		var a = [];
		for( i in 0...2 ){
			var sens = i*2-1;
			//var np:Pix = { x:p.x, y:p.y, gid:p.gid, sens:sens };
			var np = new Pix(p.x,p.y,gid);
			for( n in 0...range ){
				Pix.movePoint(np,sens);
				a.push(np.gid);
			}
		}
		//trace("["+p.x+","+p.y+"]"+a);

		var dx = 0;
		var dy = 0;
		for( di in a ){
			var d = Cs.DIR[di];
			dx += d[0];
			dy += d[1];
		}
		return Num.hMod(Math.atan2(dy,dx)+3.14,3.14);
	}

	public function isFree(x,y){

		var ma = 2;
		if( x<ma || x>lander.Game.WIDTH-ma ) return false;

		return lander.Game.me.isLandingFree(x,y,0xFFFF0000);


	}

	// DEBUG
	/*
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
	*/




//{
}











