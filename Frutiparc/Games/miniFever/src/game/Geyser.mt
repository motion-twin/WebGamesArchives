class game.Geyser extends Game{//}

	// CONSTANTES
	var gRay:float;
	var bRay:float;
	var tRay:float;
	var gl:float;
	
	// VARIABLES
	var flBall:bool;
	var fallTimer:float;
	var tubeHeight:float;
	var eList:Array<{>sp.Phys,ray:int,z:float,vitz:float,timer:float,flGlassUp:bool,flTubeUp:bool}>
	var fList:Array<{>MovieClip,tx:float,ty:float,vity:float}>
	
	var tubeNum:int;
	var tubeObj:int;
	
	// MOVIECLIPS
	var glass:sp.Phys;
	var tube:{>MovieClip,dm:DepthManager};
	var runner:{>MovieClip,vx:float}
	
	function new(){
		super();
	}

	function init(){
		
		gameTime = 520;
		super.init();
		
		gRay  = 20
		bRay = 5
		tRay = 8
		gl = Cs.mch-8
		
		tubeNum = 0
		tubeObj = 3+Math.round(dif*0.08)
		
		tubeHeight = tubeObj*(bRay*2*0.85)
		
		eList = new Array();
		fList = new Array();
		
		attachElements();
	};
	
	function attachElements(){

		
		// TUBE
		tube = downcast(dm.empty(Game.DP_SPRITE))//downcast(dm.attach("mcGeyserTube",Game.DP_SPRITE))
		tube._x = Cs.mcw - (tRay+4)
		tube._y = Cs.mch
		tube.dm = new DepthManager(tube);
		var mc = tube.dm.attach("mcGeyserTube",2)
		mc._yscale = tubeHeight;
		
		// RUNNER
		runner = downcast(dm.attach("mcGeyserRunner",Game.DP_SPRITE))
		runner._x = Cs.mcw*0.5
		runner._y = gl
		runner.vx = -4
		
		
		// GLASS
		glass = newPhys("mcGeyserGlass")
		glass.x = Cs.mcw*0.5
		glass.y = Cs.mch*0.5
		glass.flPhys = false;
		glass.skin.stop();
		glass.init();		
		
	}

	function update(){
		super.update();
		switch(step){
			case 1:
				genElements();
				moveElements();
				moveGlass();
					
				for( var i=0; i<fList.length; i++ ){
					var mc = fList[i]
					mc.vity += 0.4*Timer.tmod
					mc.vity *= Math.pow(0.98,Timer.tmod)
					mc._y += mc.vity*Timer.tmod
					if(mc._y > mc.ty){
						mc._y = mc.ty
						mc._x = mc.tx
						fList.splice(i--,1)
					}
				}

				if(runner._rotation>0 ){
					runner.vx*=0.9
				}else{
					var m = 5
					if(runner._x < m ){
						runner._x = m;
						turn();
	
					}
					if(runner._x > Cs.mcw-(m+28) ){
						runner._x = Cs.mcw-(m+28);
						turn();
					}
					
					if(Std.random(int(60/Timer.tmod))==0)turn();
									
				}
				
				runner._x += runner.vx*Timer.tmod

				
				
			
				break;
			case 2:
				
				break;
			
		}
		//
	
	}
	
	function turn(){
		runner.vx *= -1
		runner._xscale *= -1	
	}
	
	
	function genElements(){
	
		for( var i=0; i<1; i++ ){
			
			var sp = newElement();
			//
			if( Std.random(16) == 0 ){
				morphToBall(sp)
			}
			sp.init();
			
			
		}
		
		
		
		//Log.print(glPhys().length)
	}
	
	function newElement(){
			var sp = downcast(newPhys("mcCouscous"))
			sp.x = Cs.mcw*0.5
			sp.y = Cs.mch-50
			var a = (Math.random()*2-1)*0.4 - 1.57
			var p = 5+Math.random()*10
			sp.vitx = Math.cos(a)*p
			sp.vity = Math.sin(a)*p
			sp.vitz = (Math.random()*2-1)*p
			sp.weight = 0.2
			sp.ray = 4
			sp.z = 0
			sp.timer = 2000//Math.random()*60
			sp.vitr = Math.random()*5
			
			sp.skin._rotation = Math.random()*360
			sp.skin.gotoAndStop(string(Std.random(2)+1))
			eList.push(sp)
		
			return sp;
	}
	
	function morphToBall(el){
		el.skin.gotoAndStop("3")
		el.flGlassUp = false;
		el.flTubeUp = false;
		el.weight = 0.4
		el.vitz = 0
	}
	
	function moveElements(){
		for( var i=0; i<eList.length; i++ ){
			var sp = eList[i]
			
			sp.vitz *= Math.pow(0.96,Timer.tmod)
			sp.z +=sp.vitz*Timer.tmod
			
			var prc = Math.min(Math.max(0,20+sp.z*0.4),80)
			Mc.setPercentColor(sp.skin,prc,0x479E4B);
			

			// CHECK GLASS
			if( glass.skin._rotation<5 && sp.vity>0 && sp.flGlassUp!=null ){
				var flUp = sp.y < glass.y
				if( !flUp && sp.flGlassUp ){
					var dx = Math.abs(glass.x-sp.x)
					if( dx < gRay-bRay ){
						if( glass.skin._currentframe == 5 ){
							sp.vity *= -0.8
							sp.y = glass.y
						}else{
							glass.vity += 6
							glass.skin.nextFrame();
							sp.timer = 0
						}
					}else if( dx < gRay+bRay ){
					
					}
				}
				
				sp.flGlassUp = flUp
			}
			
			// CHECK TUBE
			if( sp.timer>0 && sp.vity>0 && sp.flTubeUp!=null ){
				var flUp = sp.y < (tube._y - tubeHeight)
				if( !flUp && sp.flTubeUp ){
					var dx = Math.abs(tube._x-sp.x)
					if( dx < (tRay-bRay)*1.2 ){
						if( tubeNum < tubeObj ){
							tubeNum++
							var mc = downcast(tube.dm.attach("mcCouscous",1))
							mc._y = -tubeHeight
							mc.vity = sp.vity
							mc.ty = bRay-tubeNum*(bRay*2*0.85)
							mc.tx = ((tubeNum%2)*2-1)*(tRay-bRay)*0.7
							mc.gotoAndStop("3")
							fList.push(mc)
							sp.timer = 0
							
							if(tubeNum ==tubeObj)setWin(true);
							
						}
						
					}else if( dx < tRay+bRay ){
						if(sp.vity>2)sp.vity *= -0.8;
					}
				}
				
				sp.flTubeUp = flUp
			}			
			
			// REBOND
			if( sp.flGlassUp!=null ){
				//ssp.skin._alpha = 50
				if( sp.vity>2 && runner._rotation == 0 && sp.y > gl-(bRay+20) && Math.abs(runner._x-sp.x) < bRay*2 ){
					runner.gotoAndPlay("dead")
					runner._rotation = 0.5
					sp.y = gl-(bRay+20)
					sp.vity *= -0.5
					sp.vitr = (Math.random()*2-1)*20
				}
				
				
				if( sp.y > gl-bRay  ){
					sp.y = gl-bRay
					sp.vity *= -0.5
					sp.vitr = (Math.random()*2-1)*20
					if(sp.timer >20)sp.timer = 10+Math.random()*10
				}
			}			
			
			
			sp.timer -= Timer.tmod
			if(sp.timer<10){
				sp.skin._xscale = sp.timer*10;
				sp.skin._yscale = sp.skin._xscale
			}
			if( sp.x < sp.ray || sp.x > Cs.mcw+sp.ray || sp.y > Cs.mch+sp.ray || sp.timer<0 ){
				sp.kill()
				eList.splice(i--,1)
			}
			
		}	
	}
	
	function moveGlass(){
		var m = {x:_xmouse,y:_ymouse+10}
		glass.toward( m, 0.4, null )
		
		var dr = -glass.skin._rotation
		if(base.flPress){
			dr  = 90 - glass.skin._rotation
			
			if( dr < 5 && glass.skin._currentframe > 1){
				fallTimer -= Timer.tmod
				if( fallTimer < 0 ){
					var sp = newElement();
					sp.x = glass.x + bRay
					sp.y = glass.y + (gRay-bRay*2)
					sp.vitx = 0.1+Math.random()*0.5
					sp.vity = 0
					sp.vitz = 0
					morphToBall(sp)
					sp.init();
					fallTimer = 8;
					glass.skin.prevFrame();
				}
			}
			
		}else{
			fallTimer = 0
		}
		glass.skin._rotation += dr*0.3*Timer.tmod	
	}
	
	
	
//{	
}















