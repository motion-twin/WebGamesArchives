import mt.bumdum9.Lib;
typedef WWheelPart = {>flash.display.MovieClip,mask_:flash.display.MovieClip};

class Wheel extends Game{//}

	// CONSTANTES
	static var IMG_MAX = 4;
	// VARIABLES

	var current:Int;
	var timer:Float;
	var vitr:Float;
	var wList:Array<WWheelPart>;

	// MOVIECLIPS
	var wheel:{>flash.display.MovieClip,mask_:flash.display.MovieClip};

	override function init(dif){
		gameTime = 300;
		super.init(dif);
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("wheel_bg",0);
		wList = new Array();
		//var img = Std.int((dif/101)*IMG_MAX);
		var img = Std.random(4);

		var max = 3+Math.floor(dif*4);
		var prec = 0.0;

		for( i in 0...max ){
			var mc:WWheelPart = cast dm.attach("mcBigWheel",Game.DP_SPRITE);
			mc.x = Cs.omcw*0.5;
			mc.y = Cs.omch*0.5;
			var scale = (1 - (i / max));
			mc.mask_.scaleX = scale;
			mc.mask_.scaleY = scale;
			mc.gotoAndStop(img+1);

			var rot = 0.0;
			do{
				rot = Math.random()*360;
				var dr = Num.hMod(rot-prec,180);
				if(Math.abs(dr)>30)break;
			}while(true);
			mc.rotation = rot;
			prec = rot;
			wList.push(mc);


			Filt.glow(mc,2,1,0,true);

		}
		current = max-1;




	}

	override function update(){
		//for( mc in wList )trace(mc.rotation);
		switch(step){
			case 1:
				moveWheel();
			case 2:

				var mc = wList[0];
				var dr = 0-mc.rotation;
				var lim = 5;
				vitr += Num.mm(-lim,dr*0.15,lim);
				vitr *= 0.94;
				mc.rotation += vitr;
				timer--;
				if(timer<0){
					timeProof = false;
					setWin(true,10);
				}
		}
		super.update();
	}


	function moveWheel() {
		var mc = wList[current - 1];
		var r = mc.rotation;
		var rot =(getMousePos().x/Cs.omcw)*500;

		var dr =  rot-r;
		while(dr>180)dr-=360;
		while(dr<-180)dr+=360;

		if(  Math.abs(dr) < 1.3 ){
			new mt.fx.Flash(mc);
			current--;
			if( current == 0 )victory();
		}

		for( i in current...wList.length ){
			var mc = wList[i];
			mc.rotation = rot;
		}
	}

	function victory(){
		timeProof  = true;
		step = 2;
		timer = 25;
		vitr = 0;
		while(wList.length > 1) {
			var mc = wList.pop();
			mc.parent.removeChild(mc);
		}

	}



//{
}

