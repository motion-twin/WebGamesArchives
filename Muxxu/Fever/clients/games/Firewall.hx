import flash.geom.Point;
import Protocole;

typedef Firewall_Ennemy = {>flash.display.MovieClip, target:Point, done : Bool, speed : Float };

class Firewall extends Game {//}
	
	static var FWCYCLE = 20;
	static var FWCOUNTER = 4;
	static var ENNEMY_CYCLE = 0.0;
	var fwCycle : Int;
	var fwCount : Int;
	var ennemyCycle : Float;
	var enemyCount : Int;
	
	var intrusion : Bool;
	var speed : Float;
	var procs : Array<flash.display.MovieClip>;
	var ennemys : Array<Firewall_Ennemy>;
	var firewall : flash.display.MovieClip;
	var aim : flash.display.MovieClip;
	var mcEnd : flash.display.MovieClip;
	var won : Bool;
	
	override function init(dif){
		gameTime = 300;
		super.init(dif);
		speed = 4;
		ENNEMY_CYCLE = 20;
		enemyCount = 1 + Math.floor( 4 * dif );//Math.ceil( 5 * dif );
		ennemyCycle = ENNEMY_CYCLE;
		fwCycle = FWCYCLE;
		fwCount = FWCOUNTER;
		ennemys = new Array();
		procs = new Array();
		attachElements();
	}
	
	function attachElements() {
		bg = dm.empty( 0 );
		WGeom.drawRectangle( bg, 400, 400, 0x000000, 100, 0x000000, 100 );
		firewall = dm.attach("mcFirewallWall", 2 );
		firewall.x = 25;
		firewall.y = 340;
		firewall.gotoAndStop(1);
				
		aim = dm.attach( "mcFirewallAim", 4 );
		aim.x = Cs.mcw / 2;
		aim.y = Cs.mch / 2;
		aim.gotoAndStop( 1 );
		
		var color = 0x1D65C7;
		var rw =  4;
		for( i in 0...5 ) {
			var p = dm.attach("mcFirewallCPU", 2 );
			p.y = 10;
			p.x = firewall.x + 12.5 + i * p.width;
			p.gotoAndStop( 1 );
			procs.push( p );
			
			var l = dm.empty(2);
			l.x = p.x + p.width / 2;
			l.y = firewall.y - rw;
			l.graphics.lineStyle( 1, color );
			var toY = 94;
			l.graphics.lineTo( 0, - ( firewall.y - toY - rw) );
			
			var m = dm.empty( 2 );
			m.x = l.x - 2;
			m.y = l.y;
			WGeom.drawRectangle( m,  rw, rw, null, 1, color, 100, 1 );
			
			var n = dm.empty( 2 );
			n.x = l.x - 2;
			n.y = toY;
			WGeom.drawRectangle( n,  rw, rw, null, 1, color, 100, 1 );
		}
		
		var max = 60 + Std.random( 50 );
		for( i in 0...max - 1 ) {
			var l = dm.empty(2);
			l.x = firewall.x + 12.5 + Std.random( Std.int( firewall.width - 25 ) );
			l.y = 80;
			l.graphics.lineStyle( 1, color );
			l.graphics.lineTo( 0, 15 );
		}
		
		for( i in 0...2 ) {
			var t = dm.empty( 2 );
			t.x = firewall.x -10 ;
			t.y = 90 + rw * (i + 1);
			t.graphics.lineStyle( 1, color );
			t.graphics.lineTo( firewall.width + 20, 0 );
		}
	}
	
	override function update() {

		var mp = getMousePos();
		aim.x = mp.x;
		aim.y = mp.y;
		
		switch(step){
			case 1:
				attackFirewall();
				blink();
				ennemy();
			case 2 :
				mcEnd = dm.attach("mcFirewallEnd", 5 );
				mcEnd.x = 0;
				mcEnd.y = Cs.mch / 2;
				mcEnd.gotoAndStop( if( won ) 2 else 3 );
				step = 3;
				fwCycle = FWCYCLE;
			case 3 :
				if( fwCycle-- <= 0 ) {
					if( mcEnd.currentFrame == 1  )
						mcEnd.gotoAndStop(if( won ) 2 else 3);
					else
						mcEnd.gotoAndStop(1);
					fwCycle = FWCYCLE;
				}
		}
		super.update();
		
		aim.gotoAndStop(click?2:1);
	}

	function ennemy() {
		for( e in ennemys ) {
			if( e.y <= e.target.y ) {
				if( !e.done ) {
					e.done = true;
					var end = true;
					// XXX
					for( i in 0...procs.length ) {
						var p = procs[i];
						if( p.currentFrame >= 2 ) continue;
						if( i < procs.length - 1 ) end = false;
		
						p.gotoAndStop(2);
						fxShake( 2 );
						var p = new Phys( e );
						p.timer = 10;
						ennemys.remove( e );
						break;
					}
					if( end ) {
						step = 2;
						setWin( false, 20 );
						fxShake( 18 );
						//step = 4;
					}
				}
				continue;
			}
			var x = e.width / 2;
			e.graphics.lineStyle( 2, 0xFF0000, 70 );
			e.graphics.moveTo( x, e.height );
			e.graphics.lineTo( x, Math.abs( e.y - firewall.y ) );
			e.y -= e.speed;
			var filter = new flash.filters.GlowFilter( 0xFFFFFF, 50, 4, 4, 1, 3 );
			e.filters= [filter];
		}
		
		if( ennemyCycle-- <= 0 ) {
			var already : IntHash<Int> = new IntHash();
			for( i in 0...enemyCount ) {
				intrusion = true;
				var idx = Std.random( procs.length );
				if( already.exists( idx ) ) continue;
				already.set( idx, idx );
				var p = procs[ idx ];
				var e : Firewall_Ennemy =  cast dm.empty(3);
				var w = 10;
				WGeom.drawTriangle( e, w, 0xFF0000, 50, 0xFF0000, 100, 1 );
				e.y = firewall.y + e.height;
				e.x = p.x + p.width / 2 - w / 2;
				e.target = new Point( p.x + p.width / 2, 108 - e.height );
				e.speed = speed /2 + Std.random( Std.int( speed ) );
				ennemys.push(e);
				
			}
			ennemyCycle = Math.floor( ENNEMY_CYCLE ) / 3 + Std.random( Std.int( ENNEMY_CYCLE ) );
			//trace(ennemyCycle);
		}
	}
	
	function attackFirewall() {
		var m = dm.empty( 2 );
		m.x = 25 + Std.random( Std.int( firewall.width ) );
		m.y = Cs.mch;
		m.graphics.lineStyle( Std.random( 3 ) + 1, 0xFF0000 );
		m.graphics.lineTo( 0, firewall.y + firewall.height - Cs.mch - 1 );
		var p = new Phys( m );
		p.timer = 3 + Std.random( 5 );
		p.fadeType = 4;
		
		var r = dm.attach( "mcFirewallImpact", 3 );
		r.x = m.x;
		r.y = firewall.y + firewall.height;
		r.scaleX = r.scaleY = 0.5 + Math.random() * 0.5;
		var p = new Phys( r );
		p.timer = 10;
		p.fadeType = 4;
		p.sleep = p.timer - 2;
	}
	
	function blink() {
		var frame = if( intrusion ) 2 else 3;
		if( fwCycle-- <= 0 ) {
			if( firewall.currentFrame != frame  )
				firewall.gotoAndStop(frame);
			else
				firewall.gotoAndStop(1);
			fwCycle = FWCYCLE;
			intrusion = false;
		}
	}
	
	override function onClick() {
		for( e in ennemys ) {
			if( e.hitTestObject( aim ) ){
				var p = new Phys(e);
				p.timer = 3;
				p.fadeType = 3;
				ennemys.remove(e);
			}
		}
	}



	override function outOfTime(){
		step = 2;
		won = true;
		setWin(true);
	}

	//{
}
