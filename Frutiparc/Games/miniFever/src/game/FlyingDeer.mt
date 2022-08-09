class game.FlyingDeer extends Game{//}
	
	// CONSTANTES
	static var RAY = 22;
	// VARIABLES
	var cx:float;
	var angle:float;
	var speed:float;
	var posList:Array<{x:float,y:float,r:float}>
	var hList:Array<sp.Phys>
	var cList:Array<MovieClip>
	var fList:Array<MovieClip>
	var cloudList:Array<MovieClip>
	
	// MOVIECLIPS
	var shade:MovieClip;
	var line:MovieClip;
	var kite:sp.Phys;

	function new(){
		super();
	}

	function init(){
		gameTime = 400
		super.init();
		airFriction = 0.92
		angle = -1.57
		speed = 2+(dif*0.03)
		
		
		attachElements();
	};
	
	function attachElements(){
		
		// SHADE
		shade = dm.attach("mcKiteShade",Game.DP_SPRITE)
		shade._x = Cs.mcw*0.5
		shade._y = Cs.mch
		
		// LIGNE
		line = dm.empty(Game.DP_SPRITE);
		
		// KITE
		kite = newPhys("mcKite")
		kite.x = Cs.mcw*0.5
		kite.y = Cs.mch-30
		kite.flPhys = false;
		kite.init();
		
		// KYTE FLY
		fList = new Array();
		for( var i=0; i<4; i++ ){
			var mc = dm.attach("mcKyteFly",Game.DP_SPRITE)
			//Log.trace(mc)
			mc.gotoAndStop(string(i+1))
			fList.push(mc)
			
		}
		posList = new Array();
		var last = {x:kite.x,y:kite.y+speed,r:-90}
		while(posList.length<50){
			var pos = {x:last.x,y:last.y+speed,r:-90}
			posList.push(pos)
			last = pos
		}
		

		// HANDS
		hList = new Array();
		for( var i=0; i<2; i++ ){
			var sp = newPhys("mcKiteHand")
			sp.x = Cs.mcw*0.5
			sp.y = Cs.mch
			sp.flPhys = false;
			sp.init();
			sp.skin.stop();
			hList.push(sp)
		}	

		// CORDES
		cList = new Array();
		for( var i=0; i<2; i++ ){
			var mc = dm.attach("mcKiteRope",Game.DP_SPRITE)
			cList.push(mc)
		}
		
		// ** CLOUDS **
		cloudList = new Array();
		for( var i=0; i<3; i++){
			var mc = Std.getVar(this,"$c"+i)
			cloudList.push(mc)
		}
	
		
	}
	
	function update(){
		
		speed *= 1.001
		
		cx = Cs.mm(0,(_xmouse/Cs.mcw),1)
		moveHands();
		moveKite();
		moveClouds();

		
		switch(step){
			case 1:
				break;
		}
		super.update();
	}

	function moveHands(){
		//line.clear();
		for( var i=0; i<2; i++ ){
			var sp = hList[i]
			
			// MOVE
			var m = 8
			var p ={
				x:m+cx*(Cs.mcw-2*m)+(i*2-1)*35
				y:(Cs.mch+20)-(1-(kite.y/Cs.mch))*50
			}
			sp.towardSpeed(p,0.1,0.5)
			
			// ANIM
			var a = sp.getAng(kite)+1.57
			var frame = 17+int(Cs.mm(-1, a ,1)*16)
			sp.skin.gotoAndStop(string(frame))
			
			
			// CORDE
			var p0 = {
				x:sp.x+downcast(sp.skin).v._x
				y:sp.y+downcast(sp.skin).v._y
			}
			
			var a2 = angle+1.57*(i*2-1)
			var p1 = {
				x:kite.x+Math.cos(a2)*RAY
				y:kite.y+Math.sin(a2)*RAY
			}

			var rope = cList[i]
			rope._x = p0.x;
			rope._y = p0.y;

			var dx = p1.x - p0.x
			var dy = p1.y - p0.y
			
			var ang = Math.atan2(dy,dx)
			var dist = Math.sqrt(dx*dx+dy*dy)
						
			rope._rotation = ang/0.0174
			rope._xscale = dist;
			
			//Log.print(rope._x+";"+rope._y)
			
			//line.lineStyle(1,0x000000,100)
			//line.moveTo(p0.x,p0.y)
			//line.lineTo(p1.x,p1.y)
			
			
			
		}
	}
	
	function moveKite(){
		var lim = 0.5
		
		if(step!=2)angle += Cs.mm(-lim,(cx*2-1)*0.1,lim)*Timer.tmod;
		
		var sp = speed * (1+(kite.y/Cs.mch)*0.5)
		
		kite.skin._rotation = angle/0.0174
		kite.vitx = Math.cos(angle)*sp
		kite.vity = Math.sin(angle)*sp
		
		//
		var px = kite.x + Math.cos(angle+3.14)*40
		var py = kite.y + Math.sin(angle+3.14)*40	
		
		line.clear();
		line.lineStyle(1,0xDDDDAA,50)
		line.moveTo(px,py)
		for( var i=0; i<fList.length; i++ ){
			var mc = fList[i]
			var pos = posList[posList.length-(3+i*4)]
			mc._x = pos.x
			mc._y = pos.y
			mc._rotation = pos.r+90
			line.lineTo(pos.x,pos.y)
		}
		

		posList.push({x:px,y:py,r:kite.skin._rotation})
		while(posList.length>50)posList.shift();
		
		//
		shade._x = kite.x
		
		//
		var m = 10
		var g = 10
		if( kite.x > Cs.mcw+m || kite.x < -m || kite.y <-m || kite.y > Cs.mch-g ){
			setWin(false)
			step = 2;
			if(kite.y> Cs.mcw-g){
				kite.vity*=-0.5
				angle = Math.atan2(kite.vity,kite.vitx)
			}
		}
		
		//
		
	}
	
	function moveClouds(){
		for( var i=0; i<cloudList.length; i++){
			var mc = cloudList[i]
			mc._x += (0.3-i*0.1)*Timer.tmod
			
		}	
	}
	
	function outOfTime(){
		setWin(true)
	}
	
	
//{	
}

















