import mt.bumdum9.Lib;
import Protocole;
typedef GeyserElement = {>Phys,ray:Int,z:Float,vz:Float,tm:Float,flGlassUp:Null<Bool>,flTubeUp:Null<Bool>};
typedef TubeElement = {>flash.display.MovieClip,tx:Float,ty:Float,vy:Float};

class Geyser extends Game{//}

	// CONSTANTES
	var gRay:Float;
	var bRay:Float;
	var tRay:Float;
	var gl:Float;

	// RIEN
	var truc : String;

	// VARIABLES
	var flBall:Bool;
	var fallTimer:Float;
	var tubeHeight:Float;
	var eList:Array<GeyserElement>;
	var fList:Array<TubeElement>;
	var pression:Int;

	var tubeNum:Int;
	var tubeObj:Int;
	
	var arrow:McGeyserArrow;

	// MOVIECLIPS
	var glass:Phys;
	var tube:{>flash.display.MovieClip,dm:mt.DepthManager};
	var runner:{>flash.display.MovieClip,vx:Float};

	override function init(dif){

		gameTime = 520;
		super.init(dif);

		gRay  = 20;
		//bRay = 5;
		//tRay = 8;
		bRay = 4;
		tRay = 9;
		
		pression  = 0;
		gl = Cs.omch-8;

		tubeNum = 0;
		tubeObj = 3+Math.round(dif*8);

		tubeHeight = tubeObj*(bRay*2*0.85);

		eList = new Array();
		fList = new Array();

		attachElements();

		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("geyser_bg",0);


		// RUNNER
		runner = cast dm.attach("mcGeyserRunner",Game.DP_SPRITE);
		runner.x = Cs.omcw*0.5;
		runner.y = gl;
		runner.vx = -4;

		// TUBE
		tube =  cast dm.empty(Game.DP_SPRITE);//downcast(dm.attach("mcGeyserTube",Game.DP_SPRITE))
		tube.x = Cs.omcw - (tRay+4);
		tube.y = Cs.omch;
		tube.dm = new mt.DepthManager(tube);
		var mc = tube.dm.attach("mcGeyserTube",2);
		mc.scaleY = tubeHeight*0.01;


		// ARROW
		arrow = new McGeyserArrow();
		arrow.x = tube.x;
		arrow.y = tube.y - (tube.height + 10);
		dm.add(arrow, Game.DP_SPRITE);


		// GLASS
		glass = newPhys("mcGeyserGlass");
		glass.x = Cs.omcw*0.5;
		glass.y = Cs.omch*0.5;
		glass.root.stop();
		glass.updatePos();

	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				genElements();
				moveElements();
				moveGlass();

				var a = fList.copy();
				for( mc in a ){
					mc.vy += 0.4;
					mc.vy *= 0.98;
					mc.y += mc.vy;
					if(mc.y > mc.ty){
						mc.y = mc.ty;
						mc.x = mc.tx;
						fList.remove(mc);
					}
				}

				if(runner.rotation>0 ){
					runner.vx*=0.9;
				}else{
					var m = 5;
					if(runner.x < m ){
						runner.x = m;
						turn();

					}
					if(runner.x > Cs.omcw-(m+28) ){
						runner.x = Cs.omcw-(m+28);
						turn();
					}

					if(Std.random(60)==0)turn();

				}

				runner.x += runner.vx;

			case 2:


		}
		//

	}

	function turn(){
		runner.vx *= -1;
		runner.scaleX *= -1;
	}


	function genElements(){

		for( i in 0...1 ){

			var sp = newElement();
			if( Std.random(16) == 0  || pression > 16) {
				morphToBall(sp);
				pression = 0;
			} else {
				pression++;
			}
			sp.updatePos();


		}


	}

	function newElement(){
			var sp:GeyserElement = cast newPhys("mcCouscous");
			sp.x = Cs.omcw*0.5 + (Math.random()*2-1)*10 ;
			sp.y = Cs.omch + Math.random()*5 -55 ;
			var a = (Math.random()*2-1)*0.4 - 1.57;
			var p = 5+Math.random()*10;
			sp.vx = Math.cos(a)*p;
			sp.vy = Math.sin(a)*p;
			sp.vz = (Math.random()*2-1)*p;
			sp.weight = 0.2;
			sp.ray = 4;
			sp.z = 0;
			sp.tm= 2000;//Math.random()*60
			sp.vr = Math.random()*5;

			sp.root.rotation = Math.random()*360;
			sp.root.gotoAndStop(Std.random(2)+1);
			sp.updatePos();
			eList.push(sp);
			return sp;
	}

	function morphToBall(el:GeyserElement){
		el.root.gotoAndStop("3");
		el.flGlassUp = false;
		el.flTubeUp = false;
		el.weight = 0.4;
		el.vz = 0;
	}

	function moveElements(){

		var ae = eList.copy();
		for( sp in ae ){

			sp.vz *= 0.96;
			sp.z +=sp.vz;

			var prc = Math.min(Math.max(0,20+sp.z*0.4),80);
			//Mc.setPercentColor(sp.root,prc,0x479E4B);
			Col.setPercentColor(sp.root,prc*0.01,0x479E4B);


			// CHECK GLASS
			if( glass.root.rotation<5 && sp.vy>0 && sp.flGlassUp!=null ){
				var flUp = sp.y < glass.y;
				if( !flUp && sp.flGlassUp ){
					var dx = Math.abs(glass.x-sp.x);
					if( dx < gRay-bRay ){
						if( glass.root.currentFrame == 5 ){
							sp.vy *= -0.8;
							sp.y = glass.y;
						}else{
							glass.vy += 6;
							glass.root.nextFrame();
							sp.tm = 0;
						}
					}else if( dx < gRay+bRay ){

					}
				}

				sp.flGlassUp = flUp;
			}

			// CHECK TUBE
			if( sp.tm>0 && sp.vy>0 && sp.flTubeUp!=null ){
				var flUp = sp.y < (tube.y - tubeHeight);
				if( !flUp && sp.flTubeUp ){
					var dx = Math.abs(tube.x-sp.x);
					if( dx < (tRay-bRay)*1.2 ){
						if( tubeNum < tubeObj ){
							tubeNum++;
							var mc:TubeElement = cast tube.dm.attach("mcCouscous",1);
							mc.y = -tubeHeight;
							mc.vy = sp.vy;
							mc.ty = bRay-tubeNum*(bRay*2*0.85);
							mc.tx = ((tubeNum%2)*2-1)*(tRay-bRay)*0.7;
							mc.gotoAndStop(3);
							fList.push(mc);
							sp.tm = 0;

							if(tubeNum ==tubeObj)setWin(true,10);

						}
						arrow.visible = false;

					}else if( dx < tRay+bRay ){
						if(sp.vy>2)sp.vy *= -0.8;
					}
				}

				sp.flTubeUp = flUp;
			}

			// REBOND
			if( sp.flGlassUp!=null ){
				//ssp.root._alpha = 50
				if( sp.vy>2 && runner.rotation == 0 && sp.y > gl-(bRay+20) && Math.abs(runner.x-sp.x) < bRay*2 ){
					runner.gotoAndPlay("dead");
					runner.rotation = 0.5;
					sp.y = gl-(bRay+20);
					sp.vy *= -0.5;
					sp.vr = (Math.random()*2-1)*20;
				}


				if( sp.y > gl-bRay  ){
					sp.y = gl-bRay;
					sp.vy *= -0.5;
					sp.vr = (Math.random()*2-1)*20;
					if(sp.tm >20)sp.tm = 10+Math.random()*10;
				}
			}


			sp.tm--;
			if(sp.tm<10){
				sp.root.scaleX = sp.tm*0.1;
				sp.root.scaleY = sp.root.scaleX;
			}


			if( sp.x < sp.ray || sp.x > Cs.omcw+sp.ray || sp.y > Cs.omch+sp.ray || sp.tm<0 ){
				eList.remove(sp);
			}

		}
	}

	function moveGlass() {
		
		var m = getMousePos();
		m.y += 10;
		glass.toward( m, 0.4, null );

		var dr = -glass.root.rotation;
		if(click){
			dr  = 90 - glass.root.rotation;

			if( dr < 5 && glass.root.currentFrame > 1){
				fallTimer--;
				if( fallTimer < 0 ){
					var sp = newElement();
					sp.x = glass.x + bRay;
					sp.y = glass.y + (gRay-bRay*2);
					sp.vx = 0.1+Math.random()*0.5;
					sp.vy = 0;
					sp.vz = 0;
					morphToBall(sp);
					sp.updatePos();
					fallTimer = 8;
					glass.root.prevFrame();
				}
			}

		}else{
			fallTimer = 0;
		}
		glass.root.rotation += dr*0.3;
	}



//{
}















