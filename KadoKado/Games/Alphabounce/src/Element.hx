import mt.bumdum.Sprite;

class Element extends Sprite{//}



	var px:Int;
	var py:Int;
	var ox:Float;
	var oy:Float;
	public var vx:Float;
	public var vy:Float;

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

		var parc:Float = 1;
		var tr = 0;
		var vvx = vx*mt.Timer.tmod;
		var vvy = vy*mt.Timer.tmod;


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
					}else{
						onBounce(px+sx,py);
						vvx*=-frict;
						vx*=-frict;

					}
				}
				if(sy!=null){

					if( Game.me.isFree(px,py+sy) ){
						py += sy;
						oy -= sy*Cs.BH;
					}else{
						onBounce(px,py+sy);
						vvy*=-frict;
						vy*=-frict;
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

	function onBounce(px,py){

	}

//{
}













