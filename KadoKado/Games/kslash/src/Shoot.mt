class Shoot {//}

	var dm:DepthManager;
	var root:MovieClip;
	
	var flCheck:bool;
	
	var x:int;
	var y:int;
	var dx:float;
	var dy:float;
	
	var vx:float;
	var vy:float;
	var vr:float;
	
	function new(mc) {
		dm = new DepthManager(mc);
		root = mc;
		Cs.game.sList.push(this)
		x=0;
		y=0;
		dx=0;
		dy=0;
		vr=0
	}

	
	function update() {
		flCheck = false;
		
		dx+=vx*Timer.tmod;
		dy+=vy*Timer.tmod;
			
		recal();
		
		root._x = (x+0.5)*Cs.SIZE + dx
		root._y = (y+0.5)*Cs.SIZE + dy
		root._rotation += vr*Timer.tmod;
		
		
		if( x<0 || x>Game.XMAX || y<0 || y>Game.YMAX ){
			kill();
		}
		
		if(!flCheck)checkCol();
		
	}
	
	function recal(){
		var m  = Cs.SIZE*0.5
		var adx = Math.abs(dx)
		var ady = Math.abs(dy)
		
		while( adx>m || ady>m ){
			if(adx>m){
				if(dx>0){
					dx-=2*m
					x++;
				}else{

					dx+=2*m
					x--;

				}
			}else{
				if(dy>0){
					dy-=2*m
					y++;

				}else{		
					dy+=2*m
					y--;
				}
			}
			adx = Math.abs(dx)
			ady = Math.abs(dy)
			checkCol();
		}
		
		
	
	}
	
	
	
	function kill(){
		Cs.game.sList.remove(this)
		root.removeMovieClip();
	}
	
	function checkCol(){
		flCheck = true;
	}
	
	

//{
}








