typedef PlateTache = {mc:flash.display.MovieClip,ray:Float,life:Float};


class Plate extends Game{//}

	// CONSTANTES

	// VARIABLES
	var depthRun:Int;
	var pRay:Int;
	var sRay:Float;

	var tache:Array<PlateTache>;
	var op:{x:Float,y:Float};
	var pdm:mt.DepthManager;

	// MOVIECLIPS
	var plate:Sprite;
	var sponge:Sprite;


	override function init(dif){
		gameTime = 320;
		super.init(dif);
		pRay = 50;
		sRay = 30 - dif*15;
		depthRun = 0;
		op={x:0.0,y:0.0};
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg= dm.attach("plate_bg",0);


		// PLATE
		plate =  newSprite("mcPlate");
		plate.x = Cs.omcw*0.5;
		plate.y = Cs.omch*1.5;
		plate.root.scaleX = pRay*0.02;
		plate.root.scaleY = pRay*0.02;
		plate.updatePos();

		// TACHES
		tache = new Array();
		var max = Math.round(6+dif*9);
		pdm = new mt.DepthManager(plate.root);
		for( i in 0...max ){
			//var mc = Std.attachMC( plate.root, "mcTache", i );
			var mc = pdm.attach("mcTache",0);
			var ray = 10+dif*10+Std.random(30);
			var d = Std.random(Std.int(100-ray));
			var a = Std.random(628)/100;
			mc.x = Math.cos(a)*d;
			mc.y = Math.sin(a)*d;
			mc.scaleX = ray*0.02;
			mc.scaleY = ray*0.02;
			mc.alpha = 1;
			mc.rotation = Std.random(360);
			mc.gotoAndStop(Std.random(mc.totalFrames)+1);
			tache.push({mc:mc,ray:ray*1.0,life:ray*1.0});
		}


		// SPONGE
		sponge = newSprite("mcSponge");
		sponge.x = Cs.omcw*0.5 + 70;
		sponge.y = Cs.omch*0.5 - 20;
		sponge.root.scaleX = sRay*0.02;
		sponge.root.scaleY = sRay*0.02;
		sponge.updatePos();

		// PART WATER
		flSplash = false;

	}
	var flSplash:Bool;
	function splash() {
		flSplash = true;
		for( i in 0...10 ){
			var mc = pdm.attach("mcPartWaterFlow",0);
			var d = Std.random(100);
			var a = Std.random(628)/100;
			mc.x = Math.cos(a)*d;
			mc.y = Math.sin(a)*d;
			mc.scaleX = 0.5+Math.random()*0.5;
			mc.scaleY = mc.scaleX;
			mc.gotoAndPlay(Std.random(10)+1);
		}
	}
	
	function isIn(dx:Float,dy:Float) {
		
	}

	override function update(){
		super.update();
		if( !flSplash ) splash();
		switch(step){
			case 1:
				// PLATE
				plate.toward({x:Cs.omcw*0.5,y:Cs.omch*0.5},0.2,null);

				// MOVE SPONGE
				sponge.toward(getMousePos(),0.5,null);
				var power = sponge.getDist(op)*0.1;

				// MOUSSE
				var max = Math.round(power);
				var dx = sponge.x - plate.x;
				var dy = sponge.y - plate.y;
				for( i in 0...max ){
					
					var d = Std.random(Std.int(sRay));
					var a = Std.random(628)/100;
					var x = dx+Math.cos(a)*d;
					var y = dy + Math.sin(a) * d;

					if( Math.sqrt(x*x+y*y) < 100 ){
						depthRun++;
						var mc = pdm.attach( "mcMousse", 2 );
						mc.x = x;
						mc.y = y;
						mc.scaleX = 1+(Math.random()*2-1)*0.5;
						mc.scaleY = mc.scaleX;
						mc.rotation = Std.random(360);
						mc.gotoAndPlay(Std.random(3)+1);
					}

				}



				// CLEAN TACHE
				var efCoef = 1.0;
				var a = tache.copy();
				for( o in a ){
					var dist = sponge.getDist({x:o.mc.x+plate.x,y:o.mc.y+plate.y});
					var c = 1-(dist/(sRay+o.ray));

					if( c > 0 ){
						o.life = Math.max( 0, o.life-c*power*efCoef );
						o.mc.alpha = (o.life/o.ray);
						if( o.life == 0 )tache.remove(o);
						efCoef*=0.5;
					}

				}

				// CHECK WIN
				if( tache.length == 0 ) {
					
					for( i in 0...24 ) {
						var mc = new FxShine();
						var a = Math.random() * 6.28;
						var dist = Math.pow(Math.random(), 0.5) * 110;
						mc.x = plate.x + Math.cos(a) * dist;
						mc.y = plate.y + Math.sin(a) * dist;
						mc.gotoAndPlay(Std.random(15)+1);
						mc.scaleX = mc.scaleY = 0.5 + Math.random() * 0.5;
						dm.add(mc, Game.DP_PART);
					}
					
					setWin(true, 25);
					step = 2;
				}

				// OLD POS
				op = { x:sponge.x, y:sponge.y }
			
			case 2:
				sponge.y += 20;

		}
		//
		

	}





//{
}

