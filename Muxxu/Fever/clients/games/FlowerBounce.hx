import mt.bumdum9.Lib;
typedef FBFlower = {>flash.display.MovieClip,fleur:flash.display.MovieClip,ray:flash.display.MovieClip,rm:Bool,dec:Float};



class FlowerBounce extends Game{//}

	// CONSTANTES
	static var RAY = 11;
	static var FRAY = 15;
	static var MRAY = 13;

	// VARIABLES
	var scrx:Float;
	var gl:Float;
	var speed:Float;
	var fList:Array<FBFlower>;
	var mList:Array<flash.display.MovieClip>;

	var power:Float;
	var pc:Float;

	// MOVIECLIPS
	var ball:Phys;
	var shade:flash.display.MovieClip;


	override function init(dif:Float){
		gameTime = 500-Std.int(dif*100);
		super.init(dif);
		gl = Cs.omch-6;
		speed = 0;
		power = 20;
		pc = 1;
		scrx = 0.0;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("flowerBounce_bg",0);

		// FLOWER
		fList = new Array();
		for( i in 0...3 ){
			var mc:FBFlower = cast dm.attach("mcBallSeekerFlower",Game.DP_SPRITE);
			while(mc.x == 0 || Math.abs(mc.x-Cs.omcw*0.5) < 30 )mc.x = FRAY+Math.random()*(Cs.omcw*2-FRAY*2);
			mc.y = FRAY+Math.random()*100;
			mc.scaleX = 0.75;
			mc.scaleY = 0.75;
			mc.dec = Math.random()*628;
			mc.rm = false;
			fList.push(mc);
		}

		// MONSTER
		mList = new Array();
		var max = Math.floor(dif*7);
		for( i in 0...max ){
			var mc = dm.attach("mcBallSeekerBomb",Game.DP_SPRITE);
			while(mc.x == 0 || Math.abs(mc.x-Cs.omcw*0.5) < 30 )mc.x = MRAY+Math.random()*(Cs.omcw*2-MRAY*2);
			mc.y = MRAY+Math.random()*(Cs.omch-MRAY*3);
			mList.push(mc);
		}

		// SHADE
		shade = dm.attach("mcBallSeekerShade",Game.DP_SPRITE);
		shade.x = Cs.omcw*0.5;
		shade.y = gl;

		// BALL
		ball = newPhys("mcBallSeeker");
		ball.x = Cs.omcw*0.5;
		ball.y = Cs.omch*0.5;
		ball.weight = 1;
		ball.updatePos();
		ball.root.stop();
		ball.frict = 1;

	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				updateBall();
				updateFlower();
				//
				var a = mList.copy();
				for(mc in a ){
					var dist = ball.getDist({x:mc.x,y:mc.y});

					if(dist<MRAY+RAY){
						pc = 0.01;

						var p = newPhys("partSeekerPlouch");
						p.x = mc.x;
						p.y = mc.y;
						p.updatePos();
						mc.parent.removeChild(mc);
						mList.remove(mc);
					}

				}

				//
				if(fList.length==0)setWin(true,10);


				// SCROLL
				var sx = Num.mm( -Cs.omcw ,-(ball.x-Cs.omcw*0.5), 0 ) -scrx;
				scrx += sx*0.1;
				box.x = scrx*Cs.mcw/Cs.omcw;


		}



	}

	function updateBall() {
		//var mpp = getMousePos();
		//var bp = box.localToGlobal(new flash.geom.Point(ball.x, ball.y));
		//var mp = box.localToGlobal(new flash.geom.Point(mpp.x, mpp.y));
		//var dx = mp.x - bp.x;
		var dx = box.mouseX - ball.x;
		speed += dx*0.01*pc;
		speed *= 0.9;
		ball.root.rotation += speed*8;

		pc = Math.min((pc+0.003)*1.008,1);
			if( ball.y+RAY > gl ){
			ball.y = gl-RAY;
			ball.vy = -power*pc;
			ball.vx = speed;
		}

		var bound = -0.8;
		if( ball.x < RAY || ball.x > Cs.omcw*2 - RAY ){
			ball.x = Num.mm(RAY,ball.x,Cs.omcw*2 - RAY);
			ball.vx *= bound;
		}
		//
		var frame = "1";
		if(pc<0.5){
			frame = "2";
			if(Std.random(Std.int(20*pc))==0){
				var p = newPhys("partSeekerKofKof");
				p.x = ball.x+(Math.random()*2-1)*RAY*0.8;
				p.y = ball.y+(Math.random()*2-1)*RAY*0.8;

				p.weight = -(0.1+Math.random()*0.1);
				p.vx = (Math.random()*2-1)*1.5;
				p.updatePos();
				p.root.rotation = Math.random()*360;
				p.frict = 1;
			}
		}
		ball.root.gotoAndStop(frame);

		var mc = getMc(ball.root,"light");
		if(mc!=null)mc.rotation = -ball.root.rotation;


		//ball.x = Num.mm(RAY,ball.x,Cs.omcw*2-RAY);

		//
		ball.root.x = ball.x;
		ball.root.y = ball.y;
		shade.x = ball.x;



	}

	function updateFlower(){
		var flDone = true;
		var a = fList.copy();
		for( mc in a ){
			var dist = ball.getDist({x:mc.x,y:mc.y});

			mc.dec = (mc.dec+40)%628;
			mc.fleur.rotation += 1.5;
			mc.ray.rotation++;


			if(mc.rm){
				mc.scaleX *= 0.5;
				mc.scaleY = mc.scaleX;
				if(mc.scaleX < 0.02){
					mc.parent.removeChild(mc);
					fList.remove(mc);
				}
			}else{
				if(dist<FRAY+RAY){
					mc.rm = true;
					mc.fleur.visible = false;
					for( n in 0...8){
						var p = newPhys("partRayArc");
						p.x = mc.x;
						p.y = mc.y;
						p.vr = 0.5+Math.random()*4;
						p.fadeType = 3;
						p.timer = 10 + Std.random(10);
						p.updatePos();
						p.root.rotation = Math.random()*360;
						p.root.scaleX = 0.6+Math.random()*0.8;
					}

				}
				flDone = false;
			}
		}
		if(flDone)timeProof = true;
	}



//{
}

