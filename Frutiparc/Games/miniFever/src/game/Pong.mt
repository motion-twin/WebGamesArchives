class game.Pong extends Game{//}
	
	// CONSTANTES
	var ballRay:int;

	// VARIABLES
	var flWasLeft:bool;
	var padRay:float;
	var speed:float;
	var startCoef:float;
	
	var oldPos:{x:float,y:float};
	
	// MOVIECLIPS
	var pad:Sprite;
	var ball:sp.Phys;

	
	function new(){
		super();
	}

	function init(){
		gameTime = 200;
		super.init();
		
		speed = 5+(dif*0.15)//+15
		padRay = 30-(dif*0.1)
		ballRay = 5
		flWasLeft = true;
		startCoef = 1
		attachElements();
	
		
	};
	
	function initDefault(){
		super.initDefault();
		airFriction = 1;
	}
	
	function attachElements(){
		// BALL
		ball = newPhys("mcPongBall")
		var a = 3.14+(Math.random()*2-1)*0.5
		ball.x = Cs.mcw-20;
		ball.y = Cs.mch*0.5;
		ball.vitx = Math.cos(a)*speed;
		ball.vity = Math.sin(a)*speed;
		ball.flPhys = false;
		ball.skin._xscale = ballRay*2
		ball.skin._yscale = ballRay*2
		ball.init();
		
		// PAD
		pad = newSprite("mcPad")
		pad.x = Cs.mcw - 14
		pad.y = Cs.mch*0.5
		var mc = Std.cast(pad.skin)
		mc.base._yscale = padRay*2;
		mc.s1._y = -padRay;
		mc.s2._y =  padRay;
		pad.init();
	}

	function outOfTime(){
		setWin(true)
	}
	
	function update(){
		super.update();
		switch(step){
			case 1: 
				startCoef = Math.max( 0, startCoef-0.02*Timer.tmod )
				
				ball.x -= ball.vitx*Timer.tmod*startCoef
				ball.y -= ball.vity*Timer.tmod*startCoef
			
				// BALL
				var r = ballRay
				if( ball.x < r ){
					ball.x = r
					ball.vitx *= -1
				}
				if( ball.y < r || ball.y > Cs.mch-r ){
					ball.y = Math.min(Math.max(r,ball.y),Cs.mch-r)
					ball.vity *= -1
				}
				var flLeft = ball.x < pad.x 
				
				if( !flLeft && flWasLeft ){
					var d = ball.y - pad.y
					if( Math.abs(d) < ballRay+padRay ){
						ball.x = pad.x-ballRay
						ball.skin._x = ball.x
						//ball.vitx *= -1
						var c = d/(ballRay+padRay)
						var a = 3.14-c*0.8
						//Log.trace(c)
						ball.vitx = Math.cos(a)*speed
						ball.vity = Math.sin(a)*speed
						
						
						
					}else{
						setWin(false)
					}
				}
				flWasLeft = flLeft
				
				// PAD
				var dy = this._ymouse - pad.y
				pad.y += dy*0.5*Timer.tmod 
				
				// TRAINE
				if(oldPos!=null){
					var mc = newSprite("mcPartVanisher")
					mc.x = ball.x
					mc.y = ball.y
					var a = mc.getAng(oldPos)
					var d = mc.getDist(oldPos)
					mc.skin._xscale = d
					mc.skin._yscale = ballRay*2
					mc.skin._rotation = a/0.0174
					mc.init();
				}
				oldPos = {x:ball.x,y:ball.y}
				

				
				break;

		}
		//
		
	}

	
	
//{	
}












