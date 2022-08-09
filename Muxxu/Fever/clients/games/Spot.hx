import mt.bumdum9.Lib;

class Spot extends Game{//}

	static var BX = 75;
	static var EX = 416;
	static var EY = 88;

	static var DY = 80;

	var flMove:Bool;
	var spotMax:Int;
	var totalSpeed:Float;
	var ray:Int;

	var freeze:Int;
	var ox:Float;
	var oy:Float;
	var walk:Float;
	var ninja:{>flash.display.MovieClip,frame:Float};
	var spots:List<Phys>;


	override function init(dif:Float){
		gameTime =  600-100*dif;
		super.init(dif);

		spotMax = 1+Std.int(dif*10);
		totalSpeed =  (0.5+dif*0.5)*spotMax;
		ray = 20;

		walk = 0;
		ox = 50;
		oy = 50;
		freeze = 0;

		attachElements();
		box.scaleX = box.scaleY = 4;

	}

	function attachElements(){

		bg = dm.attach("spot_bg",0);

		// NINJA
		ninja  = cast dm.attach("spot_ninja",1);
		ninja.stop();
		ninja.y = DY;
		ninja.x = 50;
		ninja.frame = 0;
		ninja.gotoAndStop("jutsu");

		// SPOTS
		var light = dm.empty(3);
		light.blendMode = flash.display.BlendMode.ADD;
		light.alpha = 0.5;
		var mc = new mt.DepthManager(light).empty(0);
		mc.blendMode =  flash.display.BlendMode.LAYER;
		var ldm = new mt.DepthManager(mc);

		var rep = [0.0];
		var max = Math.min(1/(spotMax*0.66),1);
		var min = Math.min(1/(spotMax*3),1);
		while(true){
			rep = Cs.getRandRep(spotMax);
			var flBreak = true;
			for( c in rep ){
				if(c>max || c<min)flBreak = false;
			}
			if(flBreak)break;
		}

		spots = new List();
		for( c in rep ){
			var sp = new Phys(ldm.attach("spot_spot",0));
			ray = 15;
			sp.x = BX + ray + Math.random()*(EX-(BX+ray*2));
			sp.y = ray + Math.random()*(EY-ray*2);
			var a = 0.77 + Std.random(4)*1.57 + (Math.random()*2-1)*0.3;
			var speed = totalSpeed*c;
			sp.vx = Math.cos(a)*speed;
			sp.vy = Math.sin(a)*speed;
			spots.push(sp);
			//sp.root.blendMode = flash.display.blendMode.ADD;
			//sp.root._alpha = 50;
		}

		



	}
	var jutsu:Null<Bool>;
	override function update(){

		if( jutsu ) {
			jutsu = false;
			getSmc(ninja).gotoAndStop(Std.random(getSmc(ninja).totalFrames)+1);
		}
		
		var mp = getMousePos();
		var dx = mp.x - ox;
		var dy = mp.y - oy;
		var dist = Math.sqrt(dx*dx+dy*dy);
		ox = mp.x;
		oy = mp.y;


		walk += dist*0.15;

		switch(step){
			case 1 : // START
				if(walk>0){
					ninja.gotoAndStop("walk");
					step = 2;
				}
				updateSpots();
			case 2 : // WALK
				if( walk< 0 )	freeze++;
				else		freeze = 0;




				while(walk>0){
					walk--;
					ninja.nextFrame();
					if(ninja.currentFrame==30)ninja.gotoAndStop("walk");
					ninja.x++;
					box.x = (50 - ninja.x)*4;
					flMove = true;
				}

				if( ninja.x > EX-10 ){
					ninja.x = EX;
					ninja.gotoAndPlay("win");
					step = 6;
					setWin(true,20);
				}


				if( freeze == 3 && flMove ){
					step = 3;
					ninja.gotoAndPlay("jutsu");
					freeze = 0;

				}
				updateSpots();

			case 3 : // JUTSU
				if(freeze++>6){
					step = 4;
					ninja.gotoAndStop("object");
					jutsu = true;
					fxPouf();
				}
				updateSpots();
			case 4 :

				if( dist > 0.5){
					ninja.gotoAndStop("walk");
					step = 2;
					fxPouf();
					walk = -1;
					flMove = false;
				}
				updateSpots();
			case 5 :
				focusSpots();

			case 6 :
				updateSpots();

		}

		super.update();


		for(sp in spots){
			sp.recalPos(2);
		}


	}

	function updateSpots(){
		for( sp in spots ){

			if( sp.x < BX+ray || sp.x> EX-ray ){
				sp.x = Num.mm(BX+ray,sp.x,EX-ray);
				sp.vx *=-1;
			}
			if( sp.y < ray || sp.y> EY-ray ){
				sp.y = Num.mm(ray,sp.y,EY-ray);
				sp.vy *=-1;
			}
			if( step!= 4 && step!=6 ){
				var dx = sp.x - ninja.x;
				var dy = sp.y - (ninja.y-9);
				if( Math.sqrt(dx*dx+dy*dy) < ray+6 ){
					step = 5;
					ninja.gotoAndPlay("lost");
					setWin(false,40);
				}
			}

		}
	}

	function focusSpots(){
		for( sp in spots ){
			var dx = ninja.x - sp.x;
			var dy = (ninja.y-5) - sp.y;

			var a = Math.atan2(dy,dx);

			sp.frict = 0.9;
			var acc = 0.5;
			sp.vx += Math.cos(a)*acc;
			sp.vy += Math.sin(a)*acc;

		}
	}

	function fxPouf(){
		for( i in 0...12 ){
			var sp = new Phys(dm.attach("spot_smoke",2));
			sp.vx =  Math.random()*2-1;
			sp.x = ninja.x + sp.vx*5;
			sp.y = ninja.y - Math.random()*18 ;
			sp.weight = -(Math.random()*0.1);
			sp.root.gotoAndPlay(Std.random(5)+1);
		}
	}

//{
}

