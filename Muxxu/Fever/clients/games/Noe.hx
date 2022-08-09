/* TODO :
	tests collisions
	test envoi
*/
import mt.flash.Volatile;

typedef TClouds = {>flash.display.MovieClip, speed : Float }
typedef TWave = {>flash.display.MovieClip, i : Float}
typedef THold = {>Phys, wvx : Float, wvy : Float, type:Int,sens:Int,cd:Float, flFree:Bool, dec:Float, wp:{x:Float,y:Float},sent:Bool, baseR : Float, falling:Bool, baseW : Float, count:Int, doneWith:Bool};

class Noe extends Game {//}

	static var LIMIT = 246;
	static var WATER = 390;
	var acycle : Volatile<Int>;
	var animalCycles : Volatile<Int>;
	var aspeed : Volatile<Float>;
	var f : Volatile<Float>;
	var clouds : List<TClouds>;
	var waves : List<TWave>;
	var animals : Array<THold>;
	var parts : Array<Phys>;
	var archeX1 : Volatile<Float>;
	var archeX2 : Volatile<Float>;
	var arche : {>TWave, tail : flash.display.MovieClip, head : flash.display.MovieClip, mid : flash.display.MovieClip, items : Array<THold> };
	var hold:THold;
	var reserved : Bool;
	var line:flash.display.MovieClip;

	// PHX
	var bdm:mt.DepthManager;
	var archR : flash.geom.Rectangle;

	override function init(dif:Float){
		gameTime = 400;
		acycle = Std.int(60);
		aspeed = 1.0 + dif;
		animalCycles = 0;// acycle;
		super.init(dif);
		reserved = false;
		f = ( if( Std.random(2) == 0 ) -1 else 1 ) * 1.2;
		clouds = new List();
		waves = new List();
		animals = new Array();
		parts = new Array();
		attachElements();
		step = 1;

	}

	function attachElements(){

		/*
		initWorld();
		var aabb = new phx.col.AABB(0,0,Cs.mcw,Cs.mch);
		world = new phx.World( aabb, new phx.col.BruteForce() );
		world.gravity.set(0,0.3);
		*/
	
		bg = dm.attach("mcNoeBg",0);
		
		var c = Std.random(6) + 1;
		for( i in 0...c ){
			var scale = 10 + Std.random(40);
			var cloud : TClouds= cast dm.attach("mcNoeCloud",0 );
			cloud.y = 30 + Std.random( Std.int( ( Cs.mch - 80 ) ) );
			cloud.x = Std.random( Std.int( Cs.mcw ) );
			cloud.scaleY = scale*0.01;
			cloud.scaleX = 1 - scale*0.01;
			var speed = ( f * scale / 100 ) ;
			cloud.speed = speed;
			cloud.alpha = 1 - ( 0.5 - speed );
			clouds.push( cloud );
		}

		for( i in 0...4 ) {
			var fw : TWave = cast dm.attach("mcNoefw",1);
			fw.x = 200;
			fw.y = 409;
			fw.i = Std.random(100);
			fw.alpha = fw.i*0.01;
			waves.push( fw );
		}

		var clif = dm.attach("mcNoeCliff",1);
		clif.x = 320;
		clif.y = 294;

		arche = cast dm.attach("mcNoeArche",3);
		arche.x = 124;
		arche.y = 365;
		arche.i = Std.random(100);
		var w = arche.mid.width;
		arche.mid.scaleX = Math.min( 1, 1 - dif * 0.8 );
		arche.head.x -= w - arche.mid.width;
		archeX1 = arche.x + arche.mid.x;
		archeX2 = arche.x + arche.head.x;

		var archeY = arche.y;
		archR = new flash.geom.Rectangle(arche.x - 119 + Math.abs( arche.mid.x - arche.tail.x )  , archeY, arche.mid.width + 10, 20 );
		arche.items = new Array();

		line = dm.empty(2);

		/*
		var board = dm.empty(3);
		bdm = new mt.DepthManager(board);
		*/
		/*
		var shape = phx.Shape.makeBox(arche.mid.width,arche.mid.height,archeX1,arche.y);
		world.addStaticShape(shape);
		*/

		for( i in 0...5 ) {
			var fw : TWave = cast dm.attach("mcNoefw",4);
			fw.x = 200;
			fw.y = 409;
			fw.i = Std.random(100);
			fw.alpha = fw.i*0.01;
			waves.push( fw );
		}
	}

	override function update(){
		super.update();

		for( part in parts ) {
			part.update();
		}

		for( s in animals ) {

			// bye bye l'animal
			if( s.y > Cs.mch + 50 ) {
				s.kill();
				if( s.root.parent !=null ) s.root.parent.removeChild(s.root);
				animals.remove(s);
				//pause = true;
				setWin(false,20);
				continue;
			}

			// Hop on essaie de balancer comme on peu l'animal
			if( !s.flFree ) {
				if( click ) {
					var mp = getMousePos();
//					if( mp.x <= s.x && mp.y <= s.y ) {
						line.graphics.clear();
						getMc(s.root,"ring").visible = true;
						var dist = s.getDist(mp);
						var max = 10;
						var c = (dist-max) / max;
						var a = s.getAng(mp);
						var p = 1;
						s.wvx = Math.cos(a)*p*c;
						s.wvy = Math.sin(a)*p*c;
						line.graphics.lineStyle(1,0xFFFFFF,70);
						line.graphics.moveTo(mp.x,mp.y);
	//					line.graphics.lineTo(s.x ,s.y  );
						line.graphics.lineTo(s.x,s.y - s.root.height/2 );
//					}
				}
				s.update();
				continue;
			}
	
			// Flying...
			if( s.sent ) {
				if( !s.doneWith ) {
					line.graphics.clear();
					reserved = false;
					s.doneWith = true;
				}
				getMc(s.root,"ring").visible = false;
				
				var smc = getSmc(s.root);
				
				if( smc.currentFrame != 2 ) smc.gotoAndStop(2);
				var ok = false;
				var archeY = arche.y - arche.mid.height;
				var rect = new flash.geom.Rectangle( s.root.x - 23, s.root.y, s.baseW, 1);
				if( rect.y >= archR.y ) {
					if( rect.x > archR.x ) {
						if( rect.right < archR.right ) {
							s.vx = 0;
							s.vy = 0;
							s.weight =0;
							s.vr = 0;
							s.baseR = s.root.rotation;
							smc.gotoAndStop(1);
							arche.items.push( s );
							arche.y += 1;
							animals.remove(s);
							continue;
							ok = true;
						}
					}
				}
			}

			if( s.sent ) {
				s.update();
				continue;
			}
			
			s.x -= aspeed;
			s.count += Std.int(aspeed);
			if( s.count % 2 == 0 )
				getSmc(s.root).gotoAndStop(if( getSmc(s.root).currentFrame == 1 ) 2 else 1);

			// l'animal tombe !
			if( s.x < LIMIT && !s.falling ) {
				s.weight = s.root.currentFrame / 10;
				s.vr = -2;
				s.falling = true;
				Reflect.deleteField( s.root, "onRelease" );
				Reflect.deleteField( s.root, "onReleaseOutside" );
			}

			// Un animal à l'eau !
			if( s.falling && s.y > WATER ) {
				s.vr = 0;
				if( s != null ) {
					var part = dm.attach("mcNoeSplash",4);
					part.gotoAndStop(Std.random(part.totalFrames)+1);
					var p = new Phys(part);
					p.y = WATER + 7;
					p.x = s.x + if(Std.random(2)==0) Std.random( s.root.currentFrame ) else -( Std.random( s.root.currentFrame ) );
					p.timer = 20;
					p.scale = (100 * s.root.currentFrame)*0.01;
					p.fadeType = 0;
					parts.push( p );
				}
			}
			s.update();
		}

		// Les jolis nuages dans le ciel
		for( c in clouds ) {
			c.x += c.speed;
		}
	
		// les jolies vagues
		for( fw in waves ) {
			fw.i += 0.05;
			fw.rotation = 1.5 * Math.sin( fw.i );
		}

		// Arche et animaux sur l'arche
		arche.i += 0.03;
		arche.rotation = 1 * Math.sin( arche.i );
		for( i in arche.items ) {
			getSmc(i.root).gotoAndStop(1);
			if( i.y < arche.y + i.root.height - 20 ) {
				i.y += 3;
			} else {
				getSmc(i.root).gotoAndStop(3);
			}
			i.root.rotation = arche.rotation + i.baseR;
		}

		switch(step){
			case 1:
				// Spawn animaux
				if( animalCycles-- <= 0 ){
					var a = dm.attach("mcNoeAnimals",2);
					a.gotoAndStop(Std.random(a.totalFrames) + 1);
					getSmc(a).gotoAndStop(1);
					a.x = Cs.mcw + a.width * 1.5;
					a.y = 270;
					var s : THold = cast new Phys(a);
					s.updatePos();
					s.baseW = a.width - 10;
					s.flFree = true;
					s.sent = false;
					s.count = 0;
					s.doneWith = false;
					var me = this;
					//s.root.onPress = function() { me.onPress(s); };
					s.root.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(e) { me.onPress(s); } );
					cast(s.root).ring.visible = false;
					animals.push( s );
					animalCycles = acycle;
				}
		}
		
		//
		if( target != null && !click ) {
			onRelease(target);
			target = null;
		}
		
	}

	var target:THold;
	function onPress( p : THold ) {
		if( reserved ) return;
		if( !p.flFree ) return;
		if( p.sent ) return;
		if( p.falling ) return;
		p.flFree = false;
		p.vx = 0;
		p.vy = 0;
		getSmc(p.root).gotoAndStop(1);
		var me = this;
		target = p;
		//p.root.onReleaseOutside = function() { me.onRelease(p); };
		//p.root.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(e) { me.onRelease(p); } );
		
		reserved = true;
	}

	function onRelease( p : THold  ) {
	
		var me = this;
		
		if( p.wvx >= 0 || p.wvy >= 0 ) {
			line.graphics.clear();
			reserved = false;
			p.doneWith = false;
			p.flFree = true;
			getMc(p.root,"ring").visible = false;
			return;
		}
		
		/*
		if( p.wvx >= 0 ) {
			line.graphics.clear();
			reserved = false;
			p.doneWith = false;
			p.flFree = true;
			var mc:flash.display.MovieClip  = cast(p.root).ring.
			mc.visible = false;
			return;
		}

		if( p.wvy >= 0 ) {
			line.graphics.clear();
			reserved = false;
			p.doneWith = false;
			p.flFree = true;
			var mc:flash.display.MovieClip  = cast(p.root).ring.
			mc.visible = false;
			return;
		}
		*/
		
		
		p.sent = true;
		p.flFree = true;
		p.vx = p.wvx;
		p.vy = p.wvy;
		p.weight = -p.wvy / 20;
	}

	override function outOfTime(){
		setWin(true);
	}



//{
}
