class Piou extends Phys{//}
	
	static var FL_DEBUG = false;
	
	static var RAY = 6
	
	static var FLY = 0
	static var WALK = 1
	static var FALL = 2
	static var CLIMB = 6
	static var EXIT = 3
	static var ACTION = 10
	static var SPEED = 0.7
	
	static var ORIENT = 20
	static var BREAK = 0.25
	static var WEIGHT = 0.3
	
	static var FALL_BOUNCE_LIMIT = 4
	static var FALL_DEATH_LIMIT = 7
	
	static var WALK_FRAME = 16
	
	static var CLIMBER = 0
	static var PSIONIC = 1
	static var STUNTMAN = 2
	static var RUNNER = 3

	var sPower:int;
	
	var flDeath:bool;
	var flOut:bool;
	
	var speed:float;
	var frame:float;
 	
	var sens:int
	var step:int;
	var px:int;
	var py:int;
	var gid:int;
	var noSelection:int;
	
	var vx:float;
	var vy:float;
	var rot:float;
	var parc:float;
	var outTest:float;

	var angle:float;
	var coefAngle:float;
	var exitSpot:{x:int,y:int};
	var exitMask:MovieClip;
	var currentAction:ac.Piou;
	
	var debugSquare:MovieClip;
	var mcArrow:MovieClip;
	//var mcCircle:MovieClip
	
	function new(mc){
		mc = Cs.game.dm.attach( "mcPiou" ,Game.DP_PIOU)
		super(mc)
		
		//
		weight = 0.3
		speed = SPEED
		frict = 0.97
		
		//
		flOut = true;
		//
		outTest = 0
		sens = 1
		gid = 1
		initStep(FLY)
		frame=0;
		
		//
		Cs.game.pList.push(this)
		//
		Cs.game.piouOut++
		Inter.updateScorePanel()
		
		if(FL_DEBUG){
			debugSquare = Cs.game.dm.attach("mcDebugSquare",Game.DP_PART)
		}
		
		
	}
	
	function initStep(n:int){
		
		switch(step){
			case FLY:
				bouncer = null;
				weight = 0
				downcast(root).sub._rotation = 0;
				break;
			case WALK:
				mcArrow._visible = false;
				root._rotation = 0
				break;
			case FALL:
				bouncer = null;
				weight = 0
				break;
			case EXIT:
				Log.trace("UNDEAD ERROR !")
		}
		
		step = n
		switch(step){
			case FLY:
				root.gotoAndStop("fly")
				vx = 0;
				vy = 0;
				weight = WEIGHT
				bouncer = new Bouncer(this);
				bouncer.onBounceGround = callback(this,land,false)
				downcast(root).sub._rotation = Math.random()*360
				break;
			
			case WALK:
				mcArrow._visible = true;
				initWalkState();
				root.gotoAndStop("walk");
				
				break;
			
			case FALL:
				vx = 0;
				vy = 1;
				weight = WEIGHT;
				bouncer = new Bouncer(this);
				bouncer.onBounce = callback(this,land,true);
				break;
				
			case EXIT:
				//gid = 0
				root.removeMovieClip();
				root = Cs.game.dm.attach( "mcPiou" ,Game.DP_OUT);
				root.gotoAndStop("fly");
				root._x = x;
				root._y = y;
				coefAngle = 0.1;
				downcast(root).sub._rotation = Math.random()*360;
				angle = Math.atan2(vy,vx);
				flOut = false;
				Cs.game.piouOut--;
				Cs.game.piouIn++;
				Cs.game.endTime = Cs.game.btimer*32//Std.getTimer()- Cs.game.startTime
				Inter.freezeTimer();
				Inter.updateScorePanel();
				Cs.game.pList.remove(this);
				Cs.game.deathList.push(this);
				updateColor(root);
				
				break;
		}
	}
	
	function initWalkState(){
		parc = 0
		vx = 0;
		vy = 0;			
		px = int(x)
		py = int(y)
		var cl = 0
		
		while( Level.isFree(px,py+1) ){
			py++
			if( cl++ > CLIMB )break;
		}
		y = py
		
	}
	
	function reverse(){
		
		sens *= -1;
		root._xscale = 100*sens
	}
	
	function update(){
		
		super.update();
		switch(step){
			case FLY:
				
				if(currentAction==null)downcast(root).sub._rotation += 8*Timer.tmod;
				checkExit();
				checkLim();
				break;
			
			case WALK:
				
				if( sPower == CLIMBER ){
					climb();
				}else{
					walk();
				}
				//
				frame = (frame+speed*1.5)%WALK_FRAME
				downcast(root).sub.gotoAndStop(string(int(frame)+1))
				//
				checkExit();
				checkLim();
				break;
			
			case FALL:
				checkExit();
				checkLim();
				break;

			case EXIT:
				downcast(root).sub._rotation += 8*Timer.tmod
				exitFly();
				break;
			case ACTION:
				//Log.print("!")
				checkExit();
				checkLim();
				break;
			
		}
		// NO SELECTION
		if(noSelection!=null){
			noSelection--;
			if(noSelection==0)noSelection = null;
		}
		
		// CAISSE
		for( var i=0; i<Cs.game.cList.length; i++){
			var c = Cs.game.cList[i]
			if(this.getDist(c)<14){
				c.activate();
			}
		}
		
		// DEBUG
		if(FL_DEBUG){
			debugSquare._x = px
			debugSquare._y = py
		}
		
		
	}
	
	function checkLim(){
		var rad = 1
		if( x<0 )		explode(0,rad);	
		if( x>Level.bmp.width )	explode(3.14,rad);	
		if( y<0 )		explode(1.57,rad);	
		if( y>Level.bmp.height )explode(-1.57,rad);			
	}
	
	function checkExit(){
		outTest -= Timer.tmod
		
		if( outTest < 0 ){
			outTest = 200
			for( var i=0; i<Cs.game.outList.length; i++ ){
				var mc = Cs.game.outList[i];
				var p = {x:int(mc._x),y:int(mc._y)}
				var dist = getDist(p);
				outTest = Math.min((dist-50)*0.2,outTest)
				if( dist < 30 && currentAction.flExclu!=true ){
					if(currentAction!=null)currentAction.interrupt();
					exitSpot = p;
					if(step==WALK){
						vx = sens
						vy = 0
					}
					initStep(EXIT);
					return;
				}else{
					if(step!=WALK)outTest*=0.25;
				}
			}
		}	
	}
	
	function walk(){
		parc += speed
			
		while( parc>1 ){
			rot = 0
			parc--
			px += sens
			if( !Level.isFree(px,py) ){
				var flReturn = true;
				for( var by=1; by<=CLIMB; by++ ){
					if( Level.isFree(px,py-by) ){
						py -= by
						flReturn  = false;
						rot = -by*ORIENT*sens
						parc-= by*BREAK
						break;
					}
				}
				if(flReturn){
					
					reverse();
					px += sens
					if(!Level.isFree(px,py))py--;
					
				}
			}else{
				if( Level.isFree(px,py+1) ){
					var flFall = true
					for( var by=1; by<=CLIMB; by++ ){
						if( !Level.isFree(px,py+by+1) ){
							py += by
							flFall  = false;
							rot = by*ORIENT*sens
							parc-= by*BREAK
							break;
						}
					}
					if(flFall){
						if( sPower==RUNNER && Level.isFree(px,py-1) ){
							jump();
						}else{
							x = px;
							y = py;						
							fall();
						}
					}
				}
			}
		}
		x = px;
		y = py;
		
		var drot = rot - root._rotation
		//root._rotation += drot*0.3*Timer.tmod;
	}
	
	function jump(){
		var ac = new ac.piou.Jump(x,y)
		downcast(ac).piou = this;
		ac.init();
		vx *= 0.6
		vy *= 0.5

	}
	
	function climb(){

		
		var trot = (gid-1)*90
		parc += speed*Timer.tmod;
		
		if(parc>0 && !Level.isFree(px,py)){
			parc = 0
			py--;
		}
		
		while( parc>1 ){
			parc--
			
			var fwd = Cs.DIR[ Cs.sMod(gid-sens,4) ]
			var sky = Cs.DIR[ Cs.sMod(gid+2,4) ]
			var grd = Cs.DIR[ gid ]
			
			px += fwd[0]
			py += fwd[1]
			
			var clv = CLIMB
			if(gid!=1)clv*=0.5;
			
			if( !Level.isFree(px,py) ){
				var flReturn = true;
				for( var by=1; by<=clv; by++ ){
					if( Level.isFree( px+sky[0]*by, py+sky[1]*by ) ){
						px += sky[0]*by
						py += sky[1]*by
						flReturn  = false;
						parc-= by*BREAK
						//trot -= ORIENT*by*sens
						break;
					}
				}
				if(flReturn){
					gid = Cs.sMod(gid-sens,4)
					px -= fwd[0];
					py -= fwd[1];
					if( gid == 3 ){
						gid = 1
						reverse();
						x = px;
						y = py;
						fall();
					}
					
					//if(!Level.isFree(px,py))py--;
					
				}
				
			}else{
				if( Level.isFree( px+grd[0], py+grd[1] ) ){
					var flFall = true
					for( var by=1; by<=clv; by++ ){
						if( !Level.isFree( px+grd[0]*by, py+grd[1]*by+1) ){
							px += grd[0]*by
							py += grd[1]*by
							flFall  = false;
							parc-= by*BREAK
							//trot += ORIENT*by*sens
							break;
						}
					}
					if(flFall){
						x = px;
						y = py;							
						if(gid==1){
							fall();
						}else{
							gid = Cs.sMod(gid+sens,4)
						}
					}
				}
			}
		}
		x = px;
		y = py;
		
		var drot = Cs.hMod(trot - root._rotation,180)
		root._rotation += drot*0.3
	
	}
	
	function exitFly(){
		var sp = 0.5
		var dx = exitSpot.x - x;
		var dy = exitSpot.y - y;
		var ta = Math.atan2(dy,dx)
		var da = Cs.hMod(ta-angle,3.14)
		
		coefAngle = Math.min(coefAngle+0.01,1)
		angle += da*coefAngle
		vx += Math.cos(angle)*sp
		vy += Math.sin(angle)*sp
		
		frict = 0.95
		
		var dist = Math.sqrt(dx*dx+dy*dy)
		var scale = Math.min(dist*8,root._xscale)
		var ds = scale-root._xscale
		root._xscale += ds*0.3;
		root._yscale = root._xscale;
		//Log.print(scale)
		if(scale<10){
			exitMask.removeMovieClip();
			Cs.game.deathList.remove(this);
			kill();
		}
		if(exitMask==null && dist<18){
			exitMask = Cs.game.dm.attach("mcOutMask",Game.DP_PIOU)
			exitMask._x = exitSpot.x;
			exitMask._y = exitSpot.y;
			root.setMask(exitMask)				
		}
					
	}
	
	function land(flControl){
		var pw = Math.sqrt(vx*vx+vy*vy)
		
		if(  pw< FALL_BOUNCE_LIMIT ){

			initStep(WALK)
		}else if( pw<FALL_DEATH_LIMIT){
			if( flControl || sPower == Piou.STUNTMAN ){
				initStep(WALK)
			}
		}else{
			if(sPower == Piou.STUNTMAN){
				smoke();
				initStep(WALK)
			}else{
				var p = Cs.game.newPart("partSplatch")
				p.setScale(42)
				p.x = x;
				p.y = y+3;
				p.updatePos();
				explode(-1.57,1.57)
			}
		}
		
	}
	
	function smoke(){
		for( var i=0; i<5; i++ ){
			var dx = (Math.random()*2-1)*14
			var p = Cs.game.newPart("mcNuage")
			p.x = x + dx
			p.y = y
			p.setScale(150-Math.abs(dx)*5)
			p.vy = -Math.random()
			p.vr = dx
			Cs.game.dm.under(p.root)
		}
	}

	function initWalk(){
		initStep(WALK)
	}
	
	function fall(){
		initStep(FALL)
		root.gotoAndStop("fall")
		vy = 1
	}
	
	//
	/*
	function setClimber(){
		flClimber = true;
		var m = [
				1,	0,	0,	0,	0,
				0,	1,	0,	0,	50,
				0,	0,	0.8,	0,	0,
				0,	0,	0,	1,	0 
		]
		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix= m;
		root.filters = [fl]
	}
	*/
	
	function setSupaPowa(n){
		switch(sPower){
			case CLIMBER:
				if(gid!=1){
					fall();
					gid = 1
				}
				root._rotation = 0;
				break;
			case RUNNER:
				speed = SPEED
				break;				
		}
		sPower = n
		switch(sPower){
			case RUNNER:
				speed = 2
				break;
		}		
		/*
		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix= Cs.PIOU_COLOR_MATRIX[sPower]
		root.filters = [fl]
		*/
		updateColor(root);
		
		// PART
		for( var i=0; i<12; i++ ){
			var p = Cs.game.newPart("partPaint");
			var a = Math.random()*6.28;
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var ray = 2+Math.random()*8
			var speed = Math.random()*0.5
			p.x = x + ca*ray; 
			p.y = y + sa*ray - RAY;
			p.vx = ca*speed;
			p.vy = sa*speed;
			p.setScale(30+Math.random()*100);
			Cs.setColorMatrix( p.root, Cs.PIOU_COLOR_MATRIX[sPower], -50 );
			p.timer = 10+Math.random()*10;
			p.root.blendMode = BlendMode.ADD
		}
		
		
	}
	
	function updateColor(mc){
		Cs.setColorMatrix( mc, Cs.PIOU_COLOR_MATRIX[sPower], null );	
	}
	
	//
	function point(){
		mcArrow = Std.attachMC(root,"mcHelpArrow",31)//dm.attach("mcHelpArrow",1)
		mcArrow._rotation = 90
		mcArrow._y = -(RAY+6)
		mcArrow._xscale = 75
		mcArrow._yscale = 75
		mcArrow._visible = step == WALK
	}
	//
	function die(){
		flDeath = true;
		kill();
	}
	
	function explode(ba,ra){
		gerb(ba,ra,18,6)
		die();
	}
	
	function gerb(ba,ra,max,power){
		var ray = 4
		var lim = Cs.game.sList.length
		if(lim>40){
			max *= (40/lim)
		}
		
		
		for( var i=0; i<max; i++ ){
			var a = ba+(Math.random()*2-1)*ra
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var sp = 0.5+Math.random()*power
			var p = getGib( x+ca*ray, y+sa*ray );
			p.vx = ca*sp
			p.vy = sa*sp
			p.root.filters = root.filters
		}
	}
	
	function getGib(px,py){
		var p = Cs.game.newPart("mcDebris")
		p.x = px
		p.y = py	
		p.weight = 0.1+Math.random()*0.1
		p.setScale(40+Math.random()*80)
		p.timer = 10+Math.random()*30
		p.fadeType = 0
		Cs.setColor(p.root, 0xFFC1C1 ,-255)
		p.bouncer = new Bouncer(p)
		if(!Level.isFree(int(p.x),int(p.y))){
			p.kill();
		}	
		return p;		
	}
	
	
	function kill(){
		if(flOut)Cs.game.piouOut--;
		Inter.updateScorePanel();
		Cs.game.pList.remove(this)
		super.kill()
		
	}
	
	
	
//{
}