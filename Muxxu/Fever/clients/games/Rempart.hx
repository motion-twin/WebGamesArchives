import mt.bumdum9.Lib;

typedef RempartClimber = {>flash.display.MovieClip,step:Int,t:Float,vr:Float,weight:Float};

class Rempart extends Game{//}

	// CONSTANTES
	static var SIDE = 16;
	static var CLIMBER_RAY = 20;
	static var VEGETABLE_SPEED = 8;

	// VARIABLES
	var cList:Array<RempartClimber>;
	var vList:Array<Phys>;
	var freq:Float;
	var delay:Float;
	var cd:Float;
	var frame:Float;
	var wall:SP;

	// MOVIECLIPS
	var hero:flash.display.MovieClip;


	override function init(dif:Float){
		gameTime = 500+dif*200;
		super.init(dif);
		cList = new Array();
		vList = new Array();
		freq = 46-dif*20;
		delay = 10;
		cd = 0;
		frame = 0;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("rempart_bg",0);

		// HERO
		hero = dm.attach("mcRempartHero",Game.DP_SPRITE);
		hero.x = Cs.omcw*0.5;
		hero.y = 68;
		hero.stop();

		// REMPART
		wall = dm.attach("mcRempart",Game.DP_SPRITE);

	}

	override function update(){
		cd -= 0.05;
		switch(step){
			case 1:
				moveHero();
				if( Std.random(Std.int(freq)) == 0 || cList.length == 0 )genClimber();
				updateShoot();
				moveClimber();
				
				
			case 2:
				
				

		}
		super.update();
	}

	// CLIMBER
	function genClimber(){
		var mc:RempartClimber  = cast dm.attach("mcRempartClimber",Game.DP_SPRITE+1);
		var m = 20;
		mc.x = m + Math.random()*(Cs.omcw-2*m);
		mc.y = Cs.omch+30;
		mc.step = 0;
		mc.t = 0;
		mc.step = 0;
		mc.vr = (Math.random() * 2 - 1) * 8;
		mc.weight = 0.5+Math.random();
		cList.push(mc);
	}

	function moveClimber() {
		var a = cList.copy();
		for( mc in a ){
			switch(mc.step){
				case 0:
					mc.t--;
					if(mc.t<0){
						mc.t = 6;
						mc.step = 1;
						mc.play();
					}

				case 1:
					mc.y -= 2;
					mc.t --;
					if(mc.t<0){
						mc.t = delay;
						mc.step = 0;
					}

				case 2:
					mc.y += 2;
					mc.t --;
					if(mc.t<0){
						mc.t = 5;
						mc.step = 0;
					}

			}
			checkCol(mc);
			if(mc.y < 70) initFall(mc.x, mc.y);
			
			var ma = 10;
			if( mc.x < -ma ||  mc.x > Cs.omcw ) {
				mc.t = 5;
				mc.step = 2;
			}
			
		}
	}

	function checkCol(mc:RempartClimber ){
		for( mco in cList ){
			var dx = mc.x - mco.x;
			var dy = mc.y - mco.y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			if( dist < CLIMBER_RAY*2 ){
				var d = (CLIMBER_RAY*2-dist)*0.5;
				var a = Math.atan2(dy,dx);
				mc.x += Math.cos(a)*d;
				mc.y += Math.sin(a)*d;
				mco.x -= Math.cos(a)*d;
				mco.y -= Math.sin(a)*d;
			}
		}

		if( mc.x < -CLIMBER_RAY || mc.x > Cs.omcw+CLIMBER_RAY ){
			mc.x = Num.mm( -CLIMBER_RAY, mc.x, Cs.omcw+CLIMBER_RAY );
		}



	}


	// SHOOT
	override function onClick(){
		if( step == 2 ) return;

		if(cd<0.5){
			cd = 1;
			hero.gotoAndPlay("shoot");
			var sp = newPhys("mcRempartVegetable");
			sp.x = hero.x+28;
			sp.y = 12;
			var a = sp.getAng( getMousePos() );
			sp.vx = Math.cos(a)*VEGETABLE_SPEED;
			sp.vy = Math.sin(a)*VEGETABLE_SPEED-2;
			sp.vr = 4*(Math.random()*2-1);
			sp.weight = 0;
			sp.updatePos();
			sp.root.gotoAndStop( Std.random(sp.root.totalFrames)+1  );
			sp.root.rotation = Math.random()*360;
			vList.push(sp);
		}

	}

	function updateShoot(){
		var a = vList.copy();
		for( sp in a ){
			for( mc in cList ){
				var dist = sp.getDist({x:mc.x,y:mc.y});
				if( dist < CLIMBER_RAY ){
					mc.step = 2;
					mc.t = sp.vy*10;
					sp.vy *= -1;
					sp.timer = 20;
					sp.weight = 0.5;
					sp.vr = (Math.random()*2-1)*36;
					vList.remove(sp);
					break;
				}


			}
		}
	}

	// HERO
	function moveHero(){
		if( step == 2 ) return;
		var dx = getMousePos().x - hero.x;
		if(cd<0){
			var lim = 4;
			var vx = Num.mm( -lim, dx*0.1, lim );
			hero.x += vx;

			frame = (frame+Math.abs(vx*0.5))%20;
			//Log.print(frame)
			hero.gotoAndStop(Std.int(frame)+1);

		}

	}

	// FALL
	var bmpWall:BMP;
	function initFall(cx:Float,cy:Float) {
		step = 2;
		setWin(false, 30);
		
		var bmp = new BMP(Cs.omcw, Cs.omch, true, 0);
		//dm.add(new flash.display.Bitmap(bmp), Game.DP_SPRITE);
		var m = new MX();
		bmp.draw(wall, m);
		bmpWall = bmp;
		//
		
		var xmax = Math.ceil(Cs.omcw / SIDE);
		var ymax = Math.ceil(Cs.omch / SIDE);
		var ray = SIDE * 0.5;
		var squares  = [];
		for( x in 0...xmax ) {
			for( y in 0...ymax ) {
		
				var p = new mt.fx.Part(new SP());
				p.x = (x + 0.5) * SIDE;
				p.y = (y + 0.5) * SIDE;
				p.updatePos();
				p.frict = 0.98;
				
				dm.add(p.root,Game.DP_SPRITE);
				
				var dx = p.x - cx;
				var dy = p.y - cy;
				var a = Math.atan2(dy, dx);
				var dist = Math.sqrt(dx * dx + dy * dy);
				var cc = Math.abs(dist / 250);
				var speed = 0.25+ (1-cc) * 1.5;
				p.vx = Math.cos(a) * speed;
				p.vy = Math.sin(a) * speed - 1;
				p.vr = (Math.random() * 2 - 1) * 3;
				p.rfr = 0.97;
				
				p.weight = 0.05 + Math.random() * 0.15;
				p.timer = 40 + Std.random(20);
				
			
				var m = new flash.geom.Matrix();
				m.translate(-p.x,-p.y);
				p.root.graphics.beginBitmapFill(bmp, m);
				var r = SIDE * 0.5;
				p.root.graphics.drawRect( -r, -r, 2 * r, 2 * r);
				
				Col.setPercentColor(p.root, cc * 0.25, 0);
				
				
				squares.push(p);
				
			}
		}
		
		// FALLERS

		hero.gotoAndStop("faller");
		
		var a:Array<MC> = [hero];
		for( mc in cList ) a.push(cast mc);
		//var a = cList.copy();
		for( mc in a ) {
			var p = new mt.fx.Part(mc);
			p.vr = (Math.random() * 2 - 1) * 8;
			p.weight = 0.25 + Math.random() * 0.5;
			if( mc == hero ) {
				p.vy -= 6;
				p.vr = 3;
				p.weight = 0.5;
			}
		}
		
		
		
		
		//
		wall.parent.removeChild(wall);
	}

	//
	override function outOfTime(){
		setWin(true);
	}

	override function kill() {
		super.kill();
		if( bmpWall != null ) bmpWall.dispose();
	}


//{
}

