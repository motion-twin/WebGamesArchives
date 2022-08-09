class game.HedgeHog extends Game{//}
	
	// CONSTANTES
	static var HRAY = 40
	static var SIZE = 150
	static var GL = 200
	
	
	// VARIABLES
	var size:float;
	var speed:float;
	var jump:float;
	var shake:float;
	
	// MOVIECLIPS
	var s:{>MovieClip,s:MovieClip,dec:float};
	var h:{>MovieClip,dec:float};
	var g:MovieClip
	
	function new(){
		super();
	}

	function init(){
		gameTime = 350
		super.init();
		h.dec = Math.random()*628
		s.dec = Math.random()*628
		speed = 10+dif*0.2
		s.s._width = size
		
		attachElements();
	};
	
	function attachElements(){
		
	}
	
	function update(){

		switch(step){
			case 1:
				moveHedgehog();
			
				// SHOE
				s.dec = (s.dec+speed*0.6)%628
				s._x = SIZE + (Cs.mcw-SIZE)*(Math.cos(s.dec/100)+1)*0.5 
				break;
			case 2:
				moveHedgehog();
				//
				s._y += 50
				if(s._y>GL)hit();
				break;
			case 3:
				jump *= Math.pow(0.95,Timer.tmod)
				h._y += jump*Timer.tmod
				jump += 0.6*Timer.tmod;
				if( h._y > GL ){
					h._y = GL
					jump = -jump*0.8
				}
				break;
			case 4:
				break;
		}
		if(shake!=null){
			shake *= Math.pow(0.8,Timer.tmod)
			var s = (Math.random()*2-1)*shake
			_y = s
			g._y = GL + s*0.5
		}
		
		
	
		super.update();
	}
	
	function moveHedgehog(){
		h.dec = (h.dec+speed)%628
		var c = Math.cos(h.dec/100)
		var x = HRAY+(Cs.mcw-HRAY*2)*(c+1)*0.5
		h._xscale = (x<h._x)?-100:100
		h._x = x
	}
	
	function click(){
		step = 2
		s.gotoAndPlay("2")
	}
	
	
	function hit(){
		s._y = GL
		var dx = h._x - (s._x-SIZE*0.5)
		shake = 3
		if( Math.abs(dx) < (SIZE*0.5+HRAY)*0.75 ){
			step = 4
			h._yscale = 20
			setWin(false)
		}else{
			h._xscale = (dx>0)?-100:100
			step = 3
			jump = -8
			setWin(true)
		}
	}
	
	
//{	
}


// voiture bus falaise



