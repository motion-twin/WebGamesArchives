class Ent {//}

	var dm:DepthManager;
	var root:MovieClip;
	
	
	var flGround:bool;
	var flCol:bool;
	var flFreezeAnim:bool;
	
	var step:int;
	var sens:int;
	
	var x:int;
	var y:int;
	var cx:int;
	var cy:int;
	var dx:float;
	var dy:float;
	
	var vx:float;
	var vy:float;
	var vr:float;

	var weight:float;
	var friction:float;
	
	var nextAnim:String;
	
	function new(mc) {
		dm = new DepthManager(mc);
		root = mc;
		downcast(mc).obj = this
		flGround=false;
		flFreezeAnim = false;
		flCol=true;
		x=0;
		y=0;
		dx=0;
		dy=0;
		cx=0;
		cy=0;
		vx=0;
		vy=0;
		weight=1;
		friction=0.95;
		//step = Cs.ST_FLY
		//root.onPress = callback(this,traceInfo)
		
	}

	function traceInfo(){
		Log.clear()
		Log.setColor(0xFFFFFF)
		Log.trace("step:"+step)
		Log.trace("waitTimer:"+downcast(this).waitTimer)
		Log.trace("pos:("+x+","+y+")")
		Log.trace("vit:("+vx+","+vy+")")
		Log.trace("flGround:"+flGround)
		Log.trace("sens:"+sens)
		
	}
	
	function update() {

		if(!flGround){
			vy+= weight*Timer.tmod
		}
		
		if(friction!=null){
			var frict = Math.pow(friction,Timer.tmod)
			vx*=frict;
			vy*=frict;
		}
		dx+=vx*Timer.tmod;
		dy+=vy*Timer.tmod;
		
		if(vr!=null){
			vr *= 0.95
			root._rotation+=vr*Timer.tmod;
		}
		
		recal();
		
		
		root._x = (x+0.25+(cx*0.5))*Cs.SIZE + dx
		root._y = (y+0.25+(cy*0.5))*Cs.SIZE + dy 
		
		if(nextAnim!=null && !flFreezeAnim  ){
			
			root.gotoAndPlay(nextAnim)
			nextAnim = null
		}
	
	}
	
	function recal(){
		var m  = Cs.SIZE*0.25
		
		var adx = Math.abs(dx)
		var ady = Math.abs(dy)
		
		while( adx>m || ady>m ){
			if(adx>ady){	// HORIZONTAL
				if(dx>0){	// DROITE
					if(cx==0){
						if(x<Game.XMAX-1){
							cx++
							dx-=2*m
							crossSquare();
						}else{
							bang();
							dx = m

						}
					}else{
						leaveSquare()
						cx=0
						dx-=2*m
						x++;
						enterSquare()
					}
				}else{		// GAUCHE
					if(cx==1){
						if(x>0){
							cx--
							dx+=2*m
							crossSquare();
						}else{
							bang();
							dx = -m
							
						}
					}else{
						leaveSquare()
						cx=1
						dx+=2*m
						x--;
						enterSquare()
					}
				}
			}else{		// VERTICAL
				if(dy>0){	// BAS
					if(cy==0){
						if(!checkGround() ){
							cy++
							dy-=2*m
						}else{

							land();
							dy = m
	
						}
					}else{
						leaveSquare()
						cy=0
						dy-=2*m
						y++;
						enterSquare()
					}
				}else{		// HAUT
					if(cy==1){
						cy--
						dy+=2*m
					}else{
						leaveSquare()
						cy=1
						dy+=2*m
						y--;
						enterSquare()
					}
				}
			}
			
			adx = Math.abs(dx)
			ady = Math.abs(dy)
		}
		
		
	
	}
	
	function crossSquare(){
		if(flGround){
			checkFall();
		}
	}
	
	function checkFall(){
		if( !checkGround())fall();
	}
	
	function fall(){
		flGround = false;
	}
	
	function land(){
		//Log.trace("land!")
		flGround = true;
		
		vy = 0		
	}
	
	function bang(){
		vx = 0	
	};
	
	function checkGround(){
		if(!flCol)return false;
		for( var i=0; i<2; i++ ){
			var sens = cx*2-1
			if( !Cs.game.checkFree(x+sens*i,y+1) ){
				//Log.trace((x+sens*i)+","+(y+1))
				return true;
			}
		}
		return false;
	}
	
	function enterSquare(){

	}
	
	function leaveSquare(){
		
	}	

	//
	function setSens(n){
		sens = n
		root._xscale = n*100
		
	}	
	
	//
	function getAng(o){
		var dx = o.root._x - root._x;
		var dy = o.root._y - root._y;
		return Math.atan2(dy,dx)
	}
	function getDist(o){
		var dx = o.root._x - root._x;
		var dy = o.root._y - root._y;
		return Math.sqrt(dx*dx+dy*dy)
	}	
//{
}









