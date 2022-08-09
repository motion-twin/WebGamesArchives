import mt.bumdum.Lib;
import mt.bumdum.Sprite;

class Pix extends Sprite{//}
	
	static var BOUNCE_FRICT = 0.5;

	var id:Int;

	var px:Int;
	var py:Int;
	var ox:Float;
	var oy:Float;
	
	var vx:Float;
	var vy:Float;
	
	var vvx:Float;
	var vvy:Float;
	var parc:Float;
	
	
	
	public function new(?mc){
		ox = 0;
		oy = 0;
		px = 0;
		py = 0;
		super(mc);

	}
	
	public function setPos(nx,ny){
		px = nx;
		py = ny;
		updatePos();
	}
	public function updatePos(){
		x = px+ox;
		y = py+oy;
		super.updatePos();
	}
	
	
	public function update(){
		super.update();
	}
	
	public function drop(){
		while( Cs.game.map.isFree(px,py+1) && py<Cs.game.map.bmp.height ){
			py++;	
		}
	}
	
	
	public function fly2(){
		
		parc = 1;
		var tr = 0;
		updateVV();

		while(parc>0){
			if( ox<0 || ox>1 || oy<0 || oy>1 ){
				trace("decal error!");
				trace("ox: "+ox);
				trace("oy: "+oy);
				return;
			}
			
			var cx = null;
			var cy = null;
			
			var sx = 0;
			var sy = 0;
			
			if( vvx>0){
				cx = (1-ox)/vvx;
				sx = 1;
			}else if(vvx<0){
				cx  = ox/vvx;
				sx = -1;
			}else{
				cx = 1;
			}
			
			if( vvy>0){
				cy = (1-oy)/vvy;
				sy = 1;
			}else if(vvy<0){
				cy  = oy/vvy;
				sy = -1;
			}else{
				cy = 1;
			}

			
			var c = null;
			
			var acx = Math.abs(cx);
			var acy = Math.abs(cy);
			var flCheck = true;
			
			if( acx < acy ){
				c = acx;
				sy = 0;
			}else{
				c = acy;
				sx = 0;
			}
			

			if(c>=parc){
				c = parc;
				flCheck = false;
			}
			ox = Num.mm( 0, ox+vvx*c, 1);
			oy = Num.mm( 0, oy+vvy*c, 1);
			parc-=c;

			if(flCheck){
				if( sx==0 && sy==0)trace("Oh mon dieu, c'est affreux!");
				
				var flGo = Cs.game.map.isFree(px+sx,py+sy);
				if(!flGo){
					var a = Math.atan2(vvy,vvx);
					var n = getNormal(Std.int(x),Std.int(y),{x:sx,y:sy},4);
					var da = Math.abs( Num.hMod( (n-a),3.14) );
					
					if( da > 1.57 ){
						flGo = true;
					}else{
						bounce(a,n);
						var fc = Math.max( 0, 1-((da/1.57)*0.8+0.5) );
						var f = Math.pow( BOUNCE_FRICT, fc  );
						vx *= f;
						vy *= f;
						updateVV();
					}
				}
				if(flGo){
					px += sx;
					py += sy;
					ox = Num.mm(0,ox-sx,1);
					oy = Num.mm(0,oy-sy,1);
				}
			}
		}
	
		updatePos();
	}
	
	function updateVV(){
		vvx = vx;
		vvy = vy;
	}
	function bounce(a:Float,n:Float){

		var p = Math.sqrt(vx*vx+ vy*vy);
		a = bounceAngle(a,n);
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		vx = ca*p;
		vy = sa*p;
		updateVV();
		onBounce(a,n);

	}
	function onBounce(a:Float,n:Float){
		//trace(Std.int(n*100)/100);
	}
	function bounceAngle(a:Float,n:Float){
		var da = Num.hMod((n-a),3.14);
		var dx = Math.cos(da);
		var dy = Math.sin(da);
		var na = Math.atan2(dy,-dx);
		return Num.hMod(n-na,3.14);
	}
	function getNormal(bx,by,bdir,ray){
		
		// GET SIDE LIST
		var sideList = [[bdir.x,bdir.y]];
		for( i in 0...2){
			var px = bx;
			var py = by;
			var dir = { x:bdir.x, y:bdir.y };
			var sens = i*2-1;
			for( n in 0...ray ){
				var f = turn(dir,sens);
				var nx = px+f.x;
				var ny = py+f.y;
				if(!Cs.game.map.isFree(nx,ny)){
					dir = f;
				}else{
					if(Cs.game.map.isFree(nx+dir.x,ny+dir.y)){
						px = nx+dir.x;
						py = ny+dir.y;
						dir = turn(dir,-sens);
					}else{
						px = nx;
						py = ny;
					}
				}
				sideList.push([dir.x,dir.y]);
				
				//markPoint(px,py)
			
			}
			
		}
		
		// GET ANGLE
		var dx = 0;
		var dy = 0;
		for( i in 0...sideList.length ){
			var dir = sideList[i];
			dx += dir[0];
			dy += dir[1];
		}
		// RETUUUUUUUUUUUUURN !
		return Math.atan2(dy,dx);
		
	}
	function turn(d,sens){
		return { x:-d.y*sens, y:d.x*sens };
	}

//{	
}