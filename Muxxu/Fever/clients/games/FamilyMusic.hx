typedef FamilyNote = {>flash.display.MovieClip, a : Float, base : Float }
typedef FamilyMonster = {>flash.display.MovieClip, base : Float, a : Float, jump : Bool, ja : Float, speed : Float, finish : Bool, hit : flash.display.MovieClip }
typedef FamilyCloud = {>flash.display.MovieClip, base : Float, a : Float, speed : Float }
typedef Sin = {>flash.display.MovieClip, a : Float, base : Float }
typedef FamilyThink = {>flash.display.MovieClip, sub1 : Sin, sub2 : Sin, sub3 : Sin, info : Sin }

class FamilyMusic extends Game{//}

	var begin:Bool;
	
	var notes : Array<FamilyNote>;
	var bgCycle : Int;
	var noteCycle : Float;
	var speed : Float;
	var pit : flash.display.MovieClip;
	var monster : FamilyMonster;
	var cloud1 : FamilyCloud;
	var cloud2 : FamilyCloud;
	var cloud3 : FamilyCloud;
	var think : FamilyThink;
	var note : Int;
	var currentNote : Int;
	var hitOk : Bool;

	static var BGCYCLE = 3;
	static var BASE = 10;
	static var MIN = 100;
	static var SIN = 30;
	static var SPEED = 3;
	static var MSPEED = 12;
	static var MBASE = 362;

	override function init(dif) {
		begin  = true;
		bgCycle = BGCYCLE;
		gameTime = 300;
		super.init(dif);
		notes= new Array();
		note = 0;
		currentNote	= 1;
		initNoteCycle();
		attachElements();
	}

	function attachElements(){
		bg = dm.attach("mcFamilyBg",0);
		getSmc(bg).stop();
		monster = cast dm.attach("mcFamilyMonster", 3 );
		initMonster();
		pit = dm.attach( "mcFamilyPit", 4 );
		pit.x = 310;
		pit.y = 372;

		cloud1 = cast dm.attach("mcFamilyCloud1", 2 );
		cloud1.x = 200;
		cloud1.y = 200;
		cloud1.base = 200;
		cloud1.speed = 0.2 + Std.random( 8 ) / 10;
		cloud1.a = Std.random( 360 );

		cloud2 = cast dm.attach("mcFamilyCloud2", 2);
		cloud2.x = 200;
		cloud2.y = 200;
		cloud2.base = 200;
		cloud2.speed = 0.2 + Std.random( 8 ) / 10;
		cloud2.a = Std.random( 360 );

		cloud3 = cast dm.attach("mcFamilyCloud3", 4);
		cloud3.x = 200;
		cloud3.y = 200;
		cloud3.base = 200;
		cloud3.speed = 0.2 + Std.random( 8 ) / 10;
		cloud3.a = Std.random( 360 );

		think = cast dm.attach("mcFamilyThink", 1 );
		think.x = 110;
		think.y = 53;
		think.sub1.base = think.sub1.y;
		think.sub2.base = think.sub2.y;
		think.sub3.base = think.sub3.y;
		think.sub1.a = Std.random( 360 );
		think.sub2.a = Std.random( 360 );
		think.sub3.a = Std.random( 360 );
		think.info.base = think.info.y;
		think.info.a = Std.random(360);
		think.info.gotoAndStop(1);
	}

	function initMonster() {
		monster.x = 310;
		monster.y = monster.y = MBASE;
		monster.a = 0;
		monster.base = 352;
		monster.ja = 10;
		monster.speed = MSPEED;
		monster.finish = false;
		monster.jump = false;
		hitOk = false;
		fade = 0;

	}

	var fade:Int;
	override function update(){
		switch(step){
			case 1:
				hitTest();
				updateBg();
				updateClouds();
				var max = begin?2:1;
				for( i in 0...max ) updateNotes();
				updateMonster();
				updateInfo();
			case 2 :
				var a = [think.sub3, think.sub2, think.sub1,think.info];
				var mc = a[fade];
				mc.scaleX -= 0.2;

				mc.scaleY = mc.scaleX;
				if( mc.scaleX <= 0.1 ) {
					mc.visible = false;
					fade++;
					if( fade == 4 ) step = 3;
				}
				updateNotes();
				updateMonster();
				
				//if( !mc.visible ) new mt.fx.Flash(monster,0.2);
			
		}
		super.update();
	}

	function hitTest() {
		if( monster.finish ) return;
		if( hitOk ) return;

		for( n in notes ) {
			if( hit( n, monster.hit ) ) {
				hitOk = true;
				if( n.currentFrame > 3 ) {
					think.info.gotoAndStop( think.info.currentFrame + 1 );
					currentNote++;
					notes.remove( n );
					var p = new Phys(n);
					p.timer = 5;
					p.vy = 0.1;
					p.weight = 2;
					p.fadeType = 4;
					new mt.fx.Flash(monster);
					if( think.info.currentFrame == think.info.totalFrames ) {
						setWin( true, 30 );
						step = 2;
						monster.nextFrame();
					}
				}
			}
		}
	}

	function updateMonster() {
		if( !monster.jump ) {
			monster.a += 5;
			monster.y= monster.base + Math.sin( monster.a * Math.PI / 180 ) * 5;
			monster.y = monster.y;
			return;
		}

		var speed = Math.sin( monster.ja * Math.PI / 180 ) * 300;
		var s = if( monster.speed > 2 ) monster.speed-- else 3;
		monster.ja += s;
		if( monster.ja  > 180 ) {
			monster.ja = 90;
			monster.finish = true;
		}


		if( monster.y <= monster.base && monster.finish) {
			initMonster();
			return;
		}

		monster.y = monster.base - speed;
		monster.y = monster.y;
	}

	function updateInfo() {
		think.sub1.a++;
		think.sub1.y = think.sub1.base + Math.sin( think.sub1.a * Math.PI / 180 ) * 3;
		think.sub1.scaleX =  think.sub1.scaleY = 1 + Math.sin( think.sub1.a * 2 * Math.PI / 180 ) * 0.1;
		think.sub2.a++;
		think.sub2.y = think.sub2.base + Math.sin( think.sub2.a * Math.PI / 180 ) * 3;
		think.sub2.scaleX =  think.sub2.scaleY = 1 + Math.sin( think.sub2.a * 2 * Math.PI / 180 ) * 0.1;
		think.sub3.a++;
		think.sub3.y = think.sub3.base + Math.sin( think.sub3.a * Math.PI / 180 ) * 3;
		think.sub3.scaleX =  think.sub3.scaleY = 1 + Math.sin( think.sub3.a * 2 * Math.PI / 180 ) * 0.1;
		think.info.a +=2;
		think.info.y = think.info.base + Math.sin( think.info.a * Math.PI / 180 ) * 3;
	}

	function updateClouds() {
		cloud1.a += cloud1.speed;
		cloud1.x = cloud1.base + Math.sin( cloud1.a * Math.PI / 180 ) * 100;
		cloud2.a += cloud2.speed;
		cloud2.x = cloud2.base + Math.sin( cloud2.a * Math.PI / 180 ) * 100;
		cloud3.a += cloud3.speed;
		cloud3.x = cloud3.base + Math.sin( cloud3.a * Math.PI / 180 ) * 100;
	}

	function updateNotes() {
		for( n in notes ) {
			n.x += speed;
			if( n.x > 100 ) begin = false;
			n.x = n.x;
			n.a += 6;
			n.y = n.base + Math.sin( n.a * Math.PI / 180 ) * SIN;
			n.y = n.y;

			var frame = (n.currentFrame-1) % 3;
			if( frame == think.info.currentFrame-1 ) {
				n.gotoAndStop(frame+3+1);
			}else {
				n.gotoAndStop(frame+1);
			}
			
			if( ( n.x  ) > 410 ) {
				n.parent.removeChild(n);
				notes.remove( n );
			}
		}
		if( step > 1 ) return;
		if( noteCycle-- <= 0 ){
			initNoteCycle();
			if( note > 2 ) note = 1; else note++;
			var n : FamilyNote = cast dm.attach( "mcFamilyNote", 1 );
			n.gotoAndStop(  note );
			n.y = n.y = n.base = MIN;
			n.x = n.x = -20;
			n.a = 0;
			notes.push(n);
		}
	}

	function initNoteCycle() {
		noteCycle = BASE;
		speed = SPEED + dif * 14;
	}

	function updateBg() {
		if( bgCycle-- <= 0 ) {
			if( getSmc(bg).currentFrame < getSmc(bg).totalFrames ) {
				getSmc(bg).gotoAndStop( getSmc(bg).currentFrame +1 );
			} else {
				getSmc(bg).gotoAndStop( 1 );
			}
			bgCycle = BGCYCLE;
		}
	}

	override function onClick(){
		if( !monster.jump )	{
			monster.jump = true;
		}
	}

	function hit( m1 : flash.display.MovieClip, m2 : flash.display.MovieClip ) {
		var r1 = getRectangle( m1 );
		var r2 = getRectangle( m2 );
		return r2.intersects( r1 );
	}

	function getRectangle( mc : flash.display.MovieClip ) {
		return mc.getBounds( bg );
	}

//{
}
