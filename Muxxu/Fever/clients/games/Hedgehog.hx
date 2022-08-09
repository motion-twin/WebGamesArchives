import Protocole;

class Hedgehog extends Game{//}

	// CONSTANTES
	static var HRAY = 40;
	static var SIZE = 150;
	static var GL = 200;


	// VARIABLES
	var size:Float;
	var speed:Float;
	var jump:Float;
	var shake:Null<Float>;

	// MOVIECLIPS
	var s:{>flash.display.MovieClip,s:flash.display.MovieClip,dec:Float};
	var h:{>flash.display.MovieClip,dec:Float};
	var g:flash.display.MovieClip;


	override function init(dif){
		gameTime = 350;
		super.init(dif);
		speed = 10+dif*20;
		attachElements();
		zoomOld();
	}

	function attachElements(){
		bg = dm.attach("hedgehog_bg",0);

		s = cast(bg).s;
		h = cast(bg).h;
		g = cast(bg).g;
		h.dec = Math.random()*628;
		s.dec = Math.random()*628;
		s.s.width = size;

	}

	override function update(){

		switch(step){
			case 1:
				moveHedgehog();

				// SHOE
				s.dec = (s.dec+speed*0.6)%628;
				s.x = SIZE + (Cs.omcw-SIZE)*(Math.cos(s.dec/100)+1)*0.5;

			case 2:
				moveHedgehog();
				s.y += 50;
				if(s.y>=GL)hit();

			case 3:
				jump *= 0.95;
				h.y += jump;
				jump += 0.6;
				if( h.y > GL ){
					h.y = GL;
					jump = -jump*0.8;
				}

			case 4:
				/*
				moveHedgehog();
				s.y += 50;
//				if(s.y>=GL)hit();
				hit();
				*/

		}
		if(shake!=null){
			shake *= 0.8;
			var s = (Math.random()*2-1)*shake;
			root.y = s;
			g.y = GL + s*0.5;
		}
		super.update();
	}

	function moveHedgehog(){
		h.dec = (h.dec+speed)%628;
		var c = Math.cos(h.dec/100);
		var x = HRAY+(Cs.omcw-HRAY*2)*(c+1)*0.5;
		h.scaleX = (x<h.x)?-1:1;
		h.x = x;
	}

	override function onClick(){
		if(step != 1)return;
		step = 2;
		s.gotoAndPlay("2");
	}

	function hit(){
		s.y = GL;
		var dx = h.x - (s.x-SIZE*0.5);
		shake = 3;
		if( Math.abs(dx) <= (SIZE*0.5+HRAY)*0.75 ){
			step = 4;
			h.scaleY = 0.2;
			setWin(false,20);
			return;
		}

		h.scaleX = (dx>0)?-1:1;
		step = 3;
		jump = -8;
		setWin(true,20);
	}

	override function outOfTime(){
		setWin(false);
	}

}


