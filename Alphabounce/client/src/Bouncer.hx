import mt.bumdum.Phys;


class Bouncer{//}


	var sp:Phys;
	
	var px:Int;
	var py:Int;
	var ox:Float;
	var oy:Float;
	public var frict:Float;

	public function new(sprite){
		sp = sprite;
		frict = 1;
		setPos(sp.x,sp.y);
	}
	
	public function update(){
		
		var parc:Float = 1;
		var tr = 0;
		var vvx = sp.vx*mt.Timer.tmod;
		var vvy = sp.vy*mt.Timer.tmod;

		
		while(parc>0){

			var cx = null;
			var cy = null;
			
			if( vvx>0){
				cx = (Cs.BW-ox)/vvx;
			}else if(vvx<0){
				cx  = ox/vvx;
			}else{
				cx = 1;
			}
			
			if( vvy>0){
				cy = (Cs.BH-oy)/vvy;
			}else if(vvy<0){
				cy  = oy/vvy;
			}else{
				cy = 1;
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
						sp.vx*=-frict;
				
					}
				}
				if(sy!=null){
					
					if( Game.me.isFree(px,py+sy) ){
						py += sy;
						oy -= sy*Cs.BH;
					}else{
						onBounce(px,py+sy);
						vvy*=-frict;
						sp.vy*=-frict;
					}
				}
			}
		}
		
		
		sp.x = Cs.getX(px)+ox;
		sp.y = Cs.getY(py)+oy;

	}
	
	public function setPos(nx:Float,ny:Float){
		px = Std.int((nx-Cs.SIDE)/Cs.BW);
		py = Std.int(ny/Cs.BH);
		ox = nx-Cs.getX(px);
		oy = ny-Cs.getY(py);
	}
	
	public function onBounce(px,py){
	
	}
	











//{
}