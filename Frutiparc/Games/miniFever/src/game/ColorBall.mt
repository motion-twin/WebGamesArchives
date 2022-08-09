class game.ColorBall extends Game{//}
	
	
	
	// CONSTANTES
	static var WAIT = 170
	static var ECART = 26
	
	// VARIABLES
	var timer:float;
	var bList:Array<{>MovieClip,t:float,light:bool}>
	
	
	// MOVIECLIPS

	
	function new(){
		super();
	}

	function init(){
		gameTime = 380
		super.init();

		attachElements();
	};
	
	function attachElements(){
		
		// BALLS
		var c = 3+Math.floor(dif*0.04)
		var m = (Cs.mcw-(c-1)*ECART)*0.5
		bList = new Array();
		for( var x=0; x<c; x++ ){
			
			for( var y=0; y<c; y++ ){
				var mc = downcast(dm.attach("mcColorBall",Game.DP_SPRITE));
				mc._x = m + x*ECART;
				mc._y = m + y*ECART;
				mc.stop();
				mc.light = false;
				bList.push(mc)
				mc.onRollOver = callback(this,activate,mc)
				
			}
		}
		
	}
	
	function update(){
		
		switch(step){
			case 1:
				var flWin = true;
				for( var i=0; i<bList.length; i++){
					var mc = bList[i]
					if(mc.light){
						mc.t -= Timer.tmod
						if( mc.t < 0 ){
							mc.t = null
							activate(mc)
						}
						mc.nextFrame();
					}else{
						mc.prevFrame();
					}
					if(mc._currentframe<5)flWin = false;
					
				}
				if(flWin){
					
					step = 2
					timer = 18
				}
				break;
			case 2:
				for( var i=0; i<bList.length; i++){
					var mc = bList[i]
					mc.nextFrame();
					mc.t+=6*Timer.tmod;
					if(mc.t>WAIT){
						mc._xscale = mc._xscale*0.7
						mc._yscale = mc._xscale
					}
					
				}
				timer -= Timer.tmod;
				if( timer < 0 )setWin(true);
				
				
				break;
		}
		super.update();
	}
	
	function activate(mc){
		mc.light = !mc.light;
		if(mc.light)mc.t =WAIT;
	}
	
	
//{	
}

















