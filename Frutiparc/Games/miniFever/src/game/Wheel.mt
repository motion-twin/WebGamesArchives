class game.Wheel extends Game{//}
	
	// CONSTANTES
	static var IMG_MAX = 4
	// VARIABLES

	var current:int
	var timer:float
	var vitr:float;
	var wList:Array<{>MovieClip,mask:MovieClip}>
	
	// MOVIECLIPS
	var wheel:{>MovieClip,mask:MovieClip}

	function new(){
		super();
	}

	function init(){
		gameTime = 250
		super.init();
		attachElements();
	};
	
	function attachElements(){
		wList = new Array();
		var img = int((dif/101)*IMG_MAX)
		var max = 2+Math.floor(dif*0.04)
		
		var prec = 0
		for( var i=0; i<max; i++ ){
			var mc = downcast(dm.attach("mcBigWheel",Game.DP_SPRITE))
			mc._x = Cs.mcw*0.5 
			mc._y = Cs.mch*0.5
			var scale = (1-(i/max))*100
			mc.mask._xscale = scale
			mc.mask._yscale = scale
			mc.gotoAndStop(string(img+1))
			var rot = null
			do{
				rot = Math.random()*360
				var dr = rot-prec
				while(dr>180)dr-=360;
				while(dr<-180)dr+=360;
				if(Math.abs(dr)>30)break;
			}while(true)
			mc._rotation = rot
			prec = rot
			
			wList.push(mc)
		}
		current = max-1
		
	}
	
	function update(){


		
		
		switch(step){
			case 1:
				moveWheel();
				break;
			case 2:
			
				var mc = wList[0]
				var dr = 0-mc._rotation
				var lim = 5
				vitr += Cs.mm(-lim,dr*0.15,lim)*Timer.tmod;
				vitr *= Math.pow(0.94,Timer.tmod)

				mc._rotation += vitr*Timer.tmod;

				timer -= Timer.tmod;
				if(timer<0){
					flFreezeResult = false;
					setWin(true);
				}
			
				break;
		}
		
		super.update();
	}
	
	
	function moveWheel(){
		var r = wList[current-1]._rotation
		var rot = Cs.mm(0,(_xmouse/Cs.mcw),1)*500
		
		var dr =  rot-r
		while(dr>180)dr-=360;
		while(dr<-180)dr+=360;
		
		if(  Math.abs(dr) < 1.3 ){
			current--;
			if( current == 0 ){
				victory();
			}
		}
		
		for( var i=current; i<wList.length; i++ ){
			var mc = wList[i]
			mc._rotation = rot;
			
		}
	}
	
	function victory(){
		flFreezeResult = true;
		step = 2
		timer = 25
		vitr = 0
		while(wList.length>1)wList.pop().removeMovieClip();
		
	}
	
	
	
//{	
}

