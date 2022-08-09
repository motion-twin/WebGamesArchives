class Bouncer{//}

	var px:int;
	var py:int;
	var ox:float;
	var oy:float;
	var frict:float;
	var sp:Phys;
	var parc:float
	
	function new(sprite){
		sp=sprite
		px = int(sp.x)
		py = int(sp.y)
		ox = 0.5;
		oy = 0.5;
		frict = 1;
	}
	
	function setPos(x,y){
		px = int(x);
		py = int(y);
		sp.x = x;
		sp.y = y;
	}
	
	function update(){
		
		parc = 1
		var tr = 0
		var vvx = sp.vx
		var vvy = sp.vy
		if( vvx==0 && vvy ==0 )parc = 0;
		
		/*
		if( !Level.isFree(px,py) ){
			Log.trace("bouncer Error!")
			var p = Level.scanRecal(px,py)
			px = p[0]
			py = p[1]
			
		}
		*/
		
		while(parc>0){

			var cx = null
			var cy = null
			
			if( vvx>0){
				cx = (1-ox)/vvx
			}else if(vvx<0){
				cx  = ox/vvx
			}else{
				cx = 1
			}
			
			if( vvy>0){
				cy = (1-oy)/vvy
			}else if(vvy<0){
				cy  = oy/vvy
			}else{
				cy = 1
			}

			
			var c = null
			var sx = null
			var sy = null
			if( Math.abs(cx) < Math.abs(cy) ){
				c = Math.abs(cx)
				sx = int(cx/c)
			}else{
				c = Math.abs(cy)
				sy = int(cy/c)
			}
			
			var flCheck = true;
			if(c>parc){
				c = parc
				flCheck = false
			}
			ox += vvx*c
			oy += vvy*c
			parc-=c
			
			if(flCheck){
				if(sx!=null){
					if( Level.isFree(px+sx,py) ){
						px += sx
						ox -= sx
					}else{
						onBounce()
						vvx*=-frict;
						sp.vx*=-frict;
				
					}
				}
				if(sy!=null){
					if( Level.isFree(px,py+sy) ){
						py += sy
						oy -= sy
					}else{
						onBounce()
						vvy*=-frict;
						sp.vy*=-frict;
						if(sp.vy<0)onBounceGround();
					}
				}
			}

		}
		
		sp.x = px+ox
		sp.y = py+oy
	}
	
	function onBounce(){
	
	}
	
	function onBounceGround(){
	
	}
	
	
	
	
	
	
	
//{	
}