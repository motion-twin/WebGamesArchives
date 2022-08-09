class game.JumpCar extends Game{//}
	
	static var GL = 171
	static var EDGE = 44
	static var SIZE = [54,90]
	static var CH = 20
	
	// CONSTANTES
	
	// VARIABLES
	var flJumpReady:bool;
	var flSky:bool;
	var hStep:int;
	var wf:float;
	var startTimer:float;
	var freq:float;
	var speed:float;
	var cList:Array<{>sp.Phys,w:float,flLeft:bool}>
	var car:{>sp.Phys,w:float, flLeft:bool}
	
	// MOVIECLIPS
	var hero:sp.Phys;

	function new(){
		super();
	}

	function init(){
		gameTime = 200
		super.init();
		flJumpReady = true;
		hStep = 0;
		wf = 0;
		startTimer = 20
		freq = 20-dif*0.17//10
		speed = 2+dif*0.04//4
		flSky = false;
		cList = new Array();
		attachElements();
	};
	
	function attachElements(){
	  
		// HERO
		var sp = newPhys("mcJumpCarHero")
		sp.x = 74;
		sp.y = GL;
		sp.weight = 0.5;
		sp.flPhys = false;
		sp.init();
		hero = sp;
		
		
		
	}
	
	function update(){
		if( !flJumpReady && !base.flPress )flJumpReady=true;
		
		switch(step){
			case 1:
				// ADD CARS
				if(startTimer<0){
				var last = cList[cList.length-1]
					if( ( last.x < Cs.mcw-60 && Std.random(int(freq/Timer.tmod)) == 0 ) || last == null ){
						addCar();
					}
				}else{
					startTimer -= Timer.tmod;
				}
				// MOVE
				moveCars();
				moveHero();
				break;
		}
		super.update();
	}
	
	function moveHero(){
		switch(hStep){
			case 0: // WALK
				if( hero.x < EDGE ){
					hero.flPhys = true;
					hero.vitx -= 1
					hStep = 1
					break;
				}
			
				//
				
				var dx = _xmouse - hero.x
				var lim = 0.8
				var inc = Cs.mm(-lim,dx*0.05,lim)*Timer.tmod;
				hero.vitx += inc
				hero.vitx *= Math.pow(0.8,Timer.tmod)
				
				var run = Math.abs(inc)
				
				if( run<0.1 ){
					wf = 0
					hero.skin.gotoAndStop("1")
				}else{
					wf=(wf+run*1.2)%11
					hero.skin.gotoAndStop(string(5+int(wf)))
					if( hero.vitx*hero.skin._xscale < 0 )hero.skin._xscale*=-1;
				}
					
				if(car!=null){
					var dif = car.x-hero.x
					if( dif < 0 || dif > car.w ){
						hero.skin.gotoAndStop("10")
						flSky = true;
						hero.flPhys = true;
						hStep = 1
						car = null;
					}
				}
				//
				if( car!=null ){
					hero.x += car.vitx
					hero.y += car.vity
				}
				//
				if(base.flPress){
					flJumpReady = false;
					hero.skin.gotoAndStop("10")
					flSky = true;
					hero.flPhys = true;
					hero.vity = -10
					hStep = 1
					car = null;
				}
				
				
				
				break;
				
			case 1: // FLY
				
				if( hero.x < EDGE )break;
				if(hero.vity > 0 ){
					if( flSky && hero.y > GL-CH ){
						flSky = false;
						for( var i=0; i<cList.length; i++ ){
							var sp = cList[i]
							if(!sp.flPhys){
								var dx = sp.x - hero.x
								if( dx > 0 && dx < sp.w ){
									hStep = 0;
									hero.flPhys = false;
									hero.vitx = 0;
									hero.vity = 0;
									hero.skin.gotoAndPlay("land")
									hero.y = GL-CH
									car = sp;
									break;
								}
							}
						}
					}
					
					if( hero.y > GL ){
						hero.y = GL
						hStep = 0;
						hero.flPhys = false;
						hero.vitx = 0;
						hero.vity = 0;
						hero.skin.gotoAndPlay("land")
						
					}
					
				}
				break;
			case 2:

				if( hero.y > GL-6 && hero.x > EDGE ){
					hero.y = GL-6
					hero.vity *= -1 ;
				}
				break;
		}
		if( hero.y > Cs.mch || hero.x < -10 ){
			flFreezeResult = false;
			setWin(false);
		}
		
		
		
		
		
	}
	
	function moveCars(){
		var prev = null
		for( var i=0; i<cList.length; i++ ){
			var sp = cList[i]
			// CHECK OTHER CAR
			var dx = Math.abs(sp.x-prev.x)
			if( prev != null && dx < sp.w ){
				var d = sp.w - dx
				sp.x += d*0.5
				prev.x -= d*0.5
				
			}
			
			// CHECK FALL
			if( sp.x-sp.w*0.5 < EDGE ){
				if( !sp.flPhys ){
					sp.flPhys = true;
					sp.vitr = -4
				}
			}else{
				prev = sp
			}
			
			// CHECK HERO COL

			var ddx = (sp.x-sp.w)-hero.x
			if( ( !sp.flLeft && ddx < 0 ) || ( sp.flLeft && ddx > 0 ) ){
				
				if( flSky ){
					sp.flLeft = !sp.flLeft
				}else if(hStep!=2){
					hStep = 2;
					hero.flPhys = true;
					hero.vitx = sp.vitx*2
					hero.vity = -(3+Math.random()*3)
					hero.vitr = 12
					hero.skin.gotoAndStop("ouch")
					hero.y -= 6
					sp.vitx *= 0.5
					flFreezeResult = true;
				}
			}
			
			
			
			// 
			if( sp.x < 0 )sp.kill();
			
			//
			
			
		}
	}
	
	function addCar(){
		
		var sp = downcast(newPhys("mcJumpCar"))
		var type = 0
		sp.vitx = -(speed+Math.random()*speed)
		sp.w = SIZE[type]
		sp.x = Cs.mcw+sp.w+10
		sp.y = GL		
		sp.flPhys = false;
		sp.weight = 0.75
		sp.friction = 1
		sp.flLeft = false
		sp.init();
		sp.skin.gotoAndStop(string(type+1))
		
		cList.push(sp)
	}
	
	function outOfTime(){
		setWin(true)
	}
	
	
	
//{	
}






















