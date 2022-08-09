class game.Clou extends Game{//}
	
	
	
	// CONSTANTES
	static var GL = 192
	static var CH = 65
	static var CRAY = 8
	
	
	// VARIABLES
	var flLeft:bool;
	var ray:float;
	var power:float;
	var seuil:float;
	
	// MOVIECLIPS
	var ham:sp.Phys
	var clou:MovieClip;
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 320
		super.init();
		ray = 40-dif*0.25
		seuil = 1+dif*0.1
		power = 0
		
		attachElements();
	};
	
	function attachElements(){
		
		// HAMMER
		ham = newPhys("mcBigHammer")
		ham.x = Cs.mcw//0.5;
		ham.y = Cs.mch*0.5;
		ham.flPhys = false;
		ham.friction = 0.92
		ham.init();
		ham.skin._xscale = ray*2
		ham.skin._yscale = ray*2
				
	}
	
	function update(){
		
		var oy = ham.y
		
		var dx = _xmouse - ham.x;
		var lim = 1;
		ham.vitx += Cs.mm(-lim,dx*0.05,lim)*Timer.tmod;
		
		
		var dy = _ymouse - ham.y;
		var c = 0.2
		if(dy>0)c = 0.5 ;
		ham.y += dy*c;
		
		switch(step){
			case 1:
				if( ham.y > clou._y - CH ){
					var dfx = ham.x - clou._x
					if( Math.abs(dfx) < ray+CRAY ){
						

						if(power>seuil){
							power-=seuil
							var max = (GL+CH)-4 
							clou._y = Math.min( clou._y+power, max )
							if(clou._y==max)setWin(true);
						}
						ham.y = clou._y - CH
					}else{
						step=2;
						flLeft = dfx<0
					}
					power = 0
				}
			
				break;
			case 2:
				if( ham.y < clou._y - CH ){
					step = 1;
					break;
				}
				
				if( flLeft && ham.x > clou._x-(CRAY+ray) ){
					ham.x = clou._x-(CRAY+ray)
					ham.vitx *= 0.1
				}
				
				if( !flLeft && ham.x < clou._x+(CRAY+ray) ){
					ham.x = clou._x+(CRAY+ray)
					ham.vitx *= 0.1
				}
				
				if( ham.y > GL ){
					ham.y = GL
					power = 0
				}
				
				break;
			case 3:
				break;
		}

		var dif = (ham.y-oy)
		power *= 0.5
		if(dif>0)power += dif*0.2;
		
		
		ham.skin._rotation = 40*Math.max(0,(1-(ham.y*2/Cs.mch)))
		
		
		super.update();
	}


//{	
}















