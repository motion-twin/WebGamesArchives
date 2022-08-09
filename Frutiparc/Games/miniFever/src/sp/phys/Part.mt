class sp.phys.Part extends sp.Phys {//}


	// VARIABLES
	var flCol:bool;
	var timer:float;
	
	var timerFadeLimit:int;
	var timerFadeType:int;
	var scale:float;
	var bound:{
		xMin:{ lim:int, type:int },
		xMax:{ lim:int, type:int },
		yMin:{ lim:int, type:int },
		yMax:{ lim:int, type:int }
	}
	
	
	function new(){
		super();
	}

	function init(){
		super.init();
		this.addToList(Cs.PART)	
		skin._xscale = scale
		skin._yscale = scale
	}
	
	function initDefault(){
		super.initDefault();
		timerFadeLimit = 10;
		timerFadeType = 0;
		scale = 100;
		bound = {
			xMin:{ lim:0, 		type:0 },
			xMax:{ lim:Cs.mcw,	type:0 },
			yMin:{ lim:0,		type:0 },
			yMax:{ lim:Cs.mch,	type:0 }			
		}
		
	}
	
	function update(){
		super.update();
		
		if( timer != null ){
			timer -= Timer.tmod
			if( timer < 0 ){
				kill();	
								
			}else if( timer < timerFadeLimit ){
				
				var c = timer/timerFadeLimit
				
				switch( timerFadeType ){
					case 0:
						skin._alpha = c*100
						break;
					case 1:
						skin._xscale = c*scale
						skin._yscale = skin._xscale
						break;
					case 2:
						
						skin._yscale = c*scale
						break;
				}
				
			}
		}
	
	};	
	
	
//{	
}