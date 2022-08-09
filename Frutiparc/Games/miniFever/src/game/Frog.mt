class game.Frog extends Game{//}
	
	// CONSTANTES
	var mancheSize:int;
	var canneSize:int;
	var limit:int;
	var gl:int;
	var tensionMax:int;
	var nerveMax:int;
	
	// VARIABLES
	var flEat:bool;
	var nerve:float;
	var dx:float;
	var dy:float;
	var cRot:float;
	var bRot:float;
	var looseTimer:float;
	var camBox:{ xMin:float, xMax:float, yMin:float, yMax:float, cx:float, sp:float };
	var ob:{x:float,y:float}
	
	// MOVIECLIPS
	var decor:MovieClip;
	var fil:MovieClip;
	var frog:sp.Phys;
	var bait:sp.Phys;
	var canne:Sprite;

	function new(){
		super();
	}

	function init(){
		
		gameTime = 360
		super.init();
		
		mancheSize = 30
		canneSize = 80
		tensionMax = 80;
		limit = 700
		gl = Cs.mch-10
		cRot = -1.57;
		bRot = 0;
		nerveMax = 1000
		nerve = nerveMax;
		flEat = false;
		camBox = {xMin:-9999,xMax:9999,yMin:0,yMax:0,cx:0.1,sp:1}
		attachElements();
		ob = {x:bait.x,y:bait.y}
	};
	

	function attachElements(){
		
		// FROG
		frog = newPhys("mcFrog")
		frog.x = limit-(50+dif*2)
		frog.y = gl
		frog.weight = 1
		frog.flPhys = false;
		//frog.skin._xscale = frog.skin._yscale = 80
		frog.init();
		
		// CANNE
		canne = newSprite("mcCanne");
		canne.x = Cs.mcw*0.5
		canne.y = Cs.mch*0.5
		canne.skin._rotation = cRot/0.0174
		canne.init();
		
		// APPAT
		bait = newPhys("mcFrogBait")
		bait.x = Cs.mcw-0.5;
		bait.y = Cs.mch-0.5;
		bait.weight = 0.7;
		bait.init();
		
		// FIL
		fil = dm.empty(Game.DP_SPRITE)
		
		// DECOR
		decor = dm.attach( "mcFrogDecor", Game.DP_SPRITE )
		decor._y = gl;		
		
		
	}
	//
	function update(){
		super.update();
		switch(step){
			case 1:

				//
				moveCam();
				moveCanne();	

				//
				checkFrog()

				ob = {x:bait.x,y:bait.y}
			
				break;
			case 2:
				moveCam();
				moveCanne();
				
				//
				if(flEat){
					frog.x = bait.x
					frog.y = bait.y
					
					var dr = -90 - frog.skin._rotation
					frog.vitr += dr*0.01*Timer.tmod
					
					//Log.print(frog.vitr)
					
				}else{
					
					checkLand();
					if(frog.flPhys){
						frog.alignRot();
						checkEat();
					}
				}
				//
				if(looseTimer!=null){
					looseTimer -= Timer.tmod
					if(looseTimer<0){
						setWin(false);
						looseTimer = 0;
					}
				}
				
				
				break;
				
				
				
		}
		//
		canne.skin._x = canne.x
		canne.skin._y = canne.y
		bait.skin._x = bait.x
		bait.skin._y = bait.y
	
	}
	//
	function moveCam(){
	
		var c = camBox.sp
		
		var x = Cs.mcw*camBox.cx - frog.x
		var y = Cs.mch*0.5 - frog.y
		
		var dx = x - this._x
		var dy = y - this._y

		this._x = Math.min( Math.max ( camBox.xMin, this._x+dx*c*Timer.tmod  ), camBox.xMax )
		this._y = Math.min( Math.max ( camBox.yMin, this._y+dy*c*Timer.tmod ), camBox.yMax )

		
	}
	
	function moveCanne(){
		// ROT
		//*
		var tr = -1//-1.8
		if(base.flPress) tr = -2.7;
		var dr = tr-cRot
		cRot += dr*0.2*Timer.tmod 
		//*/
		canne.skin._rotation = cRot/0.0174
		
		
		// MOVE
		canne.toward( {x:_xmouse,y:_ymouse}, 0.5, null )
		
		// DRAW CANNE
		var cs = getCanneSize();
		canne.skin.clear();
		canne.skin.lineStyle(3,0x8B6830,100)
		canne.skin.moveTo(mancheSize,0)
		var x  = Math.cos(bRot)*cs + mancheSize
		var y  = Math.sin(bRot)*cs
		canne.skin.curveTo( mancheSize+cs*0.8, 0, x, y )
		

		//
		
		var bx = canne.x + Math.cos(cRot)*mancheSize
		var by = canne.y + Math.sin(cRot)*mancheSize
		
		var px = bx + Math.cos(cRot+bRot)*(canneSize-Math.abs(bRot)*10)
		var py = by + Math.sin(cRot+bRot)*(canneSize-Math.abs(bRot)*10)
		
		// BAIT + TENSION
		var dx = px - bait.x
		var dy = py - bait.y

		var dist = Math.sqrt(dx*dx+dy*dy)
		var a = Math.atan2(dy,dx)
		var g = null
		var pression = null
		if( dist > tensionMax ){
			var c = (dist-tensionMax)/tensionMax
			var p = 20

			pression  = { a:a, p:c*p }

			bait.vitx += Math.cos(a)*c*p
			bait.vity += Math.sin(a)*c*p
			
			
			
			var lim = 0.2
			if(c>lim){
				bait.x = px - Math.cos(a)*tensionMax*(1+lim)
				bait.y = py - Math.sin(a)*tensionMax*(1+lim)
			
			}
		}else{
			g = (tensionMax-dist)*0.5
		}
		
		bait.vitx *= Math.pow(0.95, Timer.tmod)
		bait.vity *= Math.pow(0.95, Timer.tmod)
		
		
		
		// TENSION BOIS
		if( pression != null ){
			var sa = pression.a-cRot
			var pr = Math.sin(sa+3.14)*pression.p			
			bRot += pr*0.02*(bait.weight+(flEat?2:0))*Timer.tmod
		}
		bRot *= 0.9
		
		// DRAW
		fil.clear();
		fil.lineStyle(1,0xFFFFFF,100)
		fil.moveTo(px,py)
		if(g==null){
			fil.lineTo(bait.x,bait.y)
		}else{
			var mx = (bait.x+px)*0.5
			var my = (bait.y+py)*0.5 + g
			fil.curveTo(mx,my,bait.x,bait.y)
		}	
		
		
	}
	
	function getCanneSize(){
		return canneSize-Math.abs(bRot)*15
	}
	
	function checkFrog(){
		nerve = Math.min(nerve+2*Timer.tmod,1000);			
		var d1 = frog.getDist(bait);
		var d2 = bait.getDist(ob)
		var c = Math.max(0,180-d1)/180
		nerve -= c*d2*8*Timer.tmod
		
		if( nerve < 0 ){
			initJump();
		}else{
			var frame = 20-Math.round((nerve/nerveMax)*10)
			frog.skin.gotoAndStop(string(frame))
		}
		
		// EYES
		var a = frog.getAng(bait)
		var f = downcast(frog.skin)
		f.h.h.o.p._x = 1.8 * (1-c) * Math.cos(a)
		f.h.h.o.p._y = 1.8 * (1-c) * Math.sin(a)		
		
	}
	
	function initJump(){
		step = 2;
		var a = frog.getAng(bait)
		var d = frog.getDist(bait)
		var p = 16+d*0.02//Math.max( 24, d*0.2 )
		frog.vitx += Math.cos(a)*p
		frog.vity += Math.sin(a)*p
		frog.flPhys = true;
		frog.skin.gotoAndPlay("jump")
		camBox.yMin = -200
		camBox.yMax = 0
		camBox.cx = 0.5
		camBox.sp = 0.2
		camBox.xMax = -(frog.x)
		flTimeProof = true;
		//camBox.xMax = 0//-(frog.x-24) 		
	}

	function checkEat(){
		var d = frog.getDist(bait)
		if( d < 20 ){
			flEat = true;
			bait.vitx += frog.vitx
			bait.vity += frog.vity
			bait.skin._visible = false;
			frog.flPhys = false;
			frog.vitx = 0;
			frog.vity = 0;
			frog.vitr = 0;
			frog.skin.gotoAndStop("eat")
			camBox.sp = 0

			looseTimer = 12
		}
	}
	
	function checkLand(){
		var g = gl
		if( frog.x > limit ) g += 120;
		if( frog.y > g ){
			frog.y = g;
			frog.flPhys = false;
			frog.vitx = 0;
			frog.vity = 0;
			if( g == gl ){
				frog.skin.gotoAndStop("1");
				frog.skin._rotation = 0;
				setWin(false)
			}else{
				setWin(true)
				for( var i=0; i<20; i++ ){
					var mc = newPart("mcPartDirt")
					mc.x = frog.x
					mc.y = frog.y
					mc.vitx = 5*(Math.random()*2-1);
					mc.vity = -(3+Math.random()*6);
					mc.scale = 30+Std.random(60);
					mc.weight = 0.5;
					mc.init();
				
				}
			}
		}
		
		
	}
	
	
//{	
}












