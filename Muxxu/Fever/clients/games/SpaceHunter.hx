import mt.bumdum9.Lib;
typedef SHStar = {>Sprite,c:Float};
typedef SHBad = {>Sprite,dec:Float,amp:Float,ec:Float,speed:Float,by:Float,pv:Int};
typedef SHWeapon = {x:Int,y:Int,a:Float,cad:Int,cd:Int};

class SpaceHunter extends Game{//}

	static var SPEED = 6;

	var coef:Float;
	var counter:Int;
	var freq:Int;
	var bcd:Int;
	var cd:Int;
	var cadence:Int;
	var hero:Phys;
	var stars:List<SHStar>;
	var bads:List<SHBad>;
	var bshots:List<Phys>;
	var hshots:List<Phys>;
	var parts:List<Phys>;
	var weapons:List<SHWeapon>;

	var plasma:mt.bumdum9.Plasma;

	override function init(dif:Float){
		gameTime = 320;
		super.init(dif);

		cadence = 6;
		freq = 5;
		if(dif>0.8)freq--;
		if(dif>1)freq--;
		if(dif>1.3)freq--;

		counter = 40;

		bads = new List();
		bshots = new List();
		hshots = new List();
		parts = new List();
		bcd = 0;
		cd = 0;
		attachElements();
		initWeapons();

	}

	function attachElements(){

		box.scaleX = box.scaleY = 4;
		bg = dm.attach("spacehunter_bg",0);

		// HERO
		hero = new Phys(dm.attach("spacehunter_hero",1));
		hero.x = 20;
		hero.y = 50;
		hero.frict = 0.75;
		hero.updatePos();
		hero.root.stop();

		// STARS
		stars = new List();
		var max = 30;
		for( i in 0...max ){
			var sp:SHStar = cast new Sprite(dm.attach("spacehunter_star",0));
			sp.x = Math.random()*100;
			sp.y = Math.pow(Math.random(),0.3)*100;
			sp.c = 0.1+i/max * 0.5;
			stars.push(sp);

			var prc = 20;
			if( sp.c < 0.4 )prc = 50;
			if( sp.c < 0.2 )prc = 100;
			Col.setPercentColor(sp.root,prc*0.01,0x386091);

		}

		// PLASMA
		plasma = new mt.bumdum9.Plasma(dm.empty(0),150,100);
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,-20,-50,-60,-1);
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 2;
		fl.blurY = 2;
		//plasma.filters.push(fl);


	}

	override function update(){

		switch(step){
			case 1:
				if( counter-- <0 ){
					counter = freq+Std.random(freq);
					addBad();
				}
				updateHero();
			case 3:
				coef = coef+0.1;
				if(coef>1){
					step = 4;
					plasma.ct = new flash.geom.ColorTransform(1,1,1,1,5,30,5,-20);
				}

			case 4:
				hero.vx += 3.5;
				hero.root.blendMode = flash.display.BlendMode.ADD;
				if(!plasma.dead) plasma.drawMc(hero.root);
				hero.root.blendMode =  flash.display.BlendMode.NORMAL;

		}

		updateBads();
		updateStars();
		updateShots();

		super.update();

		if( !plasma.dead ){
			plasma.scroll(-SPEED,0);
			plasma.update();
		}

		var mc = dm.attach("spacehunter_explo",0);
		for( p in parts ){
			if(p.root.visible != true){
				parts.remove(p);
			}else{
				mc.x = p.root.x;
				mc.y = p.root.y;
				mc.scaleX = mc.scaleY = Math.min(p.timer/p.fadeLimit,1)*(45-p.root.currentFrame*5)*0.01;
				mc.blendMode = flash.display.BlendMode.ADD;
				mc.rotation = p.root.rotation;
				if(!plasma.dead)plasma.drawMc(mc);
			}

		}
		mc.parent.removeChild(mc);


	}

	//
	function initWeapons(){
		weapons = new List();
		var mod = SHM[Std.int(Math.min(dif,0.99)*SHM.length)];
		for( o in mod ){
			weapons.push({
				x:o.x,
				y:o.y,
				cad:o.cad,
				a:o.a,
				cd:0,
			});
		}

	}

	// BAD
	function addBad(){
		var ma = 4;
		var b:SHBad = cast new Sprite(dm.attach("spacehunter_bad",1));
		b.x = 110;
		b.by = ma + Math.random()*(100-2*ma);
		b.y = b.by;
		b.speed = 0.75+Math.random()*0.75;
		b.dec = Math.random();
		b.amp = 0.003+Math.random()*0.005;
		b.ec = 8+Math.random()*8;
		b.pv = 2;
		b.root.gotoAndStop(1);
		if( Std.random(3)==0 && dif>0.3 ){
			b.root.nextFrame();
			b.pv+=1;
			b.ec = 1;
			b.speed += 1;
		}



		bads.push(b);
	}
	function updateBads(){

		var rw = 6;
		var rh = 2;

		for( b in bads){

			if( b.root.currentFrame == 1 ){
				var inc = dif * 0.4;
				var dy = 0.0;
				if( hero != null ) dy = b.by - hero.y;
				if( dy > 0 )b.by-=inc;
				if( dy < 0 )b.by+=inc;
			}

			//
			b.dec = (b.dec+b.amp)%1;
			b.y = b.by + (0.5+Math.cos(b.dec*6.28)*0.5)*b.ec;
			b.x -= b.speed;

			if( hero!=null){
				var dx = b.x - hero.x;
				var dy = b.y - (hero.y-1);
				if( Math.abs(dx) < rw+8 &&  Math.abs(dy) < rh+4 ){
					explode(b);
					collision();
				}
			}
			
			if(b.x<-20)bads.remove(b);
		}
	}
	function damage(bad:SHBad,n=1){
		bad.pv -= n;
		//this.fxFlash(bad.root);
		new mt.fx.Flash(bad.root, 0.1);
		if(bad.pv <= 0) explode(bad);
		

	}
	function explode(bad:SHBad){

		// PARTS
		var cr = 3;
		for( i in 0...6 ){
			var sp = Math.random()*4;
			var a = ((i+Math.random())/3)*6.28;
			var p = newPhys("spacehunter_parts");
			p.vx = Math.cos(a)*sp - SPEED;
			p.vy = Math.sin(a)*sp;
			p.x = bad.x + p.vx*cr;
			p.y = bad.y + p.vy*cr;
			p.weight = 0.1;
			p.timer = 20;
			p.root.gotoAndStop(Std.random(4)+1);
			//p.setScale(30+Math.random()*30);
			parts.push(p);
			p.updatePos();
			p.root.rotation = 90*Std.random(4);
			//p.root.visible = false;
			//p.root.blendMode = flash.display.blendMode.ADD;
			p.fadeType = 0;

		}

		// BOOM
		fxBoom(bad.x,bad.y);

		//
		bad.kill();
		bads.remove(bad);
	}

	// SHOTS
	function updateShots(){

		var ray = 2;
		for( shot in hshots ){

			for( b in bads){
				var dx = shot.x - b.x;
				var dy = shot.y - b.y;
				if( Math.abs(dx) < (b.root.width*0.5)+ray && Math.abs(dy) < (b.root.height*0.5)+ray ){
					hshots.remove(shot);
					shot.kill();
					damage(b,1);
				}

			}

			if( shot.x>110 )hshots.remove(shot);

		}

	}

	// HERO
	function updateHero(){


		var mp = getMousePos();

		/*
		if( mp.x < 0 ) return;
		if( mp.x > 100 ) return;
		if( mp.y < 0 ) return;
		if( mp.y > 100 ) return;
		*/

		// SHOOT
		if(cd>0)cd--;
		if(bcd>0)bcd--;
		if(cd==0 && click )shoot();

		// MOVE
		var dx = mp.x - hero.x;
		var dy = mp.y - hero.y;
		var fr = Num.mm(1,2+dy*0.1,3);

		// DX
		hero.vx += dx*0.05;

		// DY
		var nfr = Math.round(fr);
		if( nfr != hero.root.currentFrame ) {
			hero.root.gotoAndStop(nfr);
			new mt.fx.GotoAndStop( hero.root,untyped __unprotect__("p0"),1,true);
			new mt.fx.GotoAndStop( hero.root,untyped __unprotect__("p1"),1,true);
		}
		
		hero.vy += dy*0.05;
		hero.root.x = Std.int(hero.x);
		hero.root.y = Std.int(hero.y);
	}

	function shoot(){

		for( wp in weapons )if(wp.cd>0)wp.cd--;
		if( click ){
			var ssp = 6;
			for( wp in weapons ){
				if(wp.cd==0){
					var shot = newPhys("spacehunter_laser");
					shot.x = hero.x+wp.x;
					shot.y = hero.y+wp.y;
					shot.vx = Math.cos(wp.a)*ssp;
					shot.vy = Math.sin(wp.a)*ssp;
					hshots.push(shot);
					if(wp.a<-0.3)		shot.root.gotoAndStop(2);
					else if(wp.a>0.3)	shot.root.gotoAndStop(3);
					else 			shot.root.stop();
					wp.cd = wp.cad;

				}
			}
		}




	}

	function collision(){
		fxBoom(hero.x,hero.y);
		setWin(false,15);
		hero.kill();
		hero = null;
		step = 2;



	}
	// STARS
	function updateStars(){
		var ma = 2;
		for( sp in stars ){
			sp.x -= SPEED*sp.c;
			if( sp.x < -ma )sp.x+= 100+2*ma;
			sp.root.x = Std.int(sp.x);
			sp.root.y = Std.int(sp.y);
		}
	}

	// FX
	function fxBoom(x, y) {
		flash.Lib.current.stage.quality = flash.display.StageQuality.LOW;
		//root._quality = "LOW";
		var mc = dm.attach("spacehunter_explo",0);
		for(i in 0...3){
			mc.x = x + (Math.random()*2-1)*6;
			mc.y = y + (Math.random()*2-1)*6;
			mc.scaleX = mc.scaleY = 0.5+i*0.25;
			mc.rotation = Math.random()*360;
			mc.blendMode = flash.display.BlendMode.ADD;
			if(!plasma.dead)plasma.drawMc(mc);
		}
		flash.Lib.current.stage.quality = flash.display.StageQuality.HIGH;
		mc.parent.removeChild(mc);
	}

	override function kill(){
		plasma.kill();
		super.kill();
	}

	override function outOfTime(){
		setWin(true,35);
		for( b in bads )explode(b);
		coef = 0;
		step = 3;
	}


	static var SHM = [
		[
			{ x:-3, y:-6,	a:-0.75,	cad:8 },
			{ x:-5, y:-4,	a:0,		cad:8 },
			{ x:-5, y:-2,	a:0,		cad:8 },
			{ x:-5, y:2,	a:0,		cad:8 },
			{ x:-5, y:4,	a:0,		cad:8 },
			{ x:-3, y:6,	a:0.75,		cad:8 },
		],
		[
			{ x:-3, y:-4,	a:-0.75,	cad:8 },
			{ x:-5, y:-2,	a:0,		cad:8 },
			{ x:-5, y:2,	a:0,		cad:8 },
			{ x:-3, y:4,	a:0.75,		cad:8 },
		],
		[
			{ x:-3, y:-4,	a:-0.75,	cad:16 },
			{ x:-5, y:-2,	a:0,		cad:8 },
			{ x:-5, y:2,	a:0,		cad:8 },
			{ x:-3, y:4,	a:0.75,		cad:16 },
		],
		[
			{ x:-5, y:-2,	a:0,	cad:8 },
			{ x:-5, y:2,	a:0,	cad:8 },
		],
		[
			{ x:-5, y:-2,	a:0,	cad:8 },
		],

	];

//{
}

