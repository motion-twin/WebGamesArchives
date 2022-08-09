import mt.bumdum9.Lib;
class Rope extends Game{//}
	// CONSTANTES
	static var CEIL = 28;
	static var TENSION = 30;
	static var GSPEED = 16;
	static var PRAY = 40;
	static var GL = 224;
	static var HCENTER = 11;

	// VARIABLES
	var flWasUp:Bool;
	var rx:Float;
	var pdec:Float;
	var orot:Float;
	var timer:Float;
	var xmax:Float;
	var burn:Float;
	var hp:{x:Float,y:Float};


	// MOVIECLIPS
	var rope:flash.display.MovieClip;
	var bbg:flash.display.MovieClip;
	var bande:flash.display.MovieClip;
	var hero:Phys;
	var grap:Phys;
	var plat:Phys;


	override function init(dif){

		gameTime = 400;
		super.init(dif);
		rx = Cs.omcw*0.5;
		pdec = 0;
		burn = 0;
		xmax = 480 + dif*1500;
		flWasUp = true;
		//airFriction = 0.98;
		attachElements();
		zoomOld();
	}

	function attachElements(){
		bg = dm.attach("rope_bg",0);
		bbg = cast(bg).bg;

		// ROPE
		rope = dm.empty(Game.DP_SPRITE);

		// PLAT
		plat = newPhys("mcRopePlat");
		plat.x = xmax-(PRAY+20);
		plat.y = GL-8;
		plat.frict= 0.9;
		plat.updatePos();

		// HERO
		hero = newPhys("mcRopeHero");
		hero.x = Cs.omcw*0.5;
		hero.y = Cs.omch*0.5;
		hero.frict = 0.98;
		hero.weight = 0.3;
		hero.updatePos();

		// BANDE
		bande = dm.attach("mcRopeBande",Game.DP_SPRITE+1);

	}

	override function update(){
		super.update();
		if(step<5)updateScroll();
		
		updatePlat();
		updateHero();
		updateRope();
	

	}

	function updateRope(){
		rope.graphics.clear();
		switch(step){
			case 1:
				// ATTIRE
				var p = {
					x:rx,
					y:CEIL*1.0
				}
				var d = hero.getDist(p);
				var a = hero.getAng(p);
				if( d > TENSION ){
					var c = (d-TENSION) / TENSION;
					var po = 0.15;
					hero.vx += Math.cos(a)*c*po;
					hero.vy += Math.sin(a)*c*po;
				}

				// DRAW
				drawRope(p);

				// CHECK
				orot = hero.root.rotation;
				var dr = ( a/0.0174 + 90 ) - orot;
				dr = Num.hMod(dr,180);
				hero.root.rotation += dr*0.25;
				var c = -Num.mm(-1,(a/3.14),0);
				hero.root.gotoAndStop(Std.int(c*20)+1);

			case 2:

			case 3:
				//Log.print(grap.y)
				if( grap.y < CEIL ){
					rx = grap.x;
					step = 1;
					grap.kill();
				}
				drawRope(grap);
			case 4:
				timer--;
				if(timer<0)setWin(true,10);
				hero.y = plat.y-5;

		}
	}

	function updateHero(){

		// HP
		var ang = (hero.root.rotation+90)*0.0174;
		hp = {
			x: hero.x + Math.cos(ang)*HCENTER,
			y: hero.y + Math.sin(ang)*HCENTER,
		}

		// CHECK FLAME
		if(hp.y>GL-4 && step !=4 ){
			burn = Math.min(burn+5,100);

			// PART
			var p = newPhys("partFlameBall");
			p.x = hero.x + (Math.random()*2-1)*6;
			p.y = GL + (Math.random()*2-1)*2;
			p.weight = -(0.2 + Math.random()*0.2);
			p.timer = 12+Std.random(12);
			p.updatePos();

			// FRICTION
			if( hp.y > GL+4 )hero.vx *= 0.85;
		}else{
			if(step==4)burn*=0.5;
			burn = Math.max(0,burn-1);
		}

		Col.setPercentColor(hero.root,burn*0.01,0x000000);
		if(burn==100){
			step = 5;
			setWin(false);
		}

		// BURNING
		if( Math.random()*burn > 25 ){
			var p = newPhys("partFlameBall");
			var ray = Math.random()*10;
			var a = Math.random()*6.28;
			p.x = hp.x + Math.cos(a)*ray;
			p.y = hp.y + Math.sin(a)*ray;
			p.vx = hero.vx;
			p.vy = hero.vy;
			p.weight = -(0.1 + Math.random()*0.2);
			p.timer = 12+Std.random(12);
			p.updatePos();

		}

		// CHECK CEIL
		if(hero.y<CEIL+4){
			hero.vy *= -1;
			hero.y = CEIL+4;
		}

		// CHECK PLAT
		var flUp  = hero.y < plat.y-20;
		if( ( step==2 || step==3 ) && !flUp && flWasUp ){
			if( Math.abs(hero.x-plat.x) < PRAY ){
				plat.vy += Num.mm(0,hero.vy,3);
				step = 4;
				hero.vx = 0;
				hero.vy = 0;
				hero.root.gotoAndPlay("land");
				hero.y = plat.y-5;
				hero.vr = 0;
				hero.root.rotation = 0;
				timer = 10;
				dm.under(hero.root);
				timeProof=true;
			}
		}
		flWasUp = flUp;

		//
		hero.root.x = hero.x;
		hero.root.y = hero.y;
	}

	override function onClick(){
		switch(step){
			case 1:
				step++;
				hero.vr = (hero.root.rotation-orot)*1.5;
				hero.root.play();

			case 2:
				step++;
				grap = newPhys("mcRopeGrap");
				var mp = { x:box.mouseX, y:box.mouseY };
				//var mp = getMousePos();
				var a = hero.getAng(mp);
				grap.x = hero.x;
				grap.y = hero.y;
				grap.vx = Math.cos(a)*GSPEED;
				grap.vy = Math.sin(a)*GSPEED;
				grap.updatePos();

		}
	}

	function updateScroll(){

		var tx = Num.mm(-xmax,Cs.omcw*0.5-hero.x,0);
		box.x = tx/0.6;


		// BG
		bbg.x = -box.x*0.6*0.9;

		// BANDE
		bande.x = Math.floor(-box.x*0.6/(Cs.omcw))*Cs.omcw;

	}

	function updatePlat(){
		pdec = (pdec+10)%628;
		var p = {
			x:plat.x,
			y:(GL-8)+Math.cos(pdec/100)*1.5
		}
		plat.towardSpeed(p,0.1,0.5);
	}

	function drawRope(p){
		rope.graphics.lineStyle(1,0xBBEE00,100);
		rope.graphics.moveTo(hero.x,hero.y);
		rope.graphics.lineTo(p.x,p.y);
	}


//{
}

