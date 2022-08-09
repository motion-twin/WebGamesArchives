import mt.bumdum9.Lib;
typedef TapFly = {>Phys,trg:{x:Float,y:Float}};

class Tapette extends Game{//}

	// CONSTANTES
	static var TRAY = 24;

	// VARIABLES
	var toKill:Int;
	var timer:Float;
	var fList:Array<TapFly>;

	// MOVIECLIPS
	var tap:Phys;

	override function init(dif:Float){
		gameTime = 400-dif*100;
		super.init(dif);
		attachElements();
		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("tapette_bg", 0);
		Col.setColor(bg, 0, -20);

		// FLYS
		fList = new Array();
		toKill = 1+Math.floor(dif*12);
		for( i in 0...toKill ){
			var sp:TapFly = cast newPhys("McTapFly");
			newTrg(sp);
			sp.x = sp.trg.x;
			sp.y = sp.trg.y;
			sp.frict = 0.95;
			//sp.flPhys = false;
			//sp.weight = 1;
			sp.updatePos();
			fList.push(sp);
			sp.root.stop();
		}

		// TAPETTE
		tap = newPhys("McTapette");
		tap.x = Cs.omcw*0.5;
		tap.y = Cs.omch*0.5;
		tap.frict = 0.95;
		tap.updatePos();
	}

	override function update(){

		// MOVE TAPETTE
		var mp = getMousePos();
		mp.y -= 60;
		var ox = tap.x;
		tap.toward(mp,0.2,null);
		var dx = tap.x-ox;
		tap.root.rotation = -dx*1.5;


		// MOVE FLYS
		for( sp in fList ){
			if(sp.weight==null){
				var dist = sp.getDist(sp.trg);

				if( dist<20 || Math.random() < 0.04 )newTrg(sp);
				sp.towardSpeed(sp.trg,0.1,0.8);

				// ESQUIVE
				var ray = dif;
				var td = sp.getDist(tap);
				if( td < ray ){
					var a = tap.getAng(sp);
					var d = ray-td;
					var c = 0.04;
					sp.x += Math.cos(a)*d*c;
					sp.y += Math.sin(a)*d*c;
				}

				// ORIENT
				var a = sp.getAng(sp.trg);
				var fr = Std.int((a/6.28)*40);
				if(fr<0)fr+=40;
				sp.root.gotoAndStop(fr + 1);
				
				// FLY
				var mc:McTapFly = cast sp.root;
				mc.a0.gotoAndPlay(Std.int(mc.x%2)+1);
				mc.a1.gotoAndPlay(Std.int(mc.x%2)+1);
				
				
			}
		}


		switch(step){
			case 2:
				timer --;
				if(timer<0) {
					setWin(true,10);
				}
		}

		super.update();
	}

	override function onClick(){

		var touched = 0;
		var flFlash = false;
		for( sp in fList ){
			if(sp.weight==null){

				var dx = sp.x - tap.x;
				var dy = sp.y - tap.y;
				if( Math.abs(dx)<TRAY && Math.abs(dy)<TRAY ){
					touched++;
					sp.weight = 1;
					sp.vx = 0;
					sp.vy = 0;
					toKill--;
					if(toKill==0){
						step=2;
						timer = 12;
					}
					sp.root.gotoAndStop("death");
					sp.root.rotation = Math.random()*360;

					var mc = dm.attach("mcFlyTache",Game.DP_SPRITE2);
					mc.x = sp.x;
					mc.y = sp.y;
					mc.rotation = Math.random()*360;
					mc.gotoAndStop(Std.random(mc.totalFrames)+1);
					flFlash = true;

				}
			}
		}
		tap.root.gotoAndPlay("2");
		var mc:McTapette = cast(tap.root);
		mc.flh.visible = flFlash;
	}

	function newTrg(sp){
		var m = 30;
		sp.trg = {
			x: m+Math.random()*(Cs.omcw-2*m),
			y: m+Math.random()*(Cs.omch-2*m),
		}
	}




//{
}

