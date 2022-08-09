import haxe.Log;
import mt.bumdum9.Lib;


class Planets extends Game{//}

	var stars:flash.display.BitmapData;
	public var planets:Array<PPlanet>;
	public var ships:Array<PShip>;
	public static var me:Planets;
	
	override function init(dif:Float) {
	
		me = this;
		
		gameTime = 2500;
		super.init(dif);
		
		// BG
		bg = new BgPlanets();
		stars = new flash.display.BitmapData(Cs.mcw, Cs.mch, false, 0x000044 );
		var brush = new McBrushGradient();
		var ma = -100;
		for( i in 0...8 ) {
			var m  = new flash.geom.Matrix();
			m.scale(10, 10);
			m.translate(ma+Std.random(Cs.mcw-2*ma), ma+Std.random(Cs.mch-2*ma));
			var r = Std.random(255)-255;
			var g = Std.random(255)-255;
			var b = Std.random(255)-255;
			var ct = new flash.geom.ColorTransform(1,1,1,0.12,r,g,b,0);
			stars.draw(brush, m, ct, flash.display.BlendMode.ADD);
		}
		var max = 200;
		var brush = new McPlanetStar();
		var ma = -5;
		for( i in 0...max ) {
			var m  = new flash.geom.Matrix();
			var sc = 0.5 + Math.random();
			m.scale(sc, sc);
			m.translate(ma + Std.random(Cs.mcw - 2 * ma), ma + Std.random(Cs.mch - 2 * ma));
			stars.draw(brush, m, null, flash.display.BlendMode.ADD);
		}
		
		
		var bmp = new flash.display.Bitmap(stars);
		bg.addChild(bmp);
		dm.add(bg, 0);
		
		//
		planets = [];
		var max = 8;
		var minDist = 30;
		
		//
		genPlanet(50, 50, 30, 1, 20);
		genPlanet(Cs.mcw-50, Cs.mch-50, Std.int(20+dif*20), 2, 15+Std.int(dif*15));

		
		
		for( i in 0...max ) {
			var ray = 16 + Std.random(20);
			var x = 0;
			var y = 0;
			while( true ) {
				x = ray + Std.random(Cs.mcw - ray * 2);
				y = ray + Std.random(Cs.mch - ray * 2);
				var ok = true;
				for( p in planets ) {
					var dx = x - p.x;
					var dy = y - p.y;
					if( Math.sqrt(dx * dx + dy * dy) < p.ray + ray+minDist ) {
						ok = false;
						break;
					}
				}
				if( ok ) break;
			}

			genPlanet(x, y, ray, 0);
			
		}
		
		//
		ships = [];
		
	}
	function genPlanet(x, y, ray, color, ?pop ) {
		var p = new PPlanet(ray);
		p.x = x;
		p.y = y;
		p.setColor(color);
		dm.add(p, 1);
		planets.push(p);
		var me = this;
		p.addEventListener( flash.events.MouseEvent.CLICK, function(e) { me.clickPlanet(p); } );
		if( pop != null ) p.setPop(pop);
	}
	
	override function update(){
		
		
		for( p in planets ) p.update();
		var a = ships.copy();
		for( sh in a) sh.update();
		
		
		if( gameTime % 8 == 0 ) updateIA(2);
		
		super.update();
	}

	// PLANETS
	var selection:PPlanet;
	function clickPlanet(p:PPlanet) {
		if( selection == null ) {
			if( p.color == 1 ) selectPlanet(p);
		}else {
			moveTo(selection,p);
			unselectPlanet();
		}
	}

	function selectPlanet(p) {
		selection = p;
		Filt.glow(p, 4, 1, 0xFFFFFF, true);
		Filt.glow(p, 2, 4, 0xFFFFFF);
		Filt.glow(p, 12, 1, 0xFFFFFF);
	}
	function unselectPlanet() {
		selection.filters = [];
		selection = null;
	}
	
	function moveTo(start:PPlanet, p:PPlanet) {
		var n = Math.ceil(start.pop * 0.5);
		if( n == 0 ) return ;
		start.incPop( -n);
		
		for( i in 0...n ) {
			var a = i / n * 6.28;
			var ship = new PShip(this,start.color);
			ship.an = a;
			ship.x = start.x +Math.cos(a) * p.ray;
			ship.y = start.y + Math.sin(a) * p.ray;
			ship.trg = p;
			p.att.push(ship);
			dm.add(ship, 2);
		}
		
	}

	// IA
	public function updateIA(color) {
		var a = [];
		var b = [];
		
		var powMono = 0;
		var powMulti = 0;
		var defense = 0;
		for( p in planets ) {
			if( p.color == color ) {
				a.push(p);
				defense += Std.int(p.pop * 0.5);
			}else {
				if( p.color == 1 ) {
					if( p.pop > powMono ) powMono = p.pop;
					powMulti += Std.int(p.pop * 0.5);
				}
				b.push(p);
			}
		}
	
		//
		
		
		
		// DEFENSE
		if( Math.random() > dif ){
			var sec = 0;
			var pdef = null;
			for( p in a ) {
				var n = p.getSecurityLevel();
				if( n < sec ) {
					sec = n;
					pdef = p;
				}
			}
			if( pdef!=null && defense + sec > 0 && Std.random(2) == 0) {
				Arr.shuffle(a);
				for( p in a ) {
					if( p == pdef ) continue;
					moveTo(p, pdef);
					if( pdef.getSecurityLevel() > 0 ) break;
				}
				return;
			}
		}
	
		
				
		
		// ATTACK
		for( p in a ) {
			var c = [];
			for( p in b ) c.push( { p:p, score:0 } );
			
			var malus = 0;
			var def = Std.int(p.pop * 0.5);
			if( def < powMono ) 	malus -= Std.random(powMono-def);
			if( def < powMulti ) 	malus -= Std.random(powMulti-def);
			
			for( trg in c ) {
				trg.score += malus;
				if( trg.p.pop < p.pop ) 					trg.score += 5;
				if( trg.p.pop * 2 < p.pop ) 				trg.score += 10;
				if( trg.score > 0 && trg.p.color == 1 )		trg.score *= 2;
				
				trg.score -= Std.int( Math.max(1 - dif, 0) * (Std.random(50)-10) );
				
			}
			c.sort(order);
			var trg = c[0];
			if( trg.score >= 5 && Std.random(2) == 0 ) moveTo(p, trg.p);
		}
		

		
	}
	
	function order(a:{p:PPlanet,score:Int},b:{p:PPlanet,score:Int}) {
		if( a.score > b.score ) return -1;
		return 1;
	}
	
	//
	public function checkWin() {
		var a = [0, 0, 0];
		for(p in planets ) a[p.color]++;
		if( a[2] == 0 ) 		setWin(true, 15);
		else if( a[1] == 0 ) 	setWin(false, 15);
		trace(a[1]+", "+a[2]);
	}
	

//{
}


class PPlanet extends flash.display.Sprite {
	
	public var pop:Int;
	public var ray:Float;
	public var timer:Float;
	public var color:Int;
	public var skin:McPlanet;
	public var att:Array<PShip>;
		
	public function new(ray) {
		super();
		timer = 0;
		pop = Std.int(ray * 0.4) + Std.random(5);
		
		
		skin = new McPlanet();
		addChild(skin);
		
		this.ray = ray;
		scaleX = scaleY = ray * 0.02;
		skin.field.scaleX = skin.field.scaleY = 0.28 /scaleX;
		skin.field.x = - skin.field.width* 0.5;
		skin.field.y = -skin.field.height * 0.5 + 1;

		
		
		incPop(0);
		color = 0;
		att = [];
	}
	
	public function update() {
			
		if( color == 0 ) return;
		timer += ray;
		if( timer > 600 ) {
			timer = 0;
			incPop(1);
		}
	}
	
	public function setColor(n) {
		color = n;
		Col.overlay(skin,[0x888888,0x88FF44,0xFF0000][color],-160);
		
	}
	
	public function incPop(inc) {
		pop += inc;
		skin.field.text = Std.string(pop);
	}
	
	public function setPop(n) {
		pop = n;
		incPop(0);
	}
	
	public function add(ship) {
		att.remove(ship);
		if( color != ship.color ) {
			if( pop > 0 ) {
				incPop( -1);
			} else {
				setColor(ship.color);
				Planets.me.checkWin();
			}
		}
		if( color == ship.color ) incPop(1);
	}
	
	public function getSecurityLevel() {
		var sec = pop;
		for( sh in att ) {
			if( sh.color != color ) 	sec--;
			else						sec++;
		}
		return sec;
	}
	
	
	
}

class PShip extends McPlanetShip {
	public static var RAY = 6;
	public static var SPEED = 2;
	var man:Planets;
	public var trg:PPlanet;
	public var an:Float;
	public var color:Int;
	
	public function new(m:Planets,col:Int) {
		super();
		man = m;
		man.ships.push(this);
		an = 0;
		color = col;
		var n = [0, 0x0AAFF88, 0xFFAAAA][color];
		Filt.glow(this,2,8,n);
		Filt.glow(this, 10, 1, n);
		blendMode = flash.display.BlendMode.ADD;
	}
	
	public function update() {
		
		// MOVE
		var dx = trg.x - x;
		var dy = trg.y - y;
		var ta = Math.atan2(dy, dx);
		var da = Num.hMod( ta - an, 3.14 );
		
		var lim = 0.2;
		an += Num.mm( -lim, da * 0.2, lim);
		
		x += Math.cos(an) * SPEED;
		y += Math.sin(an) * SPEED;
		
		rotation = an / 0.0174;
		
		//if( Math.abs(dx)
		
		
		// RECAL SHIPS
		for( sh in man.ships ) {
			if( sh == this ) continue;
			var dx = sh.x - x;
			var dy = sh.y - y;
			if( Math.abs(dx) < RAY*2 && Math.abs(dy) < RAY*2 ) {
				var dist = Math.sqrt(dx * dx + dy * dy);
				var dif = RAY * 2 - dist;
				if( dif > 0 ) {
					var a = Math.atan2(dy,dx);
					var ca = Math.cos(a)* dif * 0.25;
					var sa = Math.sin(a)* dif * 0.25;
					sh.x += ca;
					sh.y += sa;
					x -= ca;
					y -= sa;
				}
			}
		}
		
		for( p in man.planets) {
			
			var dx = p.x - x;
			var dy = p.y - y;
			if( Math.abs(dx) < RAY+p.ray && Math.abs(dy) < RAY+p.ray ) {
				var dist = Math.sqrt(dx * dx + dy * dy);
				var dif = RAY+p.ray - dist;
				if( dif > 0 ) {
					if( p == trg ) {
						p.add(this);
						kill();
						return;
					}
					
					var a = Math.atan2(dy,dx);
					x -= Math.cos(a)* dif;
					y -= Math.sin(a)* dif;
				}
			}

		}

	}
	public function kill() {
		man.ships.remove(this);
		parent.removeChild(this);
	}
}












