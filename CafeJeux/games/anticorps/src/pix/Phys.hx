package pix;
import Common;
import mt.bumdum.Lib;


class Phys extends Pix {//}


	public var flAngleBounce:Bool;

	var ox:Float;
	var oy:Float;
	public var vx:Float;
	public var vy:Float;

	public var vvx:Float;
	public var vvy:Float;
	public var weight:Float;
	var parc:Float;
	var frict:Float;
	public var colFrict:Float;

	public var context:{mapBmp:flash.display.BitmapData};
	var mapPoint:flash.MovieClip;

	public function new(mc) {

		//context = Game.me;

		super(mc);
		ox = 0.5;
		oy = 0.5;
		vx = 0;
		vy = 0;
		colFrict = 1;
	}
	public function initMapPos(frame){
		if(Game.me.miniMap.sc<0.05)return;
		mapPoint = Game.me.miniMap.dm.attach("mcMapPoint",1);
		mapPoint.gotoAndStop(frame);
		mapPoint._xscale = 100/Game.me.miniMap.sc;
		mapPoint._yscale = mapPoint._xscale;
		mapPoint._x = x;
		mapPoint._y = y;
		//Filt.glow(mapPoint,2,10,0xFFFFFF);
	}

	public function fly(){



		// FRICT
		if(frict!=null){
			vx *= frict;
			vy *= frict;
		}

		// WEIGHT
		if(weight!=null)vy += weight;

		// PHYS
		parc = 1;
		var tr = 0;
		vvx = vx;
		vvy = vy;
		while(parc>0){

			var cx = null;
			var cy = null;

			if( vvx>0){
				cx = (Cs.UNIT-ox)/vvx;
			}else if(vvx<0){
				cx  = ox/vvx;
			}else{
				cx = 1/0;
			}

			if( vvy>0){
				cy = (Cs.UNIT-oy)/vvy;
			}else if(vvy<0){
				cy  = oy/vvy;
			}else{
				cy = 1/0;
			}


			var c = null;
			var sx = null;
			var sy = null;
			if( Math.abs(cx) < Math.abs(cy) ){
				c = Math.abs(cx);
				sx = Std.int(cx/c);
				if(c==0)sx=-1;
			}else{
				c = Math.abs(cy);
				sy = Std.int(cy/c);
				if(c==0)sy=-1;
			}

			var flCheck = true;
			if(c>parc){
				c = parc;
				flCheck = false;
			}
			ox += vvx*c;
			oy += vvy*c;
			parc-=c;

			if(flCheck){
				if(sx!=null){
					if( isFree(x+sx,y) ){
						x += sx;
						ox -= sx*Cs.UNIT;
					}else{
						onBounce(sx,0);



					}
				}
				if(sy!=null){

					if( isFree(x,y+sy) ){
						y += sy;
						oy -= sy*Cs.UNIT;
					}else{
						onBounce(0,sy);
					}
				}
			}
		}

		//
		updatePos();

	}
	function onBounce(sx,sy){

		if( flAngleBounce ){

			// ANGLE
			gid = getDir(sx,sy);
			var n = getNormal();
			var a = Math.atan2(vy,vx)+3.14;
			var da = Num.hMod(a-n,3.14);
			var dist = Math.sqrt(vx*vx+vy*vy) * colFrict;
			var na = Num.hMod(n-da,3.14);

			//Game.me.showAngle(x,y,na);

			// VITESSE
			vx = Math.cos(na)*dist;
			vy = Math.sin(na)*dist;
			ox = 0.5;
			oy = 0.5;
			parc = 0;
			return;
		}

		if(sx!=0){
			vvx*=-colFrict;
			vx*=-colFrict;
		}
		if(sy!=0){
			vvy*=-colFrict;
			vy*=-colFrict;
		}


		//trace(getDir(sx,sy)+"___"+isFree(x+sx,y+sy));
	}

	override function updatePos(){
		root._x = x+ox;
		root._y = y+oy;

		if(mapPoint!=null){
			mapPoint._x = x;
			mapPoint._y = y;
		}
		/*
		if(!isFree(x,y)){
			trace("argh!("+x+";"+y+")");
		}
		*/

	}

	function isFree(x,y){
		if(context!=null){
			var pix = context.mapBmp.getPixel32(x,y);
			var col = Col.colToObj32(pix);
			return col.a < 50 || y>Game.me.mapHeight;

		}

		return Game.me.isFree(x,y);

	}

	function frictVit(c){
		vx*=c;
		vy*=c;
		vvx*=c;
		vvy*=c;
	}

	public function getDir(x,y){
		if( x==1 && y==0 )return 0;
		if( x==0 && y==1 )return 1;
		if( x==-1 && y==0 )return 2;
		if( x==0 && y==-1 )return 3;
		trace("getDir Error");
		return null;

	}

	// FX
	public function getGlue(ga){
		var ec = 8;
		var p = new mt.bumdum.Phys( Game.me.layGlue.dm.attach("partGlue",0) );
		p.x = x + Math.cos(ga+1.57)*(Math.random()*2-1)*ec;
		p.y = y + Math.sin(ga+1.57)*(Math.random()*2-1)*ec;
		p.fadeType = 0;
		p.weight = 0.03+Math.random()*0.05;
		p.timer = 10+Math.random()*15;
		p.setScale(80+Math.random()*50);
		return p;
	}

	override function kill(){
		if(mapPoint!=null)mapPoint.removeMovieClip();
		super.kill();
	}

//{
}











