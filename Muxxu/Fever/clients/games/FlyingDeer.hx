import mt.bumdum9.Lib;
class FlyingDeer extends Game{//}

	// CONSTANTES
	static var RAY = 22;
	// VARIABLES
	var startTimer:Float;
	var cx:Float;
	var angle:Float;
	var speed:Float;
	var posList:Array<{x:Float,y:Float,r:Float}>;
	var hList:Array<Phys>;
	var cList:Array<flash.display.MovieClip>;
	var fList:Array<flash.display.MovieClip>;
	var cloudList:Array<flash.display.MovieClip>;

	// MOVIECLIPS
	var shade:flash.display.MovieClip;
	var line:flash.display.MovieClip;
	var kite:Phys;

	override function init(dif){
		gameTime = 360;
		super.init(dif);
		angle = -1.57;
		speed = 2+(dif*3);
		attachElements();
		zoomOld();
		startTimer = 0;
	}

	function attachElements(){

		bg = dm.attach("flyingDeer_bg",0);

		// SHADE
		shade = dm.attach("mcKiteShade",Game.DP_SPRITE);
		shade.x = Cs.omcw*0.5;
		shade.y = Cs.omch;

		// LIGNE
		line = dm.empty(Game.DP_SPRITE);

		// KITE
		kite = newPhys("mcKite");
		kite.x = Cs.omcw*0.5;
		kite.y = Cs.omch-30;
		kite.updatePos();
		kite.frict = 0.92;

		// KYTE FLY
		fList = new Array();
		for( i in 0...4 ){
			var mc = dm.attach("mcKyteFly",Game.DP_SPRITE);
			mc.gotoAndStop(i+1);
			fList.push(mc);
		}
		posList = new Array();
		var last = {x:kite.x,y:kite.y+speed,r:-90.0};
		while(posList.length<50){
			var pos = {x:last.x,y:last.y+speed,r:-90.0};
			posList.push(pos);
			last = pos;
		}


		// HANDS
		hList = new Array();
		for( i in 0...2 ){
			var sp = newPhys("mcKiteHand");
			sp.x = Cs.omcw*0.5;
			sp.y = Cs.omch;
			sp.frict = 0.92;
			sp.updatePos();
			sp.root.stop();
			hList.push(sp);
		}

		// CORDES
		cList = new Array();
		for( i in 0...2 ){
			var mc = dm.attach("mcKiteRope",Game.DP_SPRITE);
			cList.push(mc);
		}

		// ** CLOUDS **
		cloudList = new Array();
		for( i in 0...3 ){
			var mc = Reflect.field(bg,"$c"+i);
			//var mc = Std.getVar(this,"$c"+i);
			cloudList.push(mc);
		}


	}

	override function update(){

		startTimer++;
		kite.frict = Math.min((startTimer/40),1)*0.92;

		speed *= 1.001;

		cx = getMousePos().x/Cs.omcw;
		moveHands();
		moveKite();
		moveClouds();

		super.update();
	}

	function moveHands(){
		//line.graphics.clear();
		for( i in 0...2 ){
			var sp = hList[i];

			// MOVE
			var m = 8;
			var p ={
				x:m+cx*(Cs.omcw-2*m)+(i*2-1)*35,
				y:(Cs.omch+20)-(1-(kite.y/Cs.omch))*50
			}
			sp.towardSpeed(p,0.1,0.5);

			// ANIM
			var a = sp.getAng(kite)+1.57;
			var frame = 17+Std.int(Num.mm(-1, a ,1)*16);
			sp.root.gotoAndStop(frame);


			// CORDE
			var p0 = {
				x:sp.x+getMc(sp.root,"v").x,
				y:sp.y+getMc(sp.root,"v").y
			}

			var a2 = angle+1.57*(i*2-1);
			var p1 = {
				x:kite.x+Math.cos(a2)*RAY,
				y:kite.y+Math.sin(a2)*RAY
			}

			var rope = cList[i];
			rope.x = p0.x;
			rope.y = p0.y;

			var dx = p1.x - p0.x;
			var dy = p1.y - p0.y;

			var ang = Math.atan2(dy,dx);
			var dist = Math.sqrt(dx*dx+dy*dy);

			rope.rotation = ang/0.0174;
			rope.scaleX = dist*0.01;

			//Log.print(rope.x+";"+rope.y)

			//line.graphics.lineStyle(1,0x000000,100)
			//line.graphics.moveTo(p0.x,p0.y)
			//line.graphics.lineTo(p1.x,p1.y)



		}
	}

	function moveKite(){
		var lim = 0.5;

		if(step!=2)angle += Num.mm(-lim,(cx*2-1)*0.1,lim);

		var sp = speed * (1+(kite.y/Cs.omch)*0.5);

		kite.root.rotation = angle/0.0174;
		kite.vx = Math.cos(angle)*sp;
		kite.vy = Math.sin(angle)*sp;

		//
		var px = kite.x + Math.cos(angle+3.14)*40;
		var py = kite.y + Math.sin(angle+3.14)*40;

		line.graphics.clear();
		line.graphics.lineStyle(1,0xDDDDAA,50);
		line.graphics.moveTo(px,py);
		var i = 0;
		for( mc in fList ){
			var pos = posList[posList.length-(3+i*4)];
			mc.x = pos.x;
			mc.y = pos.y;
			mc.rotation = pos.r+90;
			line.graphics.lineTo(pos.x,pos.y);
			i++;
		}


		posList.push({x:px,y:py,r:kite.root.rotation});
		while(posList.length>50)posList.shift();
		shade.x = kite.x;

		//
		var m = 30;
		var g = 10;
		if( kite.x > Cs.omcw+m || kite.x < -m || kite.y <-m || kite.y > Cs.omch-g ){
			setWin(false,5);
			step = 2;
			if(kite.y> Cs.omcw-g){
				kite.vy*=-0.5;
				angle = Math.atan2(kite.vy,kite.vx);
			}
		}

		//

	}

	function moveClouds(){
		var i = 0;
		for( mc in cloudList ){
			mc.x += (0.3-i*0.1);
			i++;

		}
	}

	override function outOfTime(){
		setWin(true);
	}


//{
}

















