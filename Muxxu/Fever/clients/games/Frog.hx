import mt.bumdum9.Lib;

class Frog extends Game{//}

	// CONSTANTES
	var mancheSize:Int;
	var canneSize:Int;
	var limit:Int;
	var gl:Int;
	var tensionMax:Int;
	var nerveMax:Int;

	// VARIABLES
	var flEat:Bool;
	var nerve:Float;
	var dx:Float;
	var dy:Float;
	var cRot:Float;
	var bRot:Float;
	var looseTimer:Null<Float>;
	var camBox:{ xMin:Float, xMax:Float, yMin:Float, yMax:Float, cx:Float, sp:Float };
	var ob:{x:Float,y:Float};

	// MOVIECLIPS
	var decor:flash.display.MovieClip;
	var fil:flash.display.MovieClip;
	var frog:Phys;
	var bait:Phys;
	var canne:Sprite;

	override function init(dif){
		gameTime = 360;
		super.init(dif);
		mancheSize = 30;
		canneSize = 80;
		tensionMax = 80;
		limit = 700;
		gl = Cs.omch-10;
		cRot = -1.57;
		bRot = 0;
		nerveMax = 1000;
		nerve = nerveMax;
		flEat = false;
		camBox = {xMin:-9999.9,xMax:9999.9,yMin:0.0,yMax:0.0,cx:0.1,sp:1.0};
		attachElements();
		ob = {x:bait.x,y:bait.y};
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("frog_bg",0);

		// FROG
		frog = newPhys("mcFrog");
		frog.x = limit-(50+dif*250);
		frog.y = gl;
		//frog.weight = 1;
		//frog.flPhys = false;
		frog.updatePos();

		// CANNE
		canne = newSprite("mcCanne");
		canne.x = Cs.omcw*0.5;
		canne.y = Cs.omch*0.5;
		canne.root.rotation = cRot/0.0174;
		canne.updatePos();

		// APPAT
		bait = newPhys("mcFrogBait");
		bait.x = Cs.omcw-0.5;
		bait.y = Cs.omch-0.5;
		bait.weight = 0.7;
		bait.updatePos();

		// FIL
		fil = dm.empty(Game.DP_SPRITE);

		// DECOR
		decor = dm.attach( "mcFrogDecor", Game.DP_SPRITE );
		decor.y = gl;


	}

	override function update(){
		super.update();
		
		switch(step){
			case 1:
				moveCam();
				moveCanne();
				checkFrog();
				ob = {x:bait.x,y:bait.y};

			case 2:
				moveCam();
				moveCanne();
				if(flEat){
					frog.x = bait.x;
					frog.y = bait.y;
					var dr = -90 - frog.root.rotation;
					frog.vr += dr*0.01;
				}else{

					checkLand();
					if(frog.weight!=null){
						var a = Math.atan2(frog.vy,frog.vx);
						frog.root.rotation = a/0.0174;
						checkEat();
					}
				}
				//
				if(looseTimer!=null){
					looseTimer--;
					if(looseTimer<0){
						setWin(false,30);
						looseTimer = 0;
					}
				}

		}
		//
		canne.root.x = canne.x;
		canne.root.y = canne.y;
		bait.root.x = bait.x;
		bait.root.y = bait.y;

	}

	function moveCam(){
		var cc = 0.6;
		var c = camBox.sp;

		var x = Cs.omcw*camBox.cx - frog.x;
		var y = Cs.omch*0.5 - frog.y;

		
		var dx = x/cc - box.x;
		var dy = y/cc - box.y;

		
		var co = camBox.sp;
		box.x += dx * co;
		box.y += dy * co;

		box.x = Num.mm( camBox.xMin, box.x, camBox.xMax );
		box.y = Num.mm( camBox.yMin, box.y, camBox.yMax );

		

		
		
		//box.x = tx;
		//box.y = ty;
		
		
		//box.x +=  dx * c ;
		//box.y += dy * c;

	}

	function moveCanne(){
		// ROT
		//*
		var tr = -1.0;
		if(click) tr = -2.7;
		var dr = tr-cRot;
		cRot += dr*0.2;
		//*/
		canne.root.rotation = cRot/0.0174;


		// MOVE
		var mp = { x:box.mouseX, y:mouseY };
		canne.toward( mp, 0.5, null );

		// DRAW CANNE
		var cs = getCanneSize();
		canne.root.graphics.clear();
		canne.root.graphics.lineStyle(3,0x8B6830,100);
		canne.root.graphics.moveTo(mancheSize,0);
		var x  = Math.cos(bRot)*cs + mancheSize;
		var y  = Math.sin(bRot)*cs;
		canne.root.graphics.curveTo( mancheSize+cs*0.8, 0, x, y );


		//

		var bx = canne.x + Math.cos(cRot)*mancheSize;
		var by = canne.y + Math.sin(cRot)*mancheSize;

		var px = bx + Math.cos(cRot+bRot)*(canneSize-Math.abs(bRot)*10);
		var py = by + Math.sin(cRot+bRot)*(canneSize-Math.abs(bRot)*10);

		// BAIT + TENSION
		var dx = px - bait.x;
		var dy = py - bait.y;

		var dist = Math.sqrt(dx*dx+dy*dy);
		var a = Math.atan2(dy,dx);
		var g:Null<Float> = null;
		var pression = null;
		if( dist > tensionMax ){
			var c = (dist-tensionMax)/tensionMax;
			var p = 20;

			pression  = { a:a, p:c*p };

			bait.vx += Math.cos(a)*c*p;
			bait.vy += Math.sin(a)*c*p;



			var lim = 0.2;
			if(c>lim){
				bait.x = px - Math.cos(a)*tensionMax*(1+lim);
				bait.y = py - Math.sin(a)*tensionMax*(1+lim);

			}
		}else{
			g = (tensionMax-dist)*0.5;
		}

		bait.vx *= 0.95;
		bait.vy *= 0.95;



		// TENSION BOIS
		if( pression != null ){
			var sa = pression.a-cRot;
			var pr = Math.sin(sa+3.14)*pression.p;
			bRot += pr*0.02*(bait.weight+(flEat?2:0));
		}
		bRot *= 0.9;

		// DRAW
		fil.graphics.clear();
		fil.graphics.lineStyle(1,0xFFFFFF,100);
		fil.graphics.moveTo(px,py);
		if(g==null){
			fil.graphics.lineTo(bait.x,bait.y);
		}else{
			var mx = (bait.x+px)*0.5;
			var my = (bait.y+py)*0.5 + g;
			fil.graphics.curveTo(mx,my,bait.x,bait.y);
		}


	}

	function getCanneSize(){
		return canneSize-Math.abs(bRot)*15;
	}

	function checkFrog(){
		nerve = Math.min(nerve+2,1000);
		var d1 = frog.getDist(bait);
		var d2 = bait.getDist(ob);
		var c = Math.max(0,180-d1)/180;
		nerve -= c*d2*8;

		if( nerve < 0 ){
			initJump();
		}else{
			var frame = 20-Math.round((nerve/nerveMax)*10);
			frog.root.gotoAndStop(frame);
		}

		// EYES
		var a = frog.getAng(bait);
		var f = cast(frog.root);
		f.h.h.o.p.x = 1.8 * (1-c) * Math.cos(a);
		f.h.h.o.p.y = 1.8 * (1-c) * Math.sin(a);

	}

	function initJump(){
		step = 2;
		var a = frog.getAng(bait);
		var d = frog.getDist(bait);
		var p = 16+d*0.02;
		frog.vx += Math.cos(a)*p;
		frog.vy += Math.sin(a)*p;
		frog.weight = 1;
		frog.root.gotoAndPlay("jump");
		camBox.yMin = -200;
		camBox.yMax = 0;
		camBox.cx = 0.5;
		camBox.sp = 0.2;
		camBox.xMax = -frog.x;
		timeProof = true;
	}

	function checkEat(){
		var d = frog.getDist(bait);
		if( d < 20 ){
			flEat = true;
			bait.vx += frog.vx;
			bait.vy += frog.vy;
			bait.root.visible = false;
			frog.weight = null;
			frog.vx = 0;
			frog.vy = 0;
			frog.vr = 0;
			frog.root.gotoAndStop("eat");
			camBox.sp = 0;

			looseTimer = 12;
		}
	}

	function checkLand(){
		var g = gl;
		if( frog.x > limit ) g += 120;
		if( frog.y > g ){
			frog.y = g;
			frog.weight = null;
			frog.vx = 0;
			frog.vy = 0;
			if( g == gl ){
				frog.root.gotoAndStop("1");
				frog.root.rotation = 0;
				setWin(false,20);
			}else{
				setWin(true,20);
				frog.root.gotoAndPlay("impact");
				for( i in 0...20 ){
					var mc = newPhys("mcPartDirt");
					mc.x = frog.x;
					mc.y = frog.y;
					mc.vx = 5*(Math.random()*2-1);
					mc.vy = -(3+Math.random()*6);
					mc.setScale(0.3+Math.random()*0.6);
					mc.weight = 0.5;
					mc.updatePos();

				}
			}
		}


	}


//{
}












