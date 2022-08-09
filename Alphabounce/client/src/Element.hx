import mt.bumdum.Sprite;
import mt.bumdum.Lib;

class Element extends Sprite{//}

	public var flGhost:Bool;

	public var px:Int;
	public var py:Int;
	var ox:Float;
	var oy:Float;
	public var vx:Float;
	public var vy:Float;
	var vvx:Float;
	var vvy:Float;

	var frict:Float;

	public function new(mc){
		super(mc);

		ox = 0.5;
		oy = 0.5;
		px = 0;
		py = 0;
		vx  = 0;
		vy  = 0;
		frict = 1;

	}

	override public function update(){

		//trace("! x>"+Std.int(x)+" y>"+Std.int(y));

		var parc:Float = 1;
		var tr = 0;
		vvx = vx*mt.Timer.tmod;
		vvy = vy*mt.Timer.tmod;


		while(parc>0){

			var cx = null;
			var cy = null;

			if( vvx>0){
				cx = (Cs.BW-ox)/vvx;
			}else if(vvx<0){
				cx  = ox/vvx;
			}else{
				cx = 999999;
			}

			if( vvy>0){
				cy = (Cs.BH-oy)/vvy;
			}else if(vvy<0){
				cy  = oy/vvy;
			}else{
				cy = 999999;
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
					if( Game.me.isFree(px+sx,py) ){

						px += sx;
						ox -= sx*Cs.BW;
						onEnterSquare(sx,0);
					}else{
						onBounce(px+sx,py);

					}
				}
				if(sy!=null){

					if( Game.me.isFree(px,py+sy) ){

						py += sy;
						oy -= sy*Cs.BH;
						onEnterSquare(0,sy);
					}else{
						onBounce(px,py+sy);

					}
				}
			}
		}


		x = Cs.getX(px)+ox;
		y = Cs.getY(py)+oy;
		// POS
		super.update();

		/* TRACE POS
		var mc = Game.me.dm.attach("mcDebugSquare",10);
		mc._x = Cs.getX(px);
		mc._y = Cs.getY(py);
		mc._xscale = Cs.BW;
		mc._yscale = Cs.BH;
		//*/


	}


	// GHOST
	public function setGhost(fl){

		flGhost = fl;
		if(flGhost){
			root._alpha = 25;
			updateNormal = update;
			untyped update = updateGhost;
		}else{
			moveTo(x,y);
			root._alpha = 100;
			untyped update = updateNormal;
		}
	}
	public function updateGhost(){
		/*
		trace("----");
		trace(x+";"+y);
		trace(vx+";"+vy);
		*/

		x += vx*mt.Timer.tmod;
		y += vy*mt.Timer.tmod;

		if( x < Cs.SIDE || x > Cs.mcw-Cs.SIDE ){
			x = Num.mm( Cs.SIDE,x,Cs.mcw-Cs.SIDE);
			vx *= -1;
		}
		if( y<0 ){
			y = 0;
			vy *= -1;
		}

		if( vy>0 ){
			setGhost(false);
		}


		root._x = x;
		root._y = y;


	}
	dynamic public function updateNormal(){

	}



	override public function updatePos(){
		x = Cs.getX(px)+ox;
		y = Cs.getY(py)+oy;
		super.updatePos();
	}
	public function moveTo(nx:Float,ny:Float){
		px = Std.int((nx-Cs.SIDE)/Cs.BW);
		py = Std.int(ny/Cs.BH);
		ox = nx-Cs.getX(px);
		oy = ny-Cs.getY(py);

	}

	public function getPos(){
		return {x:Cs.getX(px)+ox,y:Cs.getY(py)+oy};

	}

	function onBounce(px:Int,py:Int){
		if(this.px!=px){
			vvx*=-frict;
			vx*=-frict;
		}else{
			vvy*=-frict;
			vy*=-frict;
		}

	}
	function onEnterSquare(sx,sy){

	}

//{
}













