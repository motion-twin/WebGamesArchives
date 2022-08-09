typedef CBBall = {>flash.display.MovieClip,t:Null<Float>,light:Bool};

class ColorBall extends Game{//}

	// CONSTANTES
	static var WAIT = 1170;
	static var ECART = 26;

	// VARIABLES
	var timer:Float;
	var bList:Array<CBBall>;



	override function init(dif:Float){
		gameTime = 400-dif*100;
		super.init(dif);
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("colorBall_bg",0);

		// BALLS
		var c = 3+Math.floor(dif*4);
		if( c>8 ) c=8;
		var m = (Cs.omcw-(c-1)*ECART)*0.5;
		bList = new Array();
		for( x in 0...c ){
			for( y in 0...c ){
				var mc:CBBall = cast(dm.attach("mcColorBall",Game.DP_SPRITE));
				mc.x = m + x*ECART;
				mc.y = m + y*ECART;
				mc.stop();
				mc.light = false;
				bList.push(mc);
				var me = this;
				mc.addEventListener(flash.events.MouseEvent.ROLL_OVER, function(e) { me.activate(mc); } );
			}
		}

	}

	override function update(){

		switch(step){
			case 1:
				var flWin = true;
				for( mc in bList){
					if(mc.light){
						mc.t --;
						if( mc.t < 0 ){
							mc.t = null;
							activate(mc);
						}
						mc.nextFrame();
					}else{
						mc.prevFrame();
					}
					if(mc.currentFrame<5)flWin = false;

				}
				if(flWin){
					timeProof = true;
					step = 2;
					timer = 18;
				}

			case 2:
				for( mc in bList){
					mc.nextFrame();
					mc.t+=6;
					if(mc.t>WAIT){
						mc.scaleX = mc.scaleX*0.7;
						mc.scaleY = mc.scaleX;
					}

				}
				timer--;
				if( timer < 0 )setWin(true,20);


		}
		super.update();
	}

	function activate(mc:CBBall){
		mc.light = !mc.light;
		if(mc.light)mc.t =WAIT;
	}


//{
}

















