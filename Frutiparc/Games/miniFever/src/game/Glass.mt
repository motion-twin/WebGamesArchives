class game.Glass extends Game{//}
	
	
	
	// CONSTANTES
	static var BRAY = 6
	static var GRAY = 15
	static var FALL = 25
	
	
	// VARIABLES
	var run:float;
	var flWillWin:bool;
	var gy:float;
	var speed:float;
	var timer:float;
	
	// MOVIECLIPS
	var glass:MovieClip;
	var glassBack:MovieClip;
	var gs:sp.Phys;
	var ball:{>sp.Phys,a:float,va:float};
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 320
		super.init();
		airFriction = 0.94
		speed = 1+dif*0.04
		gy = 60
		run = 0
		attachElements();
	};
	
	function attachElements(){
		

		// SHADE
		gs = newPhys("mcGlassShade")
		gs.x = Cs.mcw*0.5
		gs.y = Cs.mch*0.5
		gs.flPhys = false;
		gs.init();
		
		// BACK
		glassBack = dm.attach("mcGlass",Game.DP_SPRITE)
		glassBack.gotoAndStop("2")
		
		// BALL
		ball = downcast(newPhys("mcGlassBall"))
		ball.x = Cs.mcw*0.5//-20
		ball.y = Cs.mch*0.5
		ball.flPhys = false;
		ball.a = 3.14
		ball.va = 0
		ball.init();
		
		// GLASS
		glass = dm.attach("mcGlass",Game.DP_SPRITE)
		glass.gotoAndStop("1")
		
		
		
	}
	
	function update(){
		//
		moveBall();
		switch(step){
			case 1:
				moveGlass();
				//moveBall();
				if(base.flPress){
					step = 2
				}
				break;
			case 2:
				//moveBall();
				
				gy -= FALL*Timer.tmod;
				if( gy < 0 ){
					gy = 0
					var dist = gs.getDist(ball)
					if( dist < GRAY ){
						//setWin(true)
						willWin(true)

					}else{
						//setWin(false)
						willWin(false)

						
						if(ball.y < gs.y )dm.under(ball.skin);
						if(ball.y > gs.y )dm.over(ball.skin);
					}
					
					recalBall();
					
					
				}
				
				break;
			case 3:
				timer -= Timer.tmod;
				if(timer<0){
					flFreezeResult = false;
					setWin(flWillWin);
				}
				break;
		}
		
		super.update();
		//
		gs.skin._y = Cs.mch*0.5 + gs.y*0.5;
		ball.skin._y = Cs.mch*0.5 + ball.y*0.5;
		updateGlassPos();
		//
		
	}
	
	function moveGlass(){
		var mp = {x:_xmouse,y:_ymouse};
		//gs.towardSpeed(mp,0.1,2);
		gs.toward(mp,0.2,null);
	}
	
	function moveBall(){
		ball.va += (Math.random()*2-1)*0.05*Timer.tmod;
		ball.va *= Math.pow(0.92,Timer.tmod)
		ball.a += ball.va*Timer.tmod;
		
		while(ball.a>3.14)ball.a-=6.28;
		while(ball.a<-3.14)ball.a+=6.28;
		
		var vx = Math.cos(ball.a)*speed;
		var vy = Math.sin(ball.a)*speed;
		
		ball.x += vx
		ball.y += vy
		
		// RECAL
		if( ball.x < BRAY || ball.x > Cs.mcw-BRAY ){
			vx *= -1
			ball.a = Math.atan2(vy,vx)
			ball.va *= 0.5
		}
		
		if( ball.y < BRAY || ball.y > Cs.mch-BRAY ){
			vy *= -1
			ball.a = Math.atan2(vy,vx)
			ball.va *= 0.5
		}

		// GFX
		var fr = int(((ball.a/6.28)+0.5)*40)
		ball.skin.gotoAndStop(string(fr+1))
		
		run = ( run + speed*Timer.tmod )%20
		downcast(ball.skin).p0.gotoAndStop(string(int(run)))
		downcast(ball.skin).p1.gotoAndStop(string(int((run+10)%20)))
		
		// RECAL SPECIAL
		if(step==3)recalBall();		
		
	}
	
	function recalBall(){
		var dist = gs.getDist(ball)
		var a = gs.getAng(ball)
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		
		
		if( flWillWin && dist > GRAY-BRAY ){
			var d = dist-(GRAY-BRAY)
			ball.x -= ca*d						
			ball.y -= sa*d
			ball.a = a+3.14+(Math.random()*2-1)*0.3
		}
		if( !flWillWin && dist < GRAY+BRAY ){
			var d =(GRAY+BRAY)-dist;
			ball.x += ca*d						
			ball.y += sa*d
			ball.a = a+(Math.random()*2-1)*0.3
		}
		
		
	}
	
	function willWin(flag){
		flFreezeResult = true;
		flWillWin = flag;
		step = 3
		timer = 12
	}
	
	function updateGlassPos(){
		glass._x = gs.skin._x
		glassBack._x = gs.skin._x
		glass._y = gs.skin._y-gy;
		glassBack._y = gs.skin._y-gy;
	}
	
	
//{	
}

