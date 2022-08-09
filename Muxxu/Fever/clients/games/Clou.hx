import mt.bumdum9.Lib;
class Clou extends Game{//}



	// CONSTANTES
	static var mcw = 240;
	static var mch = 240;
	static var GL = 192;
	static var CH = 65;
	static var CRAY = 8;


	// VARIABLES
	var flLeft:Bool;
	var ray:Float;
	var power:Float;
	var seuil:Float;

	// MOVIECLIPS
	var ham:Phys;
	var clou:flash.display.MovieClip;

	override function init(dif){
		gameTime = 280;
//		dif = 1.595;
		super.init(dif);
		ray = 40-dif*25;
		seuil = 2+dif*6.5;
		power = 0;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("clou_bg",0);

		// HAMMER
		ham = newPhys("mcBigHammer");
		ham.x = mcw;
		ham.y = mch*0.5;
		ham.frict = 0.92;
		ham.updatePos();
		ham.root.scaleX = ray*0.02;
		ham.root.scaleY = ray*0.02;

		//
		clou = cast (bg).clou_;
	
	}

	override function update(){

		var mp = getMousePos();
		
		var oy = ham.y;
		var dx = mp.x - ham.x;
		var lim = 1;
		ham.vx += Num.mm(-lim,dx*0.05,lim);


		var dy = mp.y - ham.y;
		var c = 0.2;
		if(dy>0)c = 0.5 ;
		ham.y += dy*c;



		switch(step){
			case 1:
				if( ham.y > clou.y - CH ){

					var dfx = ham.x - clou.x;
					if( Math.abs(dfx) < ray+CRAY ){
						if(power>seuil){

							power-=seuil;
							var max = (GL+CH)-4;
							clou.y = Math.min( clou.y+power, max );
							if(clou.y==max)setWin(true,20);
						}
						ham.y = clou.y - CH;
						ham.vx *= 0.5;
					}else{
						step=2;
						flLeft = dfx<0;
					}
					power = 0;
				}
			case 2:
				if( ham.y < clou.y - CH ){
					step = 1;
				}else{

					if( flLeft && ham.x > clou.x-(CRAY+ray) ){
						ham.x = clou.x-(CRAY+ray);
						ham.vx *= 0.1;
					}

					if( !flLeft && ham.x < clou.x+(CRAY+ray) ){
						ham.x = clou.x+(CRAY+ray);
						ham.vx *= 0.1;
					}

					if( ham.y > GL ){
						ham.y = GL;
						power = 0;
					}
				}

			case 3:

		}

		var dif = (ham.y-oy);
		power *= 0.5;
		if(dif>0)power += dif*0.2;


		ham.root.rotation = 40*Math.max(0,(1-(ham.y*2/mch)));


		super.update();
	}


//{
}















