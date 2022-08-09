package en;

import mt.flash.Volatile;
import Entity;

enum PatternAction {
	TurnLeft;
	TurnRight;
	Continue(f:Float);
}

class Pacman extends Enemy {
	public static var MIN_DIFFS = [ 1, 12, 16 ];
	static var LAST_WAVE = {waveId:-1, pattern:-1};
	
	var path		: Array<{x:Float, y:Float}>;
	var ang			: Float;
	var cadency		: Volatile<Int>;
	var type		: Volatile<Int>;
	
	static var _PATTERNS = [
		"0.2 :  0.7 R 0.6 R", // U large
		"0.4 :  0.7 R 0.2 R", // U serré
		"0.4 :  0.9 R 0.2 R", // U long
		"0.6 :  0.7 L 0.4 L 0.4 L 0.4 L", // U long
		"0.1 :  0.8 R 0.2 R 0.6 L 0.2 L 0.6 R 0.2 R", // Zig-zags bord 1
		"0.9 :  0.8 L 0.2 L 0.6 R 0.2 R 0.6 L 0.2 L", // Zig-zags bord 2
		"0.8 :  0.8 L 0.3 L 0.6 R 0.3 R", // S centre
		"0.6 :  0.1 R 0.3 L 0.8 L 0.8 L 0.8 L 0.3 R", // Longe les bords
		"0.5 : 0.2 L 0.25 R 0.5 R 0.5 R 0.5 R 0.25 L", // cercle au centre
	];
	static var PATTERN_INIT = false;
	
	public override function toString() {
		return super.toString()+"[Pacman]";
	}
	
	public function new(type:Int) {
		super();
		
		if( !PATTERN_INIT ) {
			PATTERN_INIT = true;
			var tmp = _PATTERNS.copy();
			_PATTERNS = [];
			var r = new mt.Rand(0);
			r.initSeed(game.seed);
			while( tmp.length>0 )
				_PATTERNS.push( tmp.splice(r.random(tmp.length), 1)[0] );
		}
		
		radius = 28;
		followScroll = true;
		autoKill = Entity.KillCond.LeaveScreen;
		ang = 0;
		cadency = 0;
		this.type = type;
		autoKillOutsider = true;

		var mc : { >flash.display.MovieClip, _smc:flash.display.MovieClip };
		switch(type) {
			case 0 :
				mc = cast new lib.Pacman();
			case 1 :
				mc = cast new lib.Badman();
			case 2 :
				mc = cast new lib.Shootman();
			default : throw "err"+type;
		}
		mc.scaleX = mc.scaleY = rnd(0.5, 0.7);
		mc._smc.gotoAndPlay( Std.random(mc._smc.totalFrames)+1 );

		switch( type ) {
			case 0 :
				initLife(1);
				speed = 0.10;
			case 1 :
				//mc.filters = [
					//mt.deepnight.Color.getColorizeMatrixFilter(0x6CC806, 0.8, 0.2),
				//];
				initLife(2);
				speed = 0.08;
			case 2 :
				//mc.filters = [
					//mt.deepnight.Color.getColorizeMatrixFilter(0xF18B01, 0.8, 0.2),
				//];
				initLife(4);
				speed = 0.14;
				cadency = 30*5;
				setCD("shoot", rseed.irange(50,400));
			default : throw "err"+type;
		}
		
		radius*=mc.scaleX;
		animMC = cast mc;
		setAnim("calm");
		spr.addChild(mc);
		cacheAnims("pacman"+type, 0.6);
		
		if( game.perf>=0.8 )
			spr.filters = [
				new flash.filters.DropShadowFilter(6,-90, 0x0,0.6, 8,8, 1, 1,true),
				new flash.filters.DropShadowFilter(12,90, 0x0,0.2, 8,8, 1),
			];
			
		if( waveCount()==1 )
			_PATTERNS.push( _PATTERNS.shift() );
		//var pid = wrand.random(_PATTERNS.length);
		//trace(LAST_WAVE+" wid="+waveId+" pid="+pid);
		//while( waveId!=LAST_WAVE.waveId && pid==LAST_WAVE.pattern ) {
			//pid = wrand.random(_PATTERNS.length);
			//trace("  ->retry pid="+pid);
		//}
		//if( LAST_WAVE.waveId==waveId )
			//pid = LAST_WAVE.pattern;
		//LAST_WAVE.waveId = waveId;
		//LAST_WAVE.pattern = pid;
		var raw = _PATTERNS[0];
		var finit = Std.parseFloat(raw.split(":")[0]);

		// Position de départ
		var side = getRandomPopSide( MIN_DIFFS[type] );
		var dir = getOppositeDir(side);
		
		var margin = 150;
		var offset = margin + (waveCount()-1) * (radius+25);
		switch(dir) {
			case 0 : setPosScreen(Game.WID*finit, Game.HEI+offset);
			case 2 : setPosScreen(Game.WID*(1-finit), -offset);
			case 1 : setPosScreen(-offset, Game.HEI*finit);
			case 3 : setPosScreen(Game.WID+offset, Game.HEI*(1-finit));
		}
		
		var program = [];
		var p = raw.split(":")[1].split(" ");
		for(a in p) {
			if( a.length==0 )
				continue;
			switch(a) {
				case "L" : program.push(TurnLeft);
				case "R" : program.push(TurnRight);
				default :
					program.push( Continue(Std.parseFloat(a)) );
			}
		}
		program.push( Continue(0.3) );
		
		// Précalcul programme
		path = [];
		var x = 0.;
		var y = 0.;
		switch(dir) {
			case 0 : x = Game.WID*finit; y = Game.HEI;
			case 2 : x = Game.WID*(1-finit); y = 0;
			case 1 : x = 0 ; y = finit*Game.HEI ;
			case 3 : x = Game.WID ; y = (1-finit)*Game.HEI ;
		}
		var d = dir;
		var distX = 0.;
		var distY = 0.;
		var step = 20;
		while( program.length>0 ) {
			var dx = 0;
			var dy = 0;
			switch(d) {
				case 0 : dy = -1;
				case 1 : dx = 1;
				case 2 : dy = 1;
				case 3 : dx = -1;
			}
			var done = false;
			switch( program[0] ) {
				case Continue(f) :
					x+=dx*step;
					y+=dy*step;
					distX+=Math.abs(dx*step);
					distY+=Math.abs(dy*step);
					path.push({x:x, y:y});
					switch(d) {
						case 1, 3 :
							if( distX>=Game.WID*f-step )
								done = true;
						case 0, 2 :
							if( distY>=Game.HEI*f-step )
								done = true;
					}
					
				case TurnLeft :
					if( --d<0 ) d = 3;
					done = true;
					
				case TurnRight :
					if( ++d>3 ) d = 0;
					done = true;
					
				default :
			}
			if( done ) {
				dx = dy = 0;
				distX = distY = 0;
				program.splice(0,1);
			}
		}
		
		#if dev
		//var g = game.debug.graphics;
		//g.clear();
		//g.lineStyle(1, 0xFFFF00,1);
		//for( pt in path )
			//g.drawCircle( pt.x, pt.y, 5 );
		#end
		
	}
	
	
	public override function onDie() {
		super.onDie();
		dropReward( waveKilled() ? (type>=1 ? 2 : 1) : type>=1 ? 1 : 0 );
	}
	
	//public override function hit(v, ?from) {
		//super.hit(v, from);
	//}
	
	public override function update() {
		if( game.perf<0.8 && spr.filters.length>0 )
			spr.filters = [];
		var a = mt.deepnight.Lib.rad(spr.rotation-180);
		var ta = a;
		if( path.length>0 ) {
			var pt = getScreenPoint();
			var t = path[0];
			var d = mt.deepnight.Lib.distanceSqr(t.x, t.y, pt.x, pt.y);
			if( d <= speed*Room.GRID * speed*Room.GRID ) {
				setPosScreen(t.x, t.y);
				path.splice(0,1);
			}
			else
				ta = Math.atan2(t.y-pt.y, t.x-pt.x);
		}
		
		if( anim=="calm" && Std.random(100)<5 )
			setAnim("clap", false);
		if( anim=="clap" && animDone() )
			setAnim("calm");
		//if( mc._smc.currentFrame>1 ) {
			//if( mc._smc.currentFrame==mc._smc.totalFrames )
				//mc._smc.gotoAndStop(1);
			//mc._smc.nextFrame();
		//}
		//if( mc._smc.currentFrame==1 && Std.random(100)<5 )
			//mc._smc.nextFrame();
			
		if( onScreen && cadency>0 && !hasCD("shoot") ) {
			setCD("shoot", cadency);
			var b = new bullet.Bad(this);
			b.toPlayer();
		}
		
		var d = ta-a;
		if( d>3.14 )
			d-=6.28;
		if( d<-3.14 )
			d+=6.28;
		a+=d*0.2;

		dx = Math.cos(ta)*speed;
		dy = Math.sin(ta)*speed;
		
		super.update();
		
		spr.rotation = mt.deepnight.Lib.deg(a)+180;
	}
}
