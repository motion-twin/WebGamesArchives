class game.BallSeeker extends Game{//}
	
	// CONSTANTES
	static var RAY = 11
	static var FRAY = 15
	static var MRAY = 13
	
	// VARIABLES
	var gl:float;
	var speed:float;
	var fList:Array<{>MovieClip,fleur:MovieClip,ray:MovieClip,rm:bool,dec:float}>
	var mList:Array<MovieClip>
	
	var power:float;
	var pc:float;
	
	// MOVIECLIPS
	var ball:sp.Phys
	var shade:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 450;
		super.init();
		gl = Cs.mch-6
		speed = 0
		power = 20
		pc = 1
		airFriction = 1
		attachElements();
	};
	
	function attachElements(){

		// FLOWER
		fList = new Array();
		
		for( var i=0; i<3; i++){
			var mc = downcast(dm.attach("mcBallSeekerFlower",Game.DP_SPRITE))
			while(mc._x == 0 || Math.abs(mc._x-Cs.mcw*0.5) < 30 )mc._x = FRAY+Math.random()*(Cs.mcw*2-FRAY*2);
			mc._y = FRAY+Math.random()*100
			mc._xscale = 75
			mc._yscale = 75
			mc.dec = Math.random()*628;
			mc.rm = false;
			fList.push(mc)
		}
		
		// MONSTER
		mList = new Array();
		var max = Math.floor(dif*0.07)
		for( var i=0; i<max; i++){
			var mc = downcast(dm.attach("mcBallSeekerBomb",Game.DP_SPRITE))
			while(mc._x == 0 || Math.abs(mc._x-Cs.mcw*0.5) < 30 )mc._x = MRAY+Math.random()*(Cs.mcw*2-MRAY*2)
			mc._y = MRAY+Math.random()*(Cs.mch-MRAY*3)
			mList.push(mc)
		}

		// SHADE
		shade = dm.attach("mcBallSeekerShade",Game.DP_SPRITE)
		shade._x = Cs.mcw*0.5
		shade._y = gl
		
		// BALL
		ball = newPhys("mcBallSeeker")
		ball.x = Cs.mcw*0.5;
		ball.y = Cs.mch*0.5;
		ball.weight = 1
		ball.init();
		ball.skin.stop();
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				updateBall();
				updateFlower();
				//
				for( var i=0; i<mList.length; i++ ){
					var mc = mList[i]
					var dist = ball.getDist({x:mc._x,y:mc._y})

					if(dist<MRAY+RAY){
						pc = 0.01

						var p = newPart("partSeekerPlouch")
						p.x = mc._x;
						p.y = mc._y;
						p.flPhys = false;
						p.init()
						
						
						
						mc.removeMovieClip();
						mList.splice(i--,1)
						
						
					}

				}
				
				//
				if(fList.length==0)setWin(true);
				
				
				// SCROLL
				var sx = Cs.mm( -Cs.mcw ,-(ball.x-Cs.mcw*0.5), 0 ) - _x
				_x += sx*0.1*Timer.tmod
				
				
				
				
				
				
				break;
				
				
				
		}
		
		
		
	}
	
	function updateBall(){
		var dx = this._xmouse - ball.x
		speed += dx*0.01*Timer.tmod*pc;
		speed *= Math.pow(0.9,Timer.tmod)
		ball.skin._rotation += speed*8*Timer.tmod
		
		pc = Math.min((pc+0.003)*1.008,1)
			if( ball.y+RAY > gl ){
			ball.y = gl-RAY
			ball.vity = -power*pc
			ball.vitx = speed
		}
		
		var bound = -0.8
		if( ball.x < RAY || ball.x > Cs.mcw*2 - RAY ){
			ball.x = Cs.mm(RAY,ball.x,Cs.mcw*2 - RAY)
			ball.vitx *= bound
		}
		//
		var frame = "1"
		if(pc<0.5){
			frame = "2"
			if(Std.random(int(20*pc))==0){
				var p = newPart("partSeekerKofKof")
				p.x = ball.x+(Math.random()*2-1)*RAY*0.8;
				p.y = ball.y+(Math.random()*2-1)*RAY*0.8;
				
				p.weight = -(0.1+Math.random()*0.1)
				p.vitx = (Math.random()*2-1)*1.5
				p.init()
				p.skin._rotation = Math.random()*360
			}
		}
		ball.skin.gotoAndStop(frame)
		
		//
		downcast(ball.skin).light._rotation = -ball.skin._rotation
		
		//
		ball.skin._x = ball.x
		ball.skin._y = ball.y
		
		shade._x = ball.x
	}
	
	function updateFlower(){
		var flDone = true;
		for( var i=0; i<fList.length; i++ ){
			var mc = fList[i]
			var dist = ball.getDist({x:mc._x,y:mc._y})
			
			mc.dec = (mc.dec+40)%628
			mc.fleur._rotation += Timer.tmod*1.5
			mc.ray._rotation += Timer.tmod
			
			
			if(mc.rm){
				mc._xscale *= 0.5
				mc._yscale = mc._xscale
				if(mc._xscale < 2){
					mc.removeMovieClip();
					fList.splice(i--,1)
				}						
			}else{
				if(dist<FRAY+RAY){
					mc.rm = true;
					mc.fleur._visible = false;
					for( var n=0; n<8; n++ ){
						var p = newPart("partRayArc")
						p.x = mc._x;
						p.y = mc._y;
						p.vitr = 0.5+Math.random()*4
						p.flPhys = false;
						p.timerFadeType = 2
						p.timer = 10+Math.random()*10
						p.init();
						p.skin._rotation = Math.random()*360
						p.skin._xscale = 60+Math.random()*80
					}
					
				}
				flDone = false;
			}
		}
		if(flDone)flTimeProof = true;
	}
	
	

//{	
}

