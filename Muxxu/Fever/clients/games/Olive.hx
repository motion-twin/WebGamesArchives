import mt.bumdum9.Lib;
typedef OlivePic = {>flash.display.MovieClip,t:Float,step:Int};

class Olive extends Game{//}

	// CONSTANTES
	static var GL = Cs.omch-24;
	static var BG_COEF = 0.5;
	static var SPEED = 20;
	static var OL_RAY = 10;

	// VARIABLES
	var startTimer:Float;
	var pList:Array<OlivePic>;

	// MOVIECLIPS
	var ol:flash.display.MovieClip;
	var os:flash.display.MovieClip;

	override function init(dif:Float){
		gameTime = 100+dif*20;
		super.init(dif);
		startTimer = 0;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("olive_bg",0);

		// NAPPE
		var nappe = dm.attach("mcOliveNappe",Game.DP_SPRITE);


		// PIQUES
		pList = new Array();
		var m = Cs.omcw*(1-BG_COEF)*0.5;
		var max = 3+Std.int(dif*10);


		for( i in 0...max ){
			var mc:OlivePic = cast dm.attach("mcOlivePique",Game.DP_SPRITE);
			var to = 0;
			do{
				mc.x = m + Math.random()*(Cs.omcw-2*m);
				if(to++==200){
					mc.parent.removeChild(mc);
					return;
				}

			}while(touchOther(mc));

			mc.y = Cs.omch;
			mc.t = i*dif*3;
			mc.step = 0;
			mc.scaleX = BG_COEF;
			mc.scaleY = -BG_COEF;
			mc.stop();
			pList.push(mc);
		}

		dm.over(nappe);

		// OLIVE SHADE
		os = dm.attach("mcOliveShade",Game.DP_SPRITE);
		os.x = Cs.omcw*0.5;
		os.y = GL;

		// OLIVE
		ol = dm.attach("mcOlive",Game.DP_SPRITE);
		ol.x = Cs.omcw*0.5;
		ol.y = GL-14;
		ol.stop();
		

	}

	override function update(){

		switch(step){
			case 1:
				moveOlive();
				if( startTimer++ > 15 )movePiques();
			case 2:
				movePiques();
		}
		//
		super.update();
	}

	function movePiques(){
		var flWin = true;
		for( mc in pList ){

			switch(mc.step){
				case 0:
					mc.t--;
					if(mc.t < 0){
						mc.y -= SPEED*BG_COEF;
						if( mc.y < -100 ){
							var mil = Cs.omcw*0.5;
							mc.x = mil + (mc.x-mil)/BG_COEF;
							mc.scaleX = 1;
							mc.scaleY =  1;
							mc.step = 1;
							dm.over(mc);
						}
					}
					flWin = false;

				case 1:
					mc.y += SPEED;
					if( mc.y > GL ){
						mc.y = GL;
						mc.step = 2;
						mc.gotoAndStop("2");


						var dx = Math.abs(mc.x - ol.x);
						if( dx < OL_RAY ){
							//dm.over(ol);
							mc.y += dx*0.75;
							step = 2;
							ol.y += 4;
							ol.gotoAndPlay("2");
							setWin(false,24);
							mc.gotoAndStop(3);

						}else{
							mc.rotation = 5+Math.random()*2;

						}

					}
					flWin = false;

				case 2:
					mc.rotation = -mc.rotation*0.92;
					if(Math.abs(mc.rotation)>2)flWin = false;

			}

		}
		if(flWin)setWin(true);
	}


	function moveOlive(){
		// OLIVE
		var ox = ol.x;
		var dx = getMousePos().x - ol.x;
		ol.x += dx*0.15;
		ol.rotation = dx*0.3;

		// RECAL
		var m = 1;
		for(mc in pList  ){
			if( mc.step == 2 ){
				if( mc.x>ol.x-OL_RAY && mc.x-m<ox-OL_RAY )		ol.x = mc.x+OL_RAY;
				if( mc.x<ol.x+OL_RAY && mc.x+m>ox+OL_RAY )		ol.x = mc.x-OL_RAY;
			}
		}

		ol.x = Num.mm(OL_RAY, ol.x, Cs.omcw-OL_RAY );

		// SHADE
		os.x = ol.x;

	}

	function touchOther(mc:OlivePic){
		for( mco in pList )if( Math.abs(mco.x-mc.x) < 5 )return true;
		return false;
	}

	override function outOfTime(){
		setWin(true);
	}


//{
}


