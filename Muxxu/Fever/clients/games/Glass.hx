class Glass extends Game{//}




	// CONSTANTES
	static var BRAY = 6;
	static var GRAY = 15;
	static var FALL = 25;


	// VARIABLES
	var run:Float;
	var flWillWin:Bool;
	var gy:Float;
	var speed:Float;
	var timer:Float;

	// MOVIECLIPS
	var glass:flash.display.MovieClip;
	var glassBack:flash.display.MovieClip;
	var gs:Phys;
	var ball:{>Phys,a:Float,va:Float};



	override function init(dif){
		gameTime = 200;
		super.init(dif);
		speed = 1+dif*4;
		gy = 60;
		run = 0;
		attachElements();
		zoomOld();
		
		
		//update();
		//gs.root.y = Cs.omch*0.5 + gs.y*0.5;
		//ball.root.y = Cs.omch*0.5 + ball.y*0.5;
		//updateGlassPos();
	}

	function attachElements(){

		bg = dm.attach("glass_bg",0);

		// SHADE
		gs = newPhys("mcGlassShade");
		gs.x = Cs.omcw*0.5;
		gs.y = Cs.omch * 0.5;
		
		gs.updatePos();
		gs.root.y = Cs.omch*0.5 + gs.y*0.5;

		// BACK
		glassBack = dm.attach("mcGlass",Game.DP_SPRITE);
		glassBack.gotoAndStop("2");

		// BALL
		ball = cast newPhys("mcGlassBall");
		ball.y = Cs.omch*0.5;//-20
		ball.x = Cs.omcw*(0.25+Math.random()*0.5);
		ball.a = 3.14;
		ball.va = 0;
		ball.updatePos();
		ball.root.y = Cs.omch * 0.5 + ball.y * 0.5;
		
		// GLASS
		glass = dm.attach("mcGlass", Game.DP_SPRITE);
		glass.x = Cs.omcw * 0.5;
		glass.y = Cs.omch * 0.25;
		glass.stop();
		//glass.gotoAndStop("1");
		updateGlassPos();


	}

	override function update(){
		//
		moveBall();
		switch(step){
			case 1:
				moveGlass();
				if(click)step = 2;
			case 2:
				gy -= FALL;
				if( gy < 0 ){
					gy = 0;
					var dist = gs.getDist(ball);
					if( dist < GRAY ) {
						timeProof = true;
						willWin(true);
					}else{
						willWin(false);
						if(ball.y < gs.y )dm.under(ball.root);
						if(ball.y > gs.y )dm.over(ball.root);
					}
					recalBall();
				}
			case 3:
				timer--;
				if(timer==0)setWin(flWillWin);
		}

		super.update();

		//
		
	}
	override function specialMaj() {
		gs.root.y = Cs.omch*0.5 + gs.y*0.5;
		ball.root.y = Cs.omch*0.5 + ball.y*0.5;
		updateGlassPos();
	}

	function moveGlass(){
		var mp = getMousePos();
		gs.toward(mp,0.2,null);
	}

	function moveBall() {
		ball.va += (Math.random()*2-1)*0.05;
		ball.va *= 0.92;
		ball.a += ball.va;

		while(ball.a>3.14)ball.a-=6.28;
		while(ball.a<-3.14)ball.a+=6.28;

		var vx = Math.cos(ball.a)*speed;
		var vy = Math.sin(ball.a)*speed;

		ball.x += vx;
		ball.y += vy;

		// RECAL
		if( ball.x < BRAY || ball.x > Cs.omcw-BRAY ){
			vx *= -1;
			ball.a = Math.atan2(vy,vx);
			ball.va *= 0.5;
		}

		if( ball.y < BRAY || ball.y > Cs.omch-BRAY ){
			vy *= -1;
			ball.a = Math.atan2(vy,vx);
			ball.va *= 0.5;
		}

		// GFX
		var fr = Std.int(((ball.a/6.28)+0.5)*40);
		ball.root.gotoAndStop(fr+1);

		run = ( run + speed ) % 20;
		//cast (ball.root).p0.gotoAndStop(Std.int(run));
		//cast (ball.root).p1.gotoAndStop(Std.int((run+10)%20));
		
		var pmc = getMc(ball.root, "p0");
		if( pmc != null ) pmc.gotoAndStop(Std.int(run));
		var pmc = getMc(ball.root, "p1");
		if( pmc != null ) pmc.gotoAndStop(Std.int((run+10)%20));


		// RECAL SPECIAL
		if(step==3)recalBall();

	}

	function recalBall(){
		var dist = gs.getDist(ball);
		var a = gs.getAng(ball);
		var ca = Math.cos(a);
		var sa = Math.sin(a);


		if( flWillWin && dist > GRAY-BRAY ){
			var d = dist-(GRAY-BRAY);
			ball.x -= ca*d;
			ball.y -= sa*d;
			ball.a = a+3.14+(Math.random()*2-1)*0.3;
		}
		if( !flWillWin && dist < GRAY+BRAY ){
			var d =(GRAY+BRAY)-dist;
			ball.x += ca*d;
			ball.y += sa*d;
			ball.a = a+(Math.random()*2-1)*0.3;
		}


	}

	function willWin(flag){
		//flFreezeResult = true;
		flWillWin = flag;
		step = 3;
		timer = 12;
	}

	function updateGlassPos(){
		glass.x = gs.root.x;
		glassBack.x = gs.root.x;
		glass.y = gs.root.y-gy;
		glassBack.y = gs.root.y-gy;
	}


//{
}

