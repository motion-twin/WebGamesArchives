import Protocole;

class Flower extends Game{//}

	// VARIABLES
	var groundLevel:Int;
	var grow:Float;
	var timer:Float;
	var speed:Float;
	var size:Float;
	var decal:Float;
	var goutteList:Array<Phys>;

	// MOVIECLIPS
	var nuage:flash.display.MovieClip;
	var flower:flash.display.MovieClip;


	override function init(dif:Float){
		gameTime = 300 - dif*150;
		super.init(dif);
		speed = 8 + dif*20;
		size = 70 - (dif*30);
		decal = 0;
		grow = 0;
		groundLevel = Cs.omch-34;
		goutteList = new Array();
		attachElements();
		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("flower_bg",0);

		// NUAGE
		nuage = dm.attach( "mcNuage", Game.DP_SPRITE);
		nuage.x = Cs.omcw*0.5;
		nuage.y = 30;
		nuage.scaleX = size*0.01;
		nuage.scaleY = size*0.01;

		// FLOWER
		flower = dm.attach( "mcFlower", Game.DP_SPRITE);
		var m = 60;
		flower.x = m+Std.random(Cs.omcw-2*m);
		flower.y = (groundLevel+Cs.omch)*0.5;
		flower.stop();

	}

	override function update(){
		switch(step){
			case 1:
				// NUAGE
				decal = (decal+speed)%628;
				var m =  Cs.omcw*0.5;
				nuage.x = m + Math.cos(decal/100)*(m-nuage.width*0.5);
				updateNuage();

				// GOUTTE
				moveGoutte();

				// CHECK LOOSE
				if( size == 0 && goutteList.length == 0 ){
					setWin(false);
				}
		}
		//
		super.update();
	}

	override function onClick(){
		if(size>0){
			size = Math.max( 0, size-10 );
			var mc = newPhys("mcGoutte");
			mc.x = nuage.x;
			mc.y = nuage.y+20;
			mc.weight = 0.5;
			mc.updatePos();
			goutteList.push(mc);
		}
	}

	function updateNuage(){
		nuage.scaleX = nuage.scaleX*0.5 + size*0.01*0.5;
		nuage.scaleY = nuage.scaleX;
	}

	function incGrow(s){
		///Log.trace(s)
		grow = Math.min(grow+s,1);
		var frame = Math.floor(grow*(flower.totalFrames-1))+1;
		flower.gotoAndStop(frame);
		if( grow == 1 ) setWin(true,20);
	}

	function moveGoutte(){

		var a = goutteList.copy();
		for( mc in a ){
			if( mc.y > groundLevel ){
				var d = Math.abs(mc.x-flower.x);
				var limit = 30;

				if(d<limit)	incGrow( (limit-d)*0.02 );


				for( n in 0...10 ){
					var g = newPhys("mcPartGoutte");
					g.x = mc.x;
					g.y = mc.y;
					g.vx = 6*(Math.random()*2-1);
					g.vy = -(2+Math.random()*6);
					g.scale = 0.4+Math.random()*0.6;
					g.weight = 0.3;
					g.timer = 10+Std.random(10);
					g.fadeType = 0;
					g.updatePos();
				}

				mc.kill();
				goutteList.remove(mc);
			}

		}


	}


//{
}




