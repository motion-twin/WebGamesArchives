class RoundBouncer extends Bouncer{//}
	
	static var RAY = 6;
	var pList:Array<{x:int,y:int}>
	static var mList:Array<MovieClip>
	
	var vvx:float;
	var vvy:float;
	
	
	function new(sprite){
		super(sprite)
		if(mList==null)mList = new Array();
		
		pList = new Array();
		
		var ray = 6
		var max = 4
		for( var i=0; i<max; i++ ){
			var a = (i/max)*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			pList.push({x:int(ca*ray),y:int(sa*ray)})
		}
		
		//
		frict = 0.3
		
	}
	

	
	function update(){
		
		while(mList.length>100)mList.shift().removeMovieClip();
		
		parc = 1
		var tr = 0
		updateVV();

		while(parc>0){
			if( ox<0 || ox>1 || oy<0 || oy>1 ){
				Log.print("decal error!")
				Log.print("ox: "+ox)
				Log.print("oy: "+oy)
				return;
			}
			
			var cx = null
			var cy = null
			
			var sx = 0
			var sy = 0
			
			if( vvx>0){
				cx = (1-ox)/vvx
				sx = 1
			}else if(vvx<0){
				cx  = ox/vvx
				sx = -1
			}else{
				cx = 1
			}
			
			if( vvy>0){
				cy = (1-oy)/vvy
				sy = 1
			}else if(vvy<0){
				cy  = oy/vvy
				sy = -1
			}else{
				cy = 1
			}

			
			var c = null
			
			var acx = Math.abs(cx)
			var acy = Math.abs(cy)
			var flCheck = true;
			
			if( acx < acy ){
				c = acx
				sy = 0
			}else{
				c = acy
				sx = 0
			}
			

			if(c>=parc){
				c = parc
				flCheck = false
			}
			ox = Cs.mm( 0, ox+vvx*c, 1)
			oy = Cs.mm( 0, oy+vvy*c, 1)
			parc-=c

		
			if(flCheck){
				if( sx==0 && sy==0) Log.trace("Oh mon dieu, c'est affreux!");
				
				var cp = isRoundFree(px+sx,py+sy)
				var flGo = cp == null
				if(!flGo){
					var a = Math.atan2(vvy,vvx)
					var n = getNormal(cp.x,cp.y,{x:sx,y:sy},RAY)
					var da = Math.abs( Cs.hMod((n-a),3.14) )
					
					if( da > 1.57 ){
						flGo = true
					}else{
						bounce(a,n)
						var fc = Math.max( 0, 1-((da/1.57)*0.8+0.5) )
						var f = Math.pow( frict, fc  )
						sp.vx *= f;
						sp.vy *= f;
						updateVV()
					}
				}
				if(flGo){
					px += sx
					py += sy
					ox = Cs.mm(0,ox-sx,1)
					oy = Cs.mm(0,oy-sy,1)
				}
			}
		}
		if(sp.bouncer==this){
			sp.x = px+ox
			sp.y = py+oy
		}
	}
	
	function bounce(a:float,n:float){

		onBounceAngle(a,n);
		var p = Math.sqrt(sp.vx*sp.vx+ sp.vy*sp.vy)
		a = bounceAngle(a,n)
		var ca = Math.cos(a)
		var sa = Math.sin(a)
		sp.vx = ca*p
		sp.vy = sa*p
		updateVV();

	}
	
	function updateVV(){
		vvx = sp.vx*Timer.tmod;
		vvy = sp.vy*Timer.tmod;
	}
	
	function getNormal(bx,by,bdir,ray){
		
		
		// GET SIDE LIST
		var sideList = [[bdir.x,bdir.y]]
		for( var i=0; i<2; i++){
			var px = bx;
			var py = by;
			var dir = { x:bdir.x, y:bdir.y }
			var sens = i*2-1
			for( var n=0; n<ray; n++ ){
				var f = turn(dir,sens)
				var nx = px+f.x;
				var ny = py+f.y;
				if(!Cs.game.isFree(nx,ny)){
					dir = f
				}else{
					if(Cs.game.isFree(nx+dir.x,ny+dir.y)){
						px = nx+dir.x;
						py = ny+dir.y;
						dir = turn(dir,-sens)
					}else{
						px = nx;
						py = ny;
					}
				}
				sideList.push([dir.x,dir.y])
				
				//markPoint(px,py)
			
			}
			
		}
		
		// GET ANGLE
		var dx = 0;
		var dy = 0;
		for( var i=0; i<sideList.length; i++ ){
			var dir = sideList[i]
			dx += dir[0];
			dy += dir[1];
		}
		// RETUUUUUUUUUUUUURN !
		return Math.atan2(dy,dx)
		
	}
	
	function bounceAngle(a,n){
		
		
		var da = Cs.hMod((n-a),3.14)
		var dx = Math.cos(da)
		var dy = Math.sin(da)
		var na = Math.atan2(dy,-dx)
		return Cs.hMod(n-na,3.14)
	}
	
	function turn(d,sens){
		return { x:-d.y*sens, y:d.x*sens }
	}
	
	function isRoundFree(x,y){
		for( var i=0; i<pList.length; i++ ){
			var dec = pList[i]
			var p = {x:x+dec.x,y:y+dec.y}
			if(!Cs.game.isFree(p.x,p.y))return p;
			//markPoint(x+dec.x,y+dec.y)
		}
		return null;
	}
	

	
	
	// MARKER
	
	function markAngle(a){
		var mc = Cs.game.dm.attach("mcVector",Game.DP_PART)
		mc._x = px+ox;
		mc._y = py+oy;
		mc._rotation = a/0.0174
		mList.push(mc)
	}
		
	function markPoint(x,y){
		var mc = Cs.game.dm.attach("mcMark",Game.DP_PART)
		mc._x = x;
		mc._y = y;
		mList.push(mc)
	}
	
	
	
	
//{	
}