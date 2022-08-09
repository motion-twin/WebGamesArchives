class game.Shield extends Game{//}
	
	// CONSTANTES
	var ballRay:float;
	var shieldRay:float;
	var shieldMargin:int;
	var gl:int;
	var pos:Array<int>;
	var herb:Sprite;
	// VARIABLES
	var ballList:Array<{>Sprite, sens:int, height:float, vx:float, vy:float, vr:float, decal:float, flActive:bool, shade:Sprite }>
	
	// MOVIECLIPS
	var hero:Sprite;
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 320
		super.init();
		ballRay = 6;
		shieldRay = 14;
		shieldMargin = 20;
		gl = Cs.mch-16;
		
		ballList = new Array();

		
		pos = [
			gl-12
			gl-29
			gl-44
		]
		
		
		attachElements();

		
	};
	
	function attachElements(){
		
		hero = newSprite("mcShieldMan")
		hero.x = Cs.mcw*0.5
		hero.y = gl
		hero.init();
		
		herb = newSprite("mcShieldFrontHerb")
		herb.x = 120
		herb.y = 225
		herb.init();
		
		
	}
	
	function update(){
		//dif = 100
		moveBall();
		switch(step){
			case 1: 
				//
				var sens = (_xmouse<Cs.mcw*0.5)?-1:1
				hero.skin._xscale = -sens*100
				var frame = null
				if( _ymouse < 170 ){
					frame = 3
				}else if(_ymouse < 200){
					frame = 2
				}else{
					frame = 1
				}
				hero.skin.gotoAndStop(string(frame))
				//								
				if( Std.random( int((100*ballList.length)/Timer.tmod) ) == 0 ){
					addBall();
					
				}
				
				for( var i=0; i<ballList.length; i++ ){
					var sp = ballList[i]
					var dx = Math.abs(hero.x - sp.x) 
					if(sp.flActive){
						if( dx < shieldMargin+ballRay ){
							var dy = Math.abs(pos[frame-1]-sp.y)
							var flWay = sens == -sp.sens
							if( dy < ballRay+shieldRay && flWay ){
								sp.sens *= -1
								sp.x = hero.x+(shieldMargin+ballRay)*sp.sens
								sp.flActive = false	
							}else{
								
								if( dx < (shieldMargin+ballRay)-12 ){
									
									sp.sens *= -1
									step = 2
									var fr= null
									if( sp.y < 170 ){				
										fr = flWay?"head0":"head1"
									}else if( sp.y < 200){
										fr = flWay?"chest0":"chest1"
									}else{
										fr = flWay?"leg0":"leg1"
			
									}
									hero.skin.gotoAndPlay(fr)
									setWin(false)
									
									
									
								}								
						
							}

							
						}
					}else{
						if( dx > (Cs.mcw*0.5)+ballRay ){
							ballList.splice(i--,1);
							sp.init();
						}
					}
				}
				
				
				
				
				
				
				break;
		
		}
		//
		super.update();
	}
	
	function moveBall(){
		for( var i=0; i<ballList.length; i++ ){
			var sp = ballList[i]
			sp.x += sp.vx*sp.sens*Timer.tmod;
			sp.decal = (sp.decal+sp.vy*Timer.tmod)%628
			sp.y = gl-( ballRay+Math.abs(Math.cos(sp.decal/100)*sp.height))
			sp.shade.x = sp.x
			sp.skin._rotation += sp.vr*Timer.tmod*sp.sens
			downcast(sp.skin).reflet._rotation = -sp.skin._rotation
		}	
	}
	
	function outOfTime(){
		setWin(true);
		hero.skin.gotoAndPlay("win")
		step = 2;
	}

	function addBall(){

		var sp = downcast(newSprite("mcShieldBall"))
		sp.sens = (Std.random(2)*2)-1
		sp.height = 20+Math.random()*40
		sp.decal = Math.random()*628
		sp.flActive = true;
		sp.vx = 2.5+dif*0.02+Math.random()*(dif*0.04)
		sp.vy = 5+dif*0.1+Math.random()*(dif*0.2)
		var half = Cs.mcw*0.5
		sp.x = half - sp.sens*(half+ballRay)
		sp.skin.gotoAndStop(string(1+Std.random(sp.skin._totalframes)))
		sp.init()
		ballList.push(sp) // BUG MTYPE
		
		sp.vr = 3+Math.random()*(10+Math.abs(sp.vx))
		

		sp.shade = newSprite("mcShieldBallShade")
		sp.shade.x = sp.x;
		sp.shade.y = gl;
		sp.shade.init();
		
		dm.under(sp.shade.skin)
		
	}
	
	
	
//{	
}



