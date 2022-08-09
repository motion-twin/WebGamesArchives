class game.Olive extends Game{//}
	
	// CONSTANTES
	static var GL = Cs.mch-24;
	static var BG_COEF = 0.5
	static var SPEED = 20
	static var OL_RAY = 10
	
	// VARIABLES
	var pList:Array<{>MovieClip,t:float,step:int}>
	
	// MOVIECLIPS
	var ol:MovieClip;
	var os:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 100+dif*0.2
		super.init();
		attachElements();
	};
	
	function attachElements(){

		// NAPPE
		dm.attach("mcOliveNappe",Game.DP_SPRITE)

		// OLIVE SHADE
		os = dm.attach("mcOliveShade",Game.DP_SPRITE)
		os._x = Cs.mcw*0.5
		os._y = GL

		// OLIVE
		ol = dm.attach("mcOlive",Game.DP_SPRITE)
		ol._x = Cs.mcw*0.5
		ol._y = GL-14
		ol.stop();

		// PIQUES
		pList = new Array();
		var m = Cs.mcw*(1-BG_COEF)*0.5
		var max = 3+int(dif*0.1)
		for( var i=0; i<max; i++ ){
			var mc = downcast( dm.attach("mcOlivePique",Game.DP_SPRITE) )
			do{
				mc._x = m + Math.random()*(Cs.mcw-2*m)
			}while(touchOther(mc))
			mc._y = Cs.mch
			mc.t = i*dif*0.03
			mc.step = 0
			mc._xscale = BG_COEF*100
			mc._yscale = -BG_COEF*100
			mc.stop();
			dm.under(mc);
			pList.push(mc)
		}
		
	}
	
	function update(){
		
		switch(step){
			case 1: 
				moveOlive()
				movePiques();
				break;
			case 2:
				movePiques();
		}
		//
		super.update();
	}
	
	function movePiques(){
		var flWin = true;
		for( var i=0; i<pList.length; i++ ){
			var mc = pList[i]
			switch(mc.step){
				case 0:
					mc.t -= Timer.tmod
					if(mc.t < 0){
						mc._y -= SPEED*Timer.tmod*BG_COEF
						if( mc._y < -100 ){
							var mil = Cs.mcw*0.5
							mc._x = mil + (mc._x-mil)/BG_COEF
							mc._xscale = 100
							mc._yscale =  100
							mc.step = 1
							dm.over(mc);
						}
					}
					flWin = false;
					break;
				case 1:
					mc._y += SPEED*Timer.tmod
					if( mc._y > GL ){
						mc._y = GL
						mc.step = 2
						mc.gotoAndStop("2")
						
						
						if(Math.abs(mc._x - ol._x) < OL_RAY ){
							dm.over(ol)
							step = 2
							ol._y += 4
							ol.gotoAndPlay("2")
							setWin(false)
						}else{
							mc._rotation = 5+Math.random()*2
							
						}
						
					}
					flWin = false;
					break;
				case 2:
					mc._rotation = -mc._rotation*Math.pow(0.92,Timer.tmod)
					if(Math.abs(mc._rotation)>2)flWin = false;
					break;
			}
			
		}
		if(flWin)setWin(true);
	}
	

	function moveOlive(){
		// OLIVE
		var ox = ol._x
		var dx = _xmouse - ol._x
		ol._x += dx*0.15*Timer.tmod;
		ol._rotation = dx*0.3
		
		// RECAL
		var m = 1
		for( var i=0; i<pList.length; i++ ){
			var mc = pList[i]
			
			if( mc.step == 2 ){
				//Log.print("t!")
		
				if( mc._x>ol._x-OL_RAY && mc._x-m<ox-OL_RAY ){
					ol._x = mc._x+OL_RAY
				}
				
				if( mc._x<ol._x+OL_RAY && mc._x+m>ox+OL_RAY ){
					ol._x = mc._x-OL_RAY
				}
				
			}
		}
		//Math.abs(mc._x - ol._x) < OL_RAY
		
		
		// SHADE
		os._x = ol._x
	
	}
	
	function touchOther(mc){
		for( var i=0; i<pList.length; i++ ){
			var mco = pList[i]
			if( Math.abs(mco._x-mc._x) < 5 )return true;
		}
		return false
	}
	
	function outOfTime(){
		setWin(true)
	}
	
	
//{	
}


