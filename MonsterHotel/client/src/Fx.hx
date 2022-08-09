import mt.deepnight.HParticle;
import mt.deepnight.slb.*;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.deepnight.Tweenie;
import mt.MLib;
import b.Hotel;
import b.r.Lobby;
import b.Room;

import h2d.SpriteBatch;
import h2d.Tile;
import h2d.Bitmap;

import com.Protocol;
import b.*;
import en.*;

class Fx extends mt.Process {
	var lib(get,null)	: BLib;
	var tile(get,null)	: h2d.Tile;

	public var addSb	: h2d.SpriteBatch;
	public var normalSb	: h2d.SpriteBatch;

	var apool			: Array<HParticle>;
	var npool			: Array<HParticle>;

	public function new(proc:mt.Process, ctx:h2d.Layers, ?maxNormal=200, ?maxAdd=300) {
		super(proc);
		root = ctx;
		name = "FxManager";

		normalSb = new h2d.SpriteBatch( tile, root );
		#if debug normalSb.name = "normalSb";#end
		npool = HParticle.initPool(normalSb, maxNormal);

		addSb = new h2d.SpriteBatch( tile, root );
		addSb.blendMode = Add;
		#if debug addSb.name = "addSb";#end
		apool = HParticle.initPool(addSb, maxAdd);
	}

	inline function get_lib() return Assets.tiles;
	inline function get_tile() return Assets.tiles.tile;

	inline function alloc(t:Tile, x:Float, y:Float, ?additive=true) {
		return HParticle.allocFromPool(additive?apool:npool, t, x,y);
	}

	public function clearAll() {
		for(p in apool) {
			p.kill();
			p.update(false);
		}
		for(p in npool) {
			p.kill();
			p.update(false);
		}
	}

	override function onDispose() {
		super.onDispose();

		addSb.dispose();
		addSb = null;

		normalSb.dispose();
		normalSb = null;
	}

	function getNova(a:Null<Affect>) {
		if( a==null )
			return "fxNovaYellow";

		return switch( a ) {
			case Heat : "fxNovaYellow";
			case Cold : "fxNovaBlue";
			case Noise : "fxNovaPurple";
			case Odor : "fxNovaGreen";
			case SunLight : "fxNovaYellow";
		}
	}

	public function clientSelected(c:en.Client) {
		var p = alloc( lib.getTile(getNova(c.sclient.emit)), c.centerX+rnd(0,3,true), c.centerY+rnd(0,3,true) );
		p.width = c.wid*1.5 + rnd(0,16);
		p.height = c.hei*1.5 + rnd(0,16);
		p.alpha = 1;
		p.ds = 0.4;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.86;
	}

	public function clientSelection(c:en.Client) {
		if( itime%3==0 ) {
			var p = alloc( lib.getTile(getNova(c.sclient.emit)), c.centerX+rnd(0,3,true), c.centerY+rnd(0,3,true) );
			p.width = c.wid*2.2 + rnd(0,16);
			p.height = c.hei*2.2 + rnd(0,16);
			p.alpha = 0;
			p.maxAlpha = rnd(0.5, 0.7);
			p.da = rnd(0.3, 0.4);
			//p.frict = rnd(0.80, 0.85);
			p.life = rnd(4,5);
		}
	}


	public function roomOvered(r:b.Room) {
		if( !cd.hasSet("roomOver"+r.rx+","+r.ry, 10) ) {
			var x = r.globalLeft;
			var y = r.globalTop;
			var w = r.wid*1.1;
			var h = r.hei*1.1;
			var p = alloc(lib.getTile("roomOver"), x+r.wid*0.5, y+r.hei*0.5);
			p.width = w;
			p.height = h;
			p.ds = 0.04;
			p.life = 0;
			p.fadeOutSpeed = 0.1;
			p.onUpdate = function() {
				p.ds*=0.85;
			}
		}
	}


	public function roomSelection(r:b.Room) {
		var x = r.globalLeft;
		var y = r.globalTop;
		var w = r.wid;
		var h = r.hei;
		var p = alloc(lib.getTile("squareOrange"), x+w*0.5, y+h*0.5);
		p.width = w;
		p.height = h;
		p.fadeIn( 1, 0.2 );
		p.life = 15;
	}


	public function marker(x,y, ?col="blue", ?scale=1.0, ?life=120) {
		#if debug
		var p = alloc(lib.getTile(col+"Circle"), x,y, false);
		p.alpha = 0.7;
		p.scale( 4*scale );
		p.ds = -0.01;
		p.life = life;
		p.fadeOutSpeed = 0.03;
		#end
	}

	public function roomMarker(cx,cy, ?col="blue") {
		#if debug
		var pt = b.Hotel.gridToPixels(cx,cy);
		var p = alloc(lib.getTile(col+"Circle"), pt.x+Const.ROOM_WID*0.5, pt.y-Const.ROOM_HEI*0.5, false);
		p.alpha = 0.7;
		p.scale( 4);
		p.ds = -0.02;
		p.life = 60;
		p.fadeOutSpeed = 0.03;
		#end
	}

	public function roomCustomized(r:Room) {
		var pt = b.Hotel.gridToPixels(r.rx, r.ry);
		var n = 25;
		var p = 20;
		for(i in 0...n) {
			var p = alloc(lib.getTile("blueShine"), r.globalLeft + rnd(p,r.wid-p), r.globalTop + rnd(p,r.hei-p));
			p.fadeIn(rnd(0.7,1), 0.1);
			p.dr = rnd(0.10, 0.25, true);
			p.scale( rnd(2, 4) );
			p.dsx = -rnd(0.02, 0.04);
			p.dsy = -rnd(0.01, 0.02);
			p.delay = rnd(0,3);
			p.life = rnd(10,25);
			p.onUpdate = function() {
				p.dr*=0.94;
			}
		}
	}


	public function roomCreated(r:Room) {
		var pt = b.Hotel.gridToPixels(r.rx, r.ry);
		var n = 25;
		for(i in 0...n) {
			// Horizontals
			for(j in 0...2) {
				var v = 0.05*r.wid + pt.x + r.wid*0.9*i/n;
				var p = alloc(lib.getTile("fxTaxiLight"), v, pt.y-Const.ROOM_HEI*j);
				p.scaleX = 1.5;
				p.fadeIn(1, 0.2);
				p.life = 25;
				p.delay = 10+j*10 + 16*i/n;
			}
			// Verticals
			for(j in 0...2) {
				var v = 0.05*r.hei + pt.y - r.hei*0.9*i/n;
				var p = alloc(lib.getTile("fxTaxiLight"), pt.x+r.wid*j, v);
				p.scaleX = 1.5;
				p.fadeIn(1, 0.2);
				p.rotation = 1.57;
				p.life = 25;
				p.delay = j*10 + 16*i/n;
			}
		}
	}


	public function interactiveObject(x:Float, y:Float) {
		var a = rnd(0,6.28);
		var d = rnd(30,50);
		var p = alloc(lib.getTile("yellowDot"), x+Math.cos(a)*d, y+Math.sin(a)*d);
		p.fadeIn(rnd(0.5, 1), 0.1);
		p.moveAwayFrom(x,y, rnd(0,3));
		p.scale( rnd(1,2));
		p.gx = rnd(0,0.2,true);
		p.gy = rnd(0,0.2,true);
		p.life = rnd(7,20);
		p.frict = rnd(0.85, 0.92);
	}


	public function affectEmit(c:en.Client, x:Float,y:Float, affect:Affect) {

		switch( affect ) {
			case Heat :
				// Flame
				var p = alloc( lib.getTile("fxParticleFire"), x+rnd(0,5,true), y+rnd(0,5,true) );
				p.fadeIn(rnd(0.5, 0.7), 0.07);
				p.dx = rnd(0,0.5,true);
				p.dy = -rnd(0.2,2);
				p.frict = rnd(0.86, 0.90);
				p.gx = rnd(0.05, 0.10);
				p.gy = -rnd(0.2, 0.4);
				p.rotation = rnd(0, 0.2, true);
				p.setScale( rnd(0.6, 0.8) );
				p.dsx = -rnd(0.01, 0.02);
				p.dsy = -rnd(0.015, 0.03);
				p.life = rnd(10, 20);

				// Smoke
				var p = alloc( lib.getTile("fxFireSmoke"), x+rnd(0,5,true), y+rnd(0,5,true), false );
				p.fadeIn(rnd(0.5, 0.7), 0.07);
				p.dx = rnd(0,0.5,true);
				p.dy = -rnd(0.2,2);
				p.frict = rnd(0.85, 0.90);
				p.gy = -rnd(0.2, 0.4);
				p.rotation = rnd(0, 6.28);
				p.setScale( rnd(2, 3) );
				p.life = rnd(20, 30);

			case Noise :
				if( !cd.hasSet("noise"+c.id, 15) ) {
					var p = alloc( lib.getRandomTile("fxSoundPulse"), x,y );
					p.alpha = rnd(0.3, 0.4);
					p.setScale( 0.6 );
					p.ds = 0.13;
					p.life = 5;
				}
				var p = alloc( lib.getRandomTile("fxSoundMusic"), x+rnd(0,5,true), y+rnd(0,5,true) );
				p.alpha = 0;
				p.da = 0.1;
				p.maxAlpha = rnd(0.8, 1);
				p.dx = rnd(5,7);
				p.dy = -rnd(0.2,2);
				p.frict = rnd(0.85, 0.90);
				p.gy = -rnd(0.05, 0.17);
				p.rotation = rnd(0, 0.3, true);
				p.setScale( rnd(0.8, 1.3) );
				p.life = rnd(20, 30);

			case Cold :
				if( Std.random(3)==0 ) {
					var p = alloc( lib.getRandomTile("blueSmoke"), x+rnd(0,5,true), y+rnd(0,5,true), false );
					p.fadeIn(rnd(0.4, 0.6), 0.05);
					p.dx = rnd(0.5,1,true);
					p.dy = rnd(0.5, 1.5);
					p.frict = rnd(0.92, 0.95);
					p.dr = rnd(0, 0.02, true);
					p.rotation = rnd(0, 6.28);
					p.setScale( rnd(1.5, 2.5) );
					p.ds = -0.02;
					p.life = rnd(20, 30);
					p.fadeOutSpeed = rnd(0.01, 0.02);
				}
				else {
					var p = new
					mt.deepnight.HParticle( lib.getRandomTile("fxParticleSnow"), x+rnd(0,5,true), y+rnd(0,5,true) );
					p.fadeIn(rnd(0.6, 0.8), 0.05);
					p.dx = rnd(0.5,1,true);
					p.dy = -rnd(0.2,2);
					p.frict = rnd(0.87, 0.90);
					p.dr = rnd(0, 0.01, true);
					p.gy = rnd(0.10, 0.15);
					p.rotation = rnd(0, 6.28);
					p.setScale( rnd(0.5, 1.3) );
					p.life = rnd(10, 20);
					p.fadeOutSpeed = rnd(0.02, 0.04);
				}

			case Odor :
				var k = Std.random(2)==0?"greenDot":"greenSmoke";
				var p = alloc( lib.getRandomTile(k), x+rnd(0,5,true), y+rnd(0,5,true), false );
				p.fadeIn(rnd(0.4,0.55), 0.04);
				p.dy = -rnd(0.2,2);
				p.frict = rnd(0.92, 0.95);
				p.gx = rnd(0.01, 0.03);
				p.gy = -rnd(0.02, 0.04);
				p.rotation = rnd(0, 6.28);
				p.dr = rnd(0, 0.02, true);
				p.scale( rnd(1.8, 2.5));
				p.life = rnd(20, 30);
				p.fadeOutSpeed = rnd(0.02, 0.04);

			case SunLight :
		}
	}

	public function gold(e:MinorEntity, scale:Float) {
		var a = -rnd(0, 3.14);
		var d = rnd(0, 150*scale);
		var p = alloc(lib.getTile("fxGoldGlow"), e.xx+Math.cos(a)*d, e.yy+Math.sin(a)*d*0.7);
		p.fadeIn(rnd(0.2, 0.4), rnd(0.01, 0.03));
		p.scale( rnd(1,2));
		p.life = rnd(20,30);
		p.moveAng(rnd(0,6.28), rnd(0.5,0.8));
		p.frict = rnd(0.94, 0.96);
		p.fadeOutSpeed = 0.02;
	}


	public function shopGem(x,y, fs:Float) {
		var p = alloc(lib.getTile("blueShine"), x, y);
		p.fadeIn( rnd(0.7,1), rnd(0.1,0.2) );
		p.scale( rnd(0.3,1)*fs );
		p.ds = -rnd(0.01, 0.03);
		p.rotation = rnd(0, 6.28);
		p.dr = rnd(0.06, 0.11);
		p.frict = rnd(0.97, 0.99);
		p.fadeOutSpeed = 0.06;
		p.life = rnd(4, 10);
		p.onUpdate = function() {
			if( p.dr<0.25 )
				p.dr+=0.03;
		}
	}


	public function shopGold(x,y, fs:Float) {
		var p = alloc(lib.getTile("yellowShine"), x, y);
		p.fadeIn( rnd(0.7,1), rnd(0.1,0.2) );
		p.setScale( rnd(0.3,1)*fs );
		p.ds = -rnd(0.01, 0.03);
		p.rotation = rnd(0, 6.28);
		p.dr = rnd(0.06, 0.11);
		p.frict = rnd(0.97, 0.99);
		p.fadeOutSpeed = 0.06;
		p.life = rnd(4, 10);
		p.onUpdate = function() {
			if( p.dr<0.25 )
				p.dr+=0.03;
		}
	}


	public function eventGift(e:MinorEntity) {
		if( itime%2==0 ) {
			var p = alloc(lib.getTile("fxBlueLight"), e.xx+rnd(0,35,true), e.yy-100 + 50*((ftime%30)/30) + rnd(0,10,true));
			p.fadeIn( rnd(0.7,1), 0.1 );
			p.scale( rnd(0.5,0.6));
			p.ds = -rnd(0.03, 0.06);
			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0.06, 0.11);
			p.frict = rnd(0.97, 0.99);
			p.fadeOutSpeed = 0.06;
			p.life = rnd(4, 10);
			p.onUpdate = function() {
				if( p.dr<0.25 )
					p.dr+=0.03;
			}
		}

		if( itime%7==0 ) {
			var p = alloc(lib.getTile("yellowShine"), e.xx+rnd(0,35,true), e.yy-70 + 50*((ftime%30)/30) + rnd(0,10,true));
			p.fadeIn( rnd(0.4,0.5), 0.03 );
			p.scale( rnd(0.9, 1.6));
			p.ds = -rnd(0, 0.03);
			p.fadeOutSpeed = 0.03;
			p.life = rnd(10,30);
		}
	}

	public function gem(e:MinorEntity) {
		if( itime%2==0 ) {
			var p = alloc(lib.getTile("fxBlueLight"), e.xx+rnd(0,35,true), e.yy-100 + 50*((ftime%30)/30) + rnd(0,10,true));
			p.fadeIn( rnd(0.7,1), 0.1 );
			p.scale( rnd(0.5,0.6));
			p.ds = -rnd(0.03, 0.06);
			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0.06, 0.11);
			p.frict = rnd(0.97, 0.99);
			p.fadeOutSpeed = 0.06;
			p.life = rnd(4, 10);
			p.onUpdate = function() {
				if( p.dr<0.25 )
					p.dr+=0.03;
			}
		}

		if( itime%7==0 ) {
			var p = alloc(lib.getTile("fxStreetLight"), e.xx+rnd(0,20,true), e.yy-100 + 50*((ftime%30)/30) + rnd(0,10,true));
			p.fadeIn( rnd(0.4,0.5), 0.03 );
			p.scale( rnd(0.9, 1.6));
			p.ds = -rnd(0, 0.03);
			p.fadeOutSpeed = 0.03;
			p.life = rnd(10,30);
		}
	}

	public function gemPickedUp(x:Float,y:Float) {
		var p = alloc(lib.getTile("fxNovaBlue"), x,y);
		p.setScale( 3 );
		p.ds = 0.5;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.9;

		// Central gem
		var p = alloc(lib.getTile("moneyGem"), x,y);
		p.setScale( 2.1 );
		p.ds = 0.4;
		p.life = 15;
		p.onUpdate = function() p.ds*=0.9;

		// Gem parts
		for(i in 0...10) {
			var p = alloc(lib.getTile("fxIceParticle",0), x+rnd(1,10,true),y+rnd(1,10,true));
			p.moveAwayFrom(x,y, rnd(15,20));
			p.frict = 0.95;
			p.setScale( rnd(1.5, 3) );
			p.life = rnd(10, 20);
		}

		// Lines
		for(i in 0...30) {
			var p = alloc(lib.getTile("blueLine"), x+rnd(0,30,true), y+rnd(0,30,true));
			p.alpha = rnd(0.6, 1);
			p.setScale( rnd(1,2) );
			p.moveAwayFrom(x,y, 10+rnd(0,10));
			var a = p.getMoveAng();
			var s = rnd(4,6);
			p.gx = Math.cos(a+1.8)*s;
			p.gy = Math.sin(a+1.8)*s;
			p.rotation = a;
			p.frict = rnd(0.8, 0.82);
			p.life = rnd(10,20);
			p.dsx = -0.06;
		}
	}


	public function lunchBoxCharge(x:Float,y:Float, fs:Float) {
		for( i in 0...200 ) {
			var d = rnd(200,220);
			var p = alloc(lib.getTileRandom(Std.random(100)<30?"blueShineLight":"yellowShineLight"), x+rnd(0,15,true), y+rnd(0,15,true));
			//var p = alloc(lib.getTileRandom("yellowBigDot"), x+rnd(0,15,true), y+rnd(0,15,true));
			p.delay = i*0.2;
			p.fadeIn( rnd(0.6, 1), 0.06);
			p.setScale( rnd(1,2)*fs );
			p.rotation = rnd(0,6.28);
			p.dr = -rnd(0.03, 0.06);
			p.life = rnd(50,60);
			p.onUpdate = function() {
				p.tile.setCenter(0, Std.int(d));
				//p.tile.setCenter(Std.int(d), 0);
				p.dr-=0.004;
				d += (5-d)*0.028;
			}
		}
		var p = alloc(lib.getTile("fxSunshine"), x,y);
		p.fadeIn(1, 0.1);
		p.setScale( 0.4*fs );
		p.ds = 0.1;
		p.dr = 0.1;
		p.life = 10;
		p.fadeOutSpeed = 0.06;
		p.onUpdate = function() p.ds*=0.9;
	}


	public function lunchBoxExplosion(x:Float,y:Float, i:Item, fs:Float) {
		var k = switch( i ) {
			case I_Money(_) : "fxNovaYellow";
			case I_Gem : "fxNovaBlue";
			default : "fxNovaPurple";
		}
		var p = alloc(lib.getTile(k), x,y);
		p.setScale( 1.5*fs );
		p.ds = 0.5;
		p.life = 3;
		p.onUpdate = function() p.ds*=0.9;

		var k = switch( i ) {
			case I_Money(_) : "yellowShineLight";
			case I_Gem : "blueShineLight";
			default : "yellowShineLight";
		}
		for( i in 0...100 ) {
			var p = alloc( lib.getTileRandom(k), x+rnd(0,70,true), y+rnd(0,30,true));
			p.setScale(rnd(1,2)*fs);
			p.fadeIn(1, 0.05);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0.03, 0.08, true);
			p.moveAwayFrom(x,y, rnd(3, 20)*fs);
			p.dx*=1.5;
			p.frict = 0.98;
			p.scaleMul = 0.99;
			p.life = rnd(20,40);
			p.fadeOutSpeed = 0.02;
			p.onUpdate = function() {
				if( p.isAlive() )
					p.alpha = rnd(0.5,1);
			}
		}

		for( i in 0...10 ) {
			var p = alloc( lib.getTileRandom("giftPiece"), x+rnd(0,30,true), y+rnd(0,30,true));
			p.setScale(2*fs);
			p.dr = rnd(0.10, 0.15, true);
			p.rotation = rnd(0,6.28);
			p.moveAwayFrom(x,y, rnd(20, 40)*fs);
			p.gy = rnd(0.3, 0.6)*fs;
			//p.frict = 0.92;
			p.life = rnd(10,20);
			p.fadeOutSpeed = 0.02;
		}

		for( i in 0...90 ) {
			var p = alloc( lib.getTileRandom("partyFx"), x+rnd(0,50,true), y+rnd(0,50,true), true);
			var s = rnd(0.6, 1.2);
			p.setScale(s*fs);
			var t = rnd(0,100);
			p.onUpdate = function() {
				p.scaleX = Math.cos(t*0.2)*s;
				t++;
			}
			p.moveAwayFrom(x,y, rnd(20,40)*fs);
			p.dx*=1.7;
			p.gy = rnd(0.2, 0.3);
			p.dr = rnd(0, 0.10, true);
			p.frict = rnd(0.87, 0.95);
			p.life = rnd(40,80);
		}
	}


	public function rewardItem(x:Float,y:Float, golden:Bool) {
		var p = alloc(lib.getTile(golden?"fxNovaYellow":"fxNovaBlue"), x,y);
		p.setScale( 6 );
		p.ds = -0.8;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.9;

		var p = alloc(lib.getTile(golden?"fxNovaYellow":"fxNovaBlue"), x,y);
		p.alpha = 0.6;
		p.setScale( 3 );
		p.ds = 0.7;
		p.delay = 4;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.9;

		for( i in 0...40 ) {
			var p = alloc(lib.getRandomTile(golden?"yellowLine":"blueLine"), x+rnd(0,60,true), y+rnd(0,60,true));
			p.setScale( rnd(1,2) );
			p.fadeIn(rnd(0.6,1), 0.15);
			p.moveAwayFrom(x,y, rnd(12,20));
			p.rotation = p.getMoveAng();
			p.frict = rnd(0.9, 0.95);
			p.life = rnd(20,30);
			p.delay = i*0.2;
			var ds = rnd(0.93,0.99);
			p.onUpdate = function() {
				p.scale(ds);
			}
		}

		for( i in 0...70 ) {
			var p = alloc(lib.getTile(golden?"yellowBigDot":"blueBigDot"), x+rnd(0,30,true), y+rnd(0,30,true));
			//p.alpha = rnd(0.6, 1);
			p.setScale( rnd(1, 2) );
			p.moveAwayFrom(x,y, rnd(5,20));
			var a = p.getMoveAng();
			var s = rnd(0.5,1.3);
			p.gx = Math.cos(a+1.8)*s;
			p.gy = Math.sin(a+1.8)*s;
			p.frict = rnd(0.85, 0.99);
			p.life = rnd(20,80);
		}

		var p = alloc(lib.getTile("fxSunshine"), x,y);
		p.fadeIn(1, 0.1);
		p.setScale( 0.4 );
		p.ds = 0.1;
		p.dr = 0.1;
		p.life = 10;
		p.fadeOutSpeed = 0.06;
		p.onUpdate = function() p.ds*=0.9;
	}

	public function rewardMaxedHappiness(x:Float,y:Float) {
		var p = alloc(lib.getTile("fxNovaGreen"), x,y);
		p.setScale( 6 );
		p.ds = -0.8;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.9;

		var p = alloc(lib.getTile("fxNovaGreen"), x,y);
		p.alpha = 0.6;
		p.setScale( 3 );
		p.ds = 0.7;
		p.delay = 4;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.9;

		for( i in 0...40 ) {
			var p = alloc(lib.getRandomTile("greenLine"), x+rnd(0,60,true), y+rnd(0,60,true));
			p.setScale( rnd(1,2) );
			p.fadeIn(rnd(0.6,1), 0.15);
			p.moveAwayFrom(x,y, rnd(12,20));
			p.rotation = p.getMoveAng();
			p.frict = rnd(0.9, 0.95);
			p.life = rnd(20,30);
			p.delay = i*0.2;
			var ds = rnd(0.93,0.99);
			p.onUpdate = function() {
				p.scale(ds);
			}
		}


		for( i in 0...90 ) {
			var t = rnd(0,100);
			var s = rnd(0.6, 1.2);
			var p = alloc( lib.getTileRandom("partyFx"), x+rnd(0,50,true), y+rnd(0,50,true), true);
			p.setScale(s);
			p.onUpdate = function() {
				p.scaleX = Math.cos(t*0.2)*s;
				t++;
			}
			p.moveAwayFrom(x,y, rnd(20,40));
			p.dx*=1.7;
			p.gy = rnd(0.2, 0.3);
			p.dr = rnd(0, 0.10, true);
			p.frict = rnd(0.87, 0.95);
			p.life = rnd(40,80);
		}
	}


	public function shake(pow:Float, duration:Float) {
		tw.terminateWithoutCallbacks(Game.ME.shake);
		Game.ME.shake = pow;
		tw.create(Game.ME.shake, 0, duration, TEaseOut);
	}


	public function roomExplosion(r:b.Room) {
		shake(1, 600);

		// Smoke
		for(i in 0...4) {
			var p = alloc(lib.getTile("fxExploSmoke"), r.globalCenterX + rnd(0,30,true), r.globalCenterY + rnd(0,30,true), false);
			p.alpha = rnd(0.6, 0.8);
			p.rotation = rnd(0,6.28);
			p.setScale( rnd(0.4, 0.8) );
			p.ds = rnd(0.6, 0.8);
			p.dr = rnd(0.07, 0.12)*(i%2==0?1:-1);
			p.life = rnd(10, 15);
			p.fadeOutSpeed = rnd(0.02, 0.04);
			p.onUpdate = function() {
				p.ds*=0.9;
				p.dr*=0.9;
			}
		}

		// Core
		for(i in 0...4) {
			var p = alloc(lib.getTile("fxGoldGlow"), r.globalCenterX - 100 + 200*i/4 + rnd(0,20,true), r.globalCenterY + rnd(20,70,true));
			p.alpha = rnd(0.8, 1);
			p.delay = i*2;
			p.scaleX = rnd(2, 4);
			p.scaleY = p.scaleX*0.8;
			p.ds = rnd(0.10, 0.30);
			p.life = rnd(3, 8);
			p.onUpdate = function() {
				p.dsx*=0.95;
				p.dsy*=0.9;
			}
		}

		// Dots
		for(i in 0...50) {
			var p = alloc(lib.getTile(Std.random(100)<60?"redDot":"yellowDot"), r.globalLeft + r.wid*rnd(0.2,0.8), r.globalCenterY + rnd(0,50,true));
			p.setScale( rnd(1, 5) );
			p.moveAwayFrom(r.globalCenterX, r.globalCenterY, i<30 ? rnd(5,25) : rnd(20,60));
			p.frict = rnd(0.97, 0.99);
			p.delay = rnd(0,3);
			p.gy = rnd(0, 1);
			p.gx = rnd(0, 0.5);
			p.life = rnd(7, 25);
		}
	}



	public function xpBar(x:Float, y:Float, h:Float) {
		var p = alloc(lib.getTile("greenBigDot"), x, y+rnd(0,h));
		p.setScale( rnd(1,2) );
		p.dx = -rnd(1,2);
		p.life = rnd(10,30);
		p.frict = 0.97;

		for(i in 0...2) {
			var p = alloc(lib.getTile("greenDot"), x, y+rnd(0,h));
			p.alpha = rnd(0.4, 0.7);
			p.dx = -rnd(0,2);
			p.gy = -rnd(0.2, 0.5);
			p.frict = 0.96;
			p.life = rnd(8,10);
		}
	}

	public function halo(alpha:Float, x:Float,y:Float, sx:Float,sy:Float) {
		var p = alloc(lib.getTile("fxStreetLight"), x,y);
		p.fadeIn(alpha, 0.3);
		p.scaleX = sx;
		p.scaleY = sy;
		p.fadeOutSpeed = 0.03;
		p.life = 10;
	}

	public function xpBarLevelUp() {
		//var b = ui.XpBar.CURRENT;
		//var r = b.getRect(false);
//
		//for(i in 0...100 ) {
			//var p = alloc(lib.getTile(i%3==0?"yellowBigDot":"greenBigDot"), r.x+rnd(0,r.w), r.y+rnd(0,r.h));
			//p.setScale( rnd(2,4) );
			////p.moveAwayFrom(r.x+r.w*0.5, r.y, rnd(4,10));
			//p.dx = rnd(0,4,true);
			//p.dy = -rnd(0,4);
			//p.delay = i*0.05;
			//p.frict = rnd(0.94, 0.97);
			//p.gy = rnd(0, 0.3);
			//p.life = rnd(20,40);
		//}
	}


	public function bar(k:String, x:Float, y:Float) {
		var p = alloc(lib.getTile(k), x+rnd(0,1,true), y+rnd(0,5,true));
		p.scale( rnd(2,3));
		p.alpha = 0;
		p.da = 0.2;
		p.maxAlpha = rnd(0.5,1);
		p.dx = rnd(0,0.2,true);
		p.dy = rnd(0,0.5,true);
		p.gx = -rnd(0, 0.3);
		p.frict = 0.95;
		p.life = rnd(10,20);
	}

	public function refine(r:b.Room) {
		var x = rnd(r.globalLeft+40, r.globalRight-40);
		var y = rnd(r.globalTop+40, r.globalBottom-40);
		var p = alloc(lib.getTile("bigSmokeBlue"), x,y);
		p.alpha = 0;
		p.maxAlpha = rnd(0.3, 0.6);
		p.da = 0.03;
		p.dr = rnd(0, 0.004, true);
		p.life = rnd(30,60);
		p.fadeOutSpeed = 0.02;
		p.scale( rnd(1.5, 2.5));
		p.moveAng(rnd(0,6.28), rnd(0, 0.6));
	}


	public function happinessMaxed(e:Client) {
		var r = e.getRealRoom();

		// Lines
		for(i in 0...60) {
			var a = rnd(0,6.28);
			var d = rnd(500,800);
			var p = alloc(lib.getTileRandom("blueLine"), r.globalCenterX+Math.cos(a)*d, r.globalCenterY+Math.sin(a)*d);
			p.setScale(rnd(1.5,3));
			p.dsx = -0.03;
			p.moveTo(r.globalCenterX, r.globalCenterY, rnd(90,110));
			p.rotation = p.getMoveAng();
			p.frict = rnd(0.85, 0.87);
			p.delay = irnd(0,5);
			p.life = rnd(8,12);
		}

		// Blink
		var p = alloc(lib.getTile("goodColor"), r.globalLeft, r.globalTop);
		p.setCenterRatio(0,0);
		p.width = r.wid;
		p.height = r.hei;
		p.fadeIn(1, 0.3);
		p.life = 10;
		p.delay = 10;
		p.fadeOutSpeed = 0.01;

		// Dots
		for(i in 0...120) {
			var x = rnd( r.globalLeft, r.globalRight );
			var y = rnd( r.globalTop, r.globalBottom );
			var p = alloc(lib.getTileRandom("partyFx"), x,y);
			var s = rnd(0.4, 0.8);
			p.setScale(s);
			p.gy = rnd(0.06,0.15);
			p.rotation = rnd(0, 6.28);
			p.moveAwayFrom(r.globalCenterX, r.globalCenterY, rnd(8,17));
			p.frict = rnd(0.88, 0.90);
			p.life = rnd(45,70);
			p.fadeOutSpeed = rnd(0.03, 0.08);
			p.dr = rnd(0,0.1,true);
			p.delay = 10 + irnd(0,4) + i*0.05;
			var t = rnd(0,100);
			p.onUpdate = function() {
				p.scaleX = Math.cos(t*0.2)*s;
				t++;
			}
		}
	}


	public function happinessDelta(e:Entity, delta:Int) {
		var r = e.room;

		// Blink
		var p = alloc(lib.getTile(delta>0?"goodColor":"badColor"), r.globalLeft, r.globalTop);
		p.setCenterRatio(0,0);
		p.width = r.wid;
		p.height = r.hei;
		p.fadeIn(1, 0.3);
		p.life = 8;
		p.fadeOutSpeed = 0.03;

		// Label
		var t = Assets.createBatchText(Game.ME.textSbHuge, Assets.fontHuge);
		t.text = delta>0 ? "+"+delta : ""+delta;
		t.textColor = delta>0 ? 0xFFFFFF : 0xFFC600;
		t.dropShadow = { color:0x0, alpha:0.75, dx:1, dy:2 }
		tw.create(t.scaleX, 0.5>2, 500).onUpdate = function() {
			t.scaleY = t.scaleX;
			t.x = Std.int( r.globalCenterX-t.textWidth*0.5*t.scaleX );
			t.y = Std.int( r.globalCenterY-t.textHeight*0.5*t.scaleY );
		}
		delayer.add( function() {
			tw.create(t.alpha, 0, 500).onEnd = function() {
				t.dispose();
			}
		}, 1200 );

		// Dots
		for(i in 0...40) {
			var x = rnd( r.globalLeft, r.globalRight );
			var y = rnd( r.globalTop, r.globalBottom );
			var p = alloc(lib.getTile(delta>0?"greenBigDot":"redBigDot"), x,y);
			p.setScale( rnd(2,4) );
			p.gx = rnd(0,0.1,true);
			p.gy = rnd(0,0.1,true);
			p.life = rnd(5,20);

			var a = Math.atan2(r.globalCenterY-p.y, r.globalCenterX-p.x);
			p.moveAng( a+3.14, rnd(15,25) );
			p.frict = rnd(0.80, 0.85);

		}
	}


	public function popText(x,y, txt:Dynamic, ?col=0xFFFFFF) {
		var wrapper = new h2d.Sprite(normalSb);
		wrapper.x = x;
		wrapper.y = y;
		var t = new h2d.Text(Assets.fontHuge, wrapper);
		t.text = Std.string(txt);
		t.scale(0.6);
		t.textColor = col;
		t.x = Std.int(-t.width*0.5*t.scaleX);
		t.y = Std.int(-t.height*0.5*t.scaleY);
		t.filter = true;

		var life = Const.seconds(0.6);
		var s = 0.3;
		var p = createChildProcess(
			function(p) {
				wrapper.scale(1+s);
				s*=0.8;
				life--;
				if( life<0 ) {
					t.alpha-=0.05;
					if( t.alpha<=0 )
						p.destroy();
				}
			},
			function(p) {
				wrapper.dispose();
				wrapper = null;

				t.dispose();
				t = null;
			}
		);
	}


	public function popItem(i:Item, x,y) {
		var p = alloc( lib.getTile(Assets.getItemIcon(i)), x,y );
		p.setScale(1.6);
		p.ds = 0.2;
		p.onUpdate = function() p.ds*=0.9;
		p.life = 25;
		p.alpha = 0.8;

		for(i in 0...40) {
			var p = alloc(lib.getTile("greenDot"), x+rnd(0,20,true), y+rnd(0,20,true));
			p.setScale( rnd(1,3) );
			p.moveAwayFrom(x,y, rnd(5, 10));
			p.frict = rnd(0.97, 0.99);
			p.life = rnd(20, 50);
			p.onUpdate = function() {
				if( p.isAlive() )
					p.alpha = 0.5 + rnd(0,0.3,true);
			}
		}

		switch( i ) {
			//case I_Slime(n) :
				//popText(x,y, Game.ME.prettyNumber(n));

			case I_Money(n) :
				popText(x,y, Game.ME.prettyMoney(n));

			default :
		}
	}


	public function popIcon(k:String, x,y) {
		var p = alloc( lib.getTile(k), x,y );
		p.setScale(1.6);
		p.ds = 0.2;
		p.onUpdate = function() p.ds*=0.9;
		p.life = 25;
		p.alpha = 0.8;

		for(i in 0...40) {
			var p = alloc(lib.getTile("greenDot"), x+rnd(0,20,true), y+rnd(0,20,true));
			p.setScale( rnd(1,3) );
			p.moveAwayFrom(x,y, rnd(5, 10));
			p.frict = rnd(0.97, 0.99);
			p.life = rnd(20, 50);
			p.onUpdate = function() {
				if( p.isAlive() )
					p.alpha = 0.5 + rnd(0,0.3,true);
			}
		}
	}



	public function lobbyUpgrade(r:b.r.Lobby, newLevel:Int) {
		var w = r.slotWid;
		var x = r.globalLeft + 400 + w*(Game.ME.shotel.getQueueLength()-1);
		var y = r.globalBottom;
		var n = 25;
		for(i in 0...n) {
			for(s in 0...2) {
				var r = i/n;
				var p = new HParticle(lib.getTile("fxStreetLight"), x- w*0.5+s*w +rnd(0,10,true), y+40-r*120+rnd(0,5,true));
				p.fadeIn(0.2, 0.1);
				p.delay = i*0.7;
				p.dy = -rnd(0,4);
				p.dsx = -0.06;
				p.frict = 0.97;
				p.life = rnd(15,20);
				}
		}

		for(i in 0...40) {
			var y = y-50;
			var a = rnd(0,6.28);
			var p = new HParticle(lib.getTile("yellowBigDot"), x+Math.cos(a)*rnd(200,250), y+Math.sin(a)*rnd(200,250));
			p.setScale( rnd(1,4) );
			p.moveTo(x,y, rnd(7,15));
			p.fadeIn(rnd(0.7,1), 0.2);
			p.delay = 10+i*0.6;
			p.frict = 0.97;
			p.life = rnd(15,20);
		}

		var p = alloc(lib.getTile("fxSunshine"), x,y-40);
		p.fadeIn(1, 0.2);
		p.setScale( 2 );
		p.life = 10;
		p.dr = 0.05;
		p.fadeOutSpeed = 0.03;

		var p = alloc(lib.getTile("fxSunshine"), x,y-40);
		p.fadeIn(1, 0.2);
		p.setScale( 2 );
		p.life = 10;
		p.dr = -0.03;
		p.fadeOutSpeed = 0.03;
	}

	public function roomUpgrade(r:b.Room) {
		var k = "yellowBigDot";

		var n = 30;
		for(i in 0...n) {
			var p = alloc(lib.getTile("godLight"), r.globalLeft+r.wid*0.5, r.globalBottom-(i/n)*r.hei);
			p.alpha = 0.8;
			p.width = r.wid;
			p.height = 100;
			p.delay = i*0.4;
			p.life = 10;
			p.fadeOutSpeed = 0.01;

			for(x in 0...2) {
				var p = alloc(lib.getTile(k), r.globalLeft+x*r.wid+rnd(0,20,true), r.globalBottom-(i/n)*r.hei + rnd(0,10,true));
				p.setScale( rnd(4,8) );
				p.dx = rnd(0,4,true);
				p.dy = rnd(0,4,true);
				p.frict = rnd(0.93, 0.97);
				p.delay = i*0.4;

			}
		}

		var p = alloc(lib.getTile("fxSunshine"), r.globalLeft+15, r.globalTop+r.hei*0.5);
		p.fadeIn(1, 0.2);
		p.rotation = 1.57;
		p.setScale( 4 );
		p.scaleY = p.scaleX*0.7;
		p.life = 6;
		p.fadeOutSpeed = 0.03;

		var p = alloc(lib.getTile("fxSunshine"), r.globalRight-15, r.globalTop+r.hei*0.5);
		p.fadeIn(1, 0.2);
		p.rotation = 1.57;
		p.setScale( 4 );
		p.scaleY = p.scaleX*0.7;
		p.life = 6;
		p.fadeOutSpeed = 0.03;
	}

	public function droppingGem(e:Entity) {
		var p = alloc(lib.getTile("blueBigDot"), e.centerX - e.dir*50 + rnd(0,20,true), e.centerY+25+rnd(0,25,true));
		p.scale( rnd(1,3));
		p.moveAng( (e.dir==1?3.14:0) + rnd(0, 0.3, true), rnd(5,15));
		p.frict = rnd(0.90, 0.99);
		p.life = rnd(10,30);
	}


	public function loveCollected(x:Float,y:Float) {
		for(i in 0...100) {
			var p = alloc( lib.getTile("redBigDot"), x+rnd(0,200,true), y+rnd(0,50,true) );
			p.moveAwayFrom(x,y, rnd(20,30));
			p.setScale(rnd(1,3));
			p.alpha = rnd(0.5,1);
			p.frict = rnd(0.85, 0.95);
			p.life = rnd(30,60);
		}
		var p = alloc( lib.getTile("moneyLove"), x,y );
		p.ds = 1;
		p.onUpdate = function() p.ds*=0.9;
		p.life = 10;
	}


	public function collectPack(k:String, n:Int, sx:Float, sy:Float, tx:Float, ty:Float) {
		var pt = Game.ME.sceneToUi(sx,sy);
		var x = pt.x;
		var y = pt.y;
		var d = Lib.distance(x,y, tx,ty);

		var coins = MLib.min(6, n);
		for(i in 0...coins) {
			var x = x + rnd(0,30,true);
			var y = y + rnd(0,30,true);
			var a = Math.atan2(ty-y, tx+rnd(0,60,true)-x) + rnd(0, 0.05, true);
			var s = 45 * rnd(0.9, 1.1);
			var p = alloc( lib.getTile(k), x,y );
			p.setScale( rnd(0.4, 0.5) );
			p.rotation = rnd(0, 1, true);
			p.dr = rnd(0, 0.05, true);
			p.delay = i*0.15 + rnd(0,4,true);
			p.life = (d-20)/s;
			p.moveAng(a, s);
			p.fadeOutSpeed = 1;
			p.onKill = function() {
				for(i in 0...5) {
					var x = p.x;
					var y = p.y;
					var p = alloc(lib.getTile("yellowBigDot"), x+rnd(0,8,true), y+rnd(0,8,true));
					p.setScale(rnd(3,4));
					p.ds = -0.1;
					p.life = rnd(10,20);
					p.moveAwayFrom(x,y,rnd(2,3));
					p.frict = 0.92;
				}
			}
		}
	}


	var moveOff : Float = 1.0;
	public function moveClient(fx:Float, fy:Float, tx:Float, ty:Float, ?spd=1.0) {
		var d = Lib.distance(fx,fy, tx,ty);
		var a = Math.atan2(ty-fy, tx-fx);
		var s = spd * 95 * rnd(0.9, 1.1);
		var p = alloc( lib.getTile("nameGlow",3), fx,fy );
		p.setCenterRatio(0.5,0.5);
		p.setScale(1);
		p.life = (d-40)/s;
		p.moveAng(a, s);
		p.fadeOutSpeed = 1;
		//var off = moveOff++;
		//if( moveOff>=3 )
			//moveOff = 1;
		p.onUpdate = function() {
			//p.tile.setCenterRatio( 0.5, 0.5+Math.sin(3.14*p.time)*off );
			var a = p.getMoveAng();
			for(i in 0...3) {
				var p = alloc(lib.getTile("blueLine"), p.x+rnd(0,10,true), p.y+rnd(0,10,true));
				p.fadeIn(rnd(0.5,1), 0.1);
				p.setScale(rnd(1.5,2.5));
				p.rotation = a;
				p.moveAng(rnd(0,6.28), rnd(0,1));
				p.life = rnd(10,20);
			}
		}
		p.onKill = function() {
			var p = alloc( lib.getTile("fxNovaBlue"), tx,ty );
			p.ds = 0.5;
			p.onUpdate = function() {
				p.ds*=0.9;
			}
			p.life = 5;
		}
	}


	public function moveIcon(k:String, tail:String, fx:Float, fy:Float, tx:Float, ty:Float, ?small=false, ?spd=1.0) {
		var d = Lib.distance(fx,fy, tx,ty);
		var a = Math.atan2(ty-fy, tx-fx);
		var s = spd * 80 * rnd(0.9, 1.1);
		var p = alloc( lib.getTile(k), fx,fy, false );
		p.setScale(small?1.1:1.5);
		p.life = (d-40)/s;
		p.moveAng(a, s);
		p.fadeOutSpeed = 1;
		var off = moveOff++;
		if( moveOff>=3 )
			moveOff = 1;
		p.onUpdate = function() {
			p.tile.setCenterRatio( 0.5, 0.5+Math.sin(3.14*p.time)*off );
			var a = p.getMoveAng();
			for(i in 0...3) {
				var p = alloc(lib.getTile(tail), p.x+p.tile.dx+rnd(0,10,true), p.y+p.tile.dy+rnd(0,10,true));
				p.fadeIn(rnd(0.5,1), 0.1);
				p.setScale(small?rnd(1,2):rnd(2,3));
				p.rotation = a;
				p.moveAng(rnd(0,6.28), rnd(0,1));
				p.life = rnd(10,20);
			}
		}
		p.onKill = function() {
			var p = alloc( lib.getTile("fxNovaYellow"), tx,ty );
			p.ds = 0.5;
			p.onUpdate = function() {
				p.ds*=0.9;
			}
			p.life = 5;

			var p = alloc( lib.getTile(k), tx,ty );
			p.ds = 0.2;
			p.onUpdate = function() {
				p.ds*=0.9;
			}
			p.life = 5;
		}
	}


	public function collectItem(i:Item, sx:Float, sy:Float, to:String) {
		var k = Assets.getItemIcon(i);

		var pt = Game.ME.sceneToUi(sx,sy);
		var x = pt.x + rnd(0,20,true);
		var y = pt.y + rnd(0,20,true);
		var pt = ui.HudMenu.CURRENT.getButtonCoord(to);
		var tx = pt==null ? w()-40 : pt.x;
		var ty = pt==null ? h()*0.5 : pt.y;

		var d = Lib.distance(x,y, tx,ty);
		var a = Math.atan2(ty-y, tx-x);
		var s = 60 * rnd(0.9, 1.1);
		var p = alloc( lib.getTile(k), x,y, false );
		p.setScale( 1.6 );
		p.life = (d-40)/s;
		p.moveAng(a, s);
		p.fadeOutSpeed = 0.3;
		p.dr = rnd(0.1, 0.2);

		var tail = switch( i ) {
			case I_Cold : "blueLine";
			case I_Heat : "redLine";
			case I_Noise : "pinkLine";
			case I_Odor : "greenLine";
			case I_Light : "yellowLine";
			default : "redLine";
		}
		p.onUpdate = function() {
			var a = p.getMoveAng();
			for(i in 0...3) {
				var p = alloc(lib.getTile(tail), p.x+rnd(0,10,true), p.y+rnd(0,10,true));
				p.fadeIn(rnd(0.5,1), 0.1);
				p.setScale(rnd(2,3));
				p.rotation = a;
				p.moveAng(rnd(0,6.28), rnd(0,1));
				p.life = rnd(10,20);
			}
		}

		p.onKill = function() {
			var p = alloc( lib.getTile("fxNovaYellow"), tx,ty );
			p.ds = 0.5;
			p.onUpdate = function() {
				p.ds*=0.9;
			}
			p.life = 5;

			var p = alloc( lib.getTile(k), tx,ty );
			p.ds = 0.2;
			p.onUpdate = function() {
				p.ds*=0.9;
			}
			p.life = 5;
		}
	}


	public function roomValidated(r:b.Room) {
		var g = 50;
		var w = MLib.floor(r.wid/g);
		var h = MLib.floor(r.hei/g);
		for(cx in 0...w)
			for(cy in 0...h) {
				var x = g + r.globalLeft + (cx+0.5)*g + rnd(0,g*0.5,true);
				var y = r.globalTop + (cy+0.5)*g + rnd(0,g*0.5,true);
				var p = alloc(lib.getTile("blueShine"), x,y);
				p.fadeIn(1, 0.1);
				p.rotation = 1.57;
				p.setScale( rnd(1,2) );
				p.dx = -rnd(2,5);
				p.dy = rnd(0, 3, true);
				p.delay = (1-(cx/w))*12;
				p.frict = rnd(0.9, 0.95);
				p.ds = -rnd(0.02,0.05);
				p.life = rnd(7,12);
			}
	}


	public function roomSkipped(r:b.Room) {
		var g = 80;
		var w = MLib.floor(r.wid/g);
		var h = MLib.floor(r.hei/g);
		for(cx in 0...w)
			for(cy in 0...h) {
				var x = r.globalLeft + (cx+0.5)*g + rnd(0,g*0.3,true);
				var y = r.globalTop + (cy+0.5)*g + rnd(0,g*0.3,true);
				var p = alloc(lib.getTile("blueHugeDot"), x,y);
				p.setScale( rnd(1,3) );
				p.moveAwayFrom(r.globalCenterX, r.globalCenterY, rnd(1,4));
				p.delay = rnd(0,5);
				p.frict = rnd(0.8, 0.95);
				p.ds = -rnd(0.02,0.06);
				p.life = rnd(40,65);
			}
	}

	public function maxHappiness(e:Entity) {
		for(i in 0...60) {
			var p = alloc(lib.getTile(i%3==0?"greenBigDot":"greenLine"), e.centerX+rnd(1,40,true), e.centerY+rnd(1,40,true));
			p.setScale( rnd(1,3) );
			p.moveAwayFrom(e.centerX, e.centerY, rnd(15,40));
			p.rotation = p.getMoveAng();
			p.delay = rnd(0,2);
			p.frict = rnd(0.92, 0.97);
			//p.gx = rnd(0,0.2,true);
			//p.gy = rnd(0,0.2,true);
			p.life = rnd(20,40);
		}
	}

	public function clientSpecialTrigger(e:Entity) {
		for(i in 0...60) {
			var p = alloc(lib.getTile(i%3==0?"blueBigDot":"blueLine"), e.centerX+rnd(1,40,true), e.centerY+rnd(1,40,true));
			p.setScale( rnd(1,3) );
			p.moveAwayFrom(e.centerX, e.centerY, rnd(5,20));
			p.rotation = p.getMoveAng();
			p.delay = rnd(0,2);
			p.frict = rnd(0.92, 0.97);
			//p.gx = rnd(0,0.2,true);
			//p.gy = rnd(0,0.2,true);
			p.life = rnd(20,40);
		}
	}

	public function sparks(x:Float,y:Float, alpha:Float) {
		var x = x + rnd(0,25,true);
		var y = y + rnd(0,40, true);

		var p = alloc(lib.getTileRandom("lightningPart"), x+rnd(0,5,true), y+rnd(0,5,true));
		p.fadeIn(alpha*rnd(0.8,1), 0.3);
		p.setScale(rnd(2,3.5));
		p.rotation = rnd(0,6.28);
		p.dr = rnd(0,0.04,true);
		p.ds = -rnd(0.05,0.08);
		p.life = rnd(0,5);

		var p = alloc(lib.getTileRandom("lightningPart"), x+rnd(0,5,true), y+rnd(0,5,true));
		p.fadeIn(alpha*rnd(0.3,0.5), 0.2);
		p.setScale(rnd(2,3.5));
		p.rotation = rnd(0,6.28);
		p.dr = rnd(0,0.04,true);
		p.ds = rnd(0.05,0.08);
		p.delay = rnd(1,2);
		p.life = rnd(0,5);
	}

	public function inspectorArrival(e:en.Client) {
		for(i in 0...40) {
			var p = alloc( lib.getTile("redLine"), e.centerX+rnd(0,20,true), e.centerY+rnd(0,20,true) );
			p.moveAwayFrom(e.centerX, e.centerY, rnd(10,20));
			p.rotation = p.getMoveAng();
			p.scaleX = rnd(0.4, 2);
			p.scaleY = 2;
			p.dsx = -rnd(0.02,0.05);
			p.frict = rnd(0.9, 0.97);
			p.life = rnd(20, 40);
		}
		for(i in 0...20) {
			var p = alloc( lib.getTile("fxExploSmoke"), e.centerX+rnd(0,40,true), e.centerY+rnd(0,60,true) );
			p.moveAwayFrom(e.centerX, e.centerY, rnd(7,10));
			p.rotation = rnd(0,6.28);
			p.setScale(rnd(1,2));
			p.gx = rnd(0,0.1);
			p.dr = rnd(0,0.03,true);
			p.gy = -rnd(0,0.2);
			p.frict = rnd(0.7, 0.8);
			p.life = rnd(40, 60);
			p.ds = -rnd(0.005,0.010);
			p.fadeOutSpeed = 0.01;
		}
	}


	public function vipSparks(e:Client) {
		var p = alloc( lib.getTile("iconVip"), e.centerX+rnd(20,30,true), e.centerY+rnd(20,45,true) );
		p.setScale(rnd(0.1,0.4));
		p.fadeIn(rnd(0.5,1), 0.15);
		p.dx = rnd(0,8,true);
		p.dy = rnd(0,8,true);
		p.gx = rnd(0,0.5,true);
		p.gy = rnd(0,0.5,true);
		p.frict = rnd(0.75, 0.80);
		p.life = rnd(10,30);
	}


	public function vipArrival(e:en.Client) {
		for(i in 0...40) {
			var p = alloc( lib.getTile("iconVip"), e.centerX+rnd(0,20,true), e.centerY+rnd(0,20,true) );
			p.moveAwayFrom(e.centerX, e.centerY, rnd(10,20));
			p.rotation = rnd(0,0.1,true);
			p.setScale( rnd(0.4, 2) );
			p.ds = -rnd(0.02,0.05);
			p.frict = rnd(0.9, 0.97);
			p.life = rnd(40, 60);
		}
		for(i in 0...20) {
			var p = alloc( lib.getTile("fxExploSmoke"), e.centerX+rnd(0,40,true), e.centerY+rnd(0,60,true) );
			p.moveAwayFrom(e.centerX, e.centerY, rnd(7,10));
			p.rotation = rnd(0,6.28);
			p.setScale(rnd(1,2));
			p.gx = rnd(0,0.1);
			p.dr = rnd(0,0.03,true);
			p.gy = -rnd(0,0.2);
			p.frict = rnd(0.7, 0.8);
			p.life = rnd(40, 60);
			p.ds = -rnd(0.005,0.010);
			p.fadeOutSpeed = 0.01;
		}
	}


	public function inspector(e:en.Client) {
		var p = alloc(lib.getTile("uiGuestDislike"), e.centerX + rnd(10,40,true), e.yy-rnd(0,e.hei));
		p.moveAwayFrom(e.centerX, e.centerY, rnd(0,3));
		p.setScale(rnd(1,2));
		p.fadeIn(rnd(0.05, 0.10), rnd(0.01, 0.04));
		p.rotation = rnd(0,0.2,true);
		p.ds = -rnd(0,0.03);
		p.gx = rnd(0,0.3);
		p.gy = -rnd(0,0.8);
		p.frict = rnd(0.7, 0.9);
		p.life = rnd(20,40);
		p.fadeOutSpeed = 0.005;
		p.onUpdate = function() {
			p.dx+=Math.cos(ftime*0.1)*0.2;
		}
	}

	public function sparkExplosion(r:Room) {
		lightning(r.globalLeft+40, r.globalCenterY+50, r.globalRight-30, r.globalCenterY+50, 35);
		for(i in 0...40) {
			var p = alloc(lib.getTileRandom("lightningLine"), rnd(r.globalLeft+40, r.globalRight-40), r.globalCenterY + rnd(0,100));
			p.alpha = rnd(0.3, 0.6);
			p.setScale(rnd(1.5, 3));
			p.rotation = rnd(0, 0.25, true);
			p.ds = -rnd(0.03, 0.06);
			//p.dr = rnd(0.4, 0.8,true);
			p.delay = i*1.3 + rnd(0,5,true);
			p.life = rnd(3,6);
			p.fadeOutSpeed = rnd(0.06, 0.10);
		}
		roomElectrocution(r, 60);
	}

	public function roomElectrocution(r:Room, frames:Float) {
		var f = 1.3;
		for(i in 0...MLib.ceil(frames/f)) {
			var p = alloc(lib.getTile("white"), r.globalCenterX, r.globalCenterY);
			p.color = h3d.Vector.fromColor(alpha(0x2BAFFF, rnd(0.02, 0.2)));
			p.width = r.wid;
			p.height = r.hei;
			p.delay = i*f + rnd(0,3,true);
			p.fadeOutSpeed = 0.06;
			p.life = 0;
		}
	}

	public function lightning(fx:Float, fy:Float, tx:Float, ty:Float, ?off=60.) {
		var n = 8;
		var segs = 16;
		var a = Math.atan2(ty-fy, tx-fx);
		var d = Lib.distance(fx,fy, tx,ty);
		for(i in 0...n) {
			var lx = fx;
			var ly = fy;
			var tx = tx + rnd(0,100,true);
			var ty = ty + rnd(0,60,true);
			var s = rnd(0,3);
			for(j in 1...segs+1) {
				var bx = fx + Math.cos(a)*(d*j/segs);
				var by = fy + Math.sin(a)*(d*j/segs);
				var x = bx + rnd(0,off,true);
				var y = by + rnd(0,off, true);
				var p = alloc(lib.getTileRandom("lightningLine"), x,y);
				p.alpha = rnd(0.8,1);
				p.tile.setCenterRatio(0,0.5);
				p.rotation = Math.atan2(ly-y, lx-x);
				p.width = Lib.distance(x,y, lx,ly)*1.3;// + rnd(2,10);
				p.scaleY = p.scaleX;
				p.moveAng(a, s);
				p.frict = 0.93;
				p.ds = -rnd(0, 0.01);
				p.delay = i*6 + j*0.7 + irnd(0,1,true);
				//p.life = 8 + 5*(j/segs);
				p.life = 9 + 2*(j/segs);
				p.fadeOutSpeed = 0.2;

				lx = x;
				ly = y;

				//var p = alloc(lib.getTileRandom("blueBigDot"), bx + rnd(0,20,true), by+rnd(0,20,true));
				//p.moveAng(a, rnd(5,10));
				//p.setScale(rnd(2,3));
				//p.fadeIn(rnd(0.5, 1), 0.2);
				//p.life = rnd(10,30);
				//p.frict = 0.95;
				//p.delay = 10 + i*8 + j*1.5;
			}
		}
	}


	public function roomRepaired(r:b.Room) {
		for(i in 0...40) {
			var x = rnd( r.globalLeft, r.globalRight );
			var y = rnd( r.globalTop, r.globalBottom );
			var p = alloc(lib.getTile("yellowDot"), x,y);
			p.setScale( rnd(2,6) );
			p.gx = rnd(0,0.1,true);
			p.gy = rnd(0,0.1,true);
			p.life = rnd(5,20);

			var a = Math.atan2(r.globalCenterY-p.y, r.globalCenterX-p.x);
			p.moveAng( a+3.14, rnd(15,25) );
			p.frict = rnd(0.80, 0.85);

		}
	}


	public function roomWarning(r:b.Room, ?k:String, ?col=0xFF0000, ?a=1.0) {
		var p = alloc(lib.getTile("white"), r.globalCenterX, r.globalCenterY);
		p.color = h3d.Vector.fromColor(alpha(col, a));
		p.width = r.wid;
		p.height = r.hei;
		//p.fadeIn(0.5, 0.1);
		p.fadeOutSpeed = 0.06;
		p.life = 0;

		if( k!=null ) {
			var p = alloc(lib.getTile(k), r.globalCenterX, r.globalCenterY);
			p.scale(2);
			p.life = 0;
			p.ds = 0.03;
			p.onUpdate = function() p.ds*=0.93;
			p.fadeOutSpeed = 0.06;
		}
	}


	public function blinkIcon(x:Float, y:Float, k:String, ?scale=1.0) {
		var p = alloc(lib.getTile(k), x,y);
		p.setScale(scale);
		p.fadeOutSpeed = 0.06;
		p.life = 1;
		p.ds = 0.017;
		p.onUpdate = function() {
			p.ds*=0.91;
		}
	}


	public function workStarted(r:b.Room) {
		var x = r.globalLeft;
		var y = r.globalTop;
		var w = r.wid;
		var h = r.hei;

		var xc = x+w*0.5;
		var yc = y+h*0.5;

		for(i in 0...40) {
			var horiz = Std.random(2)==0;
			var xx = x + rnd(0, w);
			var yy = y + rnd(0, h);

			if( horiz )
				yy = Std.random(2)==0 ? y : y+h;
			else
				xx = Std.random(2)==0 ? x : x+w;

			var a = Math.atan2(y-yc, x-xc);
			var p = alloc( lib.getTile("redLine"), xx, yy );
			p.alpha = 0;
			p.da = rnd(0.1, 0.2);
			p.rotation = horiz ? 0 : 1.57;
			//p.scale( rnd(2,4));
			p.life = rnd(30,50);

			var a = Math.atan2(r.globalCenterY-p.y, r.globalCenterX-p.x);
			p.moveAng( a+3.14, rnd(15,25) );
			p.frict = rnd(0.60, 0.65);

		}
	}


	public function repairerSmoke(e:Entity) {
		var p = alloc(lib.getTile("bigSmokeBlue"), e.xx+rnd(0,20,true), e.yy-10);
		p.fadeIn(rnd(0.3, 0.6), 0.2);
		p.scale( rnd(0.7, 1.3));
		//p.scaleX = rnd(1,2);
		//p.scaleY = rnd(0.3, 0.7);
		p.dsx = -rnd(0, 0.015);
		p.dx = rnd(2,5,true);
		p.rotation = rnd(0,6.28);
		p.dr = rnd(0, 0.1) * (p.dx>0?1:-1);
		p.frict = rnd(0.9, 0.96);
		p.life = rnd(8,15);
		p.fadeOutSpeed = 0.03;
	}



	public function smokeBomb(e:Entity) {
		var n = 7;
		for(i in 0...n) {
			var p = alloc(lib.getTile("bigSmokeBlue"), e.xx+rnd(0,5,true), e.yy-e.hei*(i/n)+rnd(0,5,true));
			p.dr = rnd(0, 0.02);
			p.ds = rnd(0, 0.02);
			p.setScale( rnd(0.8, 1.5) );
			p.alpha = rnd(0.4, 0.7);
			p.rotation = rnd(0, 6.28);
			p.dx = rnd(0,4,true);
			p.dy = rnd(0,3,true);
			p.gy = -rnd(0.1, 0.2);
			p.frict = rnd(0.8, 0.9);
			p.life = rnd(20,30);
			p.fadeOutSpeed = rnd(0.03, 0.05);
		}

		for(i in 0...15) {
			var p = alloc(lib.getTile("blueDot"), e.xx+rnd(0,5,true), e.yy-rnd(20,e.hei-20));
			p.ds = rnd(0, 0.02);
			p.setScale( rnd(1, 3) );
			p.alpha = rnd(0.6, 1);
			p.moveAng(rnd(0,6.28), rnd(8,15));
			p.frict = rnd(0.8, 0.9);
			p.life = rnd(10,20);
			p.fadeOutSpeed = rnd(0.03, 0.05);
		}
	}


	public function bloodDots(x,y, ?r:b.Room) {
		var p = alloc(lib.getTileRandom("particleSlime"), x+rnd(0,20,true), y+rnd(0,20,true), false);
		p.scale( rnd(0.7, 1.5));
		p.alpha = rnd(0.5, 0.8);
		p.dx = rnd(0,6, true);
		p.dy = -rnd(5,10);
		p.frict = rnd(0.96, 0.98);
		p.rotation = rnd(0, 6.28);
		p.dr = rnd(0, 0.1, true);
		p.gy = rnd(0.6, 1.5);
		p.life = rnd(20, 40);

		if( r!=null ) {
			p.groundY = r.globalBottom;
			p.onBounce = function() {
				p.kill();
			}
		}
	}

	public function bloodExplosion(x,y, ?r:b.Room) {
		var p = alloc( lib.getTile("redCircle"), x,y );
		p.setScale(2);
		p.alpha = 1;
		p.ds = 0.4;
		p.life = 5;
		p.onUpdate = function() p.ds*=0.9;

		var p = alloc( lib.getTile("fxNovaRed"), x,y );
		p.setScale(2);
		p.alpha = 1;
		p.ds = 2;
		p.life = 5;
		p.onUpdate = function() p.ds*=0.8;


		for(i in 0...30) {
			var p = alloc(lib.getTileRandom("particleSlime"), x+rnd(0,20,true), y+rnd(0,20,true), false);
			p.setScale( rnd(2, 3) );
			p.alpha = rnd(0.5, 0.8);
			//p.moveAng(-rnd(0.5, 2.64), rnd(10, 20));
			p.dx = rnd(0,13, true);
			p.dy = -rnd(10,20);
			p.frict = rnd(0.96, 0.98);
			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.1, true);
			p.gy = rnd(0.6, 1.5);
			p.life = rnd(20, 40);
			if( r!=null ) {
				p.groundY = r.globalBottom;
				p.onBounce = function() {
					p.kill();
					//p.setPos(p.x, p.groundY);
					//p.dy = 0;
					//p.gy = 0;
					//p.tile = lib.getTile("moneySlime");
					//p.rotation = 0;
					//p.scale( rnd(0.3, 0.5));
					//p.scaleY*=0.4;
					//p.frict = rnd(0.7, 0.9);
					//p.dr = 0;
					//p.setCenter(0.5, 1);
				}
			}
		}
	}

	public function blender(x,y, r:b.Room) {
		for(i in 0...irnd(2,3)) {
			var p = alloc(lib.getTile("uiGuestLike"), x+rnd(0,20,true), y+rnd(0,20,true), false);
			p.scale( rnd(0.7, 1.5));
			p.fadeIn(rnd(0.5,0.8), 0.05);
			p.dx = rnd(7,23);
			p.dy = -rnd(0,15);
			p.frict = rnd(0.96, 0.98);
			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0.1, 0.2, true);
			p.gy = rnd(0.6, 1.5);
			p.life = rnd(20, 40);
			if( r!=null ) {
				p.onUpdate = function() {
					if( p.dx>0 && p.x>r.globalRight-r.padding )
						p.dx = -p.dx*0.5;
				}
				p.bounceMul = 0.5;
				p.groundY = r.globalBottom-r.padding;
			}
		}

		var p = alloc(lib.getTile("whiteSmoke"), x+rnd(0,20,true), y+rnd(0,15,true), false);
		p.scale( rnd(0.6, 1.5));
		p.fadeIn(rnd(0.3, 0.7), 0.1);
		p.dx = rnd(2, 5);
		p.dy = rnd(0,2,true);
		p.frict = rnd(0.96, 0.98);
		p.rotation = rnd(0, 6.28);
		p.dr = rnd(0, 0.03, true);
		p.life = rnd(20, 40);
		p.fadeOutSpeed = 0.02;
	}


	public function carSmoke(x,y) {
		for(i in 0...2) {
			var p = alloc(lib.getTile("bigSmokeBlue"), x+rnd(0,20,true), y+rnd(0,20,true));
			p.setScale( rnd(0.4,2) );
			p.alpha = rnd(0.4, 0.7);
			p.ds = 0.2;
			p.dx = rnd(0,3);
			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.05);
			p.gy = -rnd(0, 0.4);
			p.frict = 0.85;
			p.life = rnd(10, 30);
			p.fadeOutSpeed = 0.02;
			p.onUpdate = function() {
				p.ds*=0.92;
				p.dr*=0.85;
			}
		}
	}

	public function cleaningSmoke(x,y) {
		var p = alloc(lib.getTile("blueBigDot"), x+rnd(0,50,true), y+rnd(0,50,true));
		p.moveAwayFrom(x,y, rnd(0.5,1));
		p.fadeIn(rnd(0.4, 0.7), 0.1);
		p.scale( rnd(0.7, 2));
		p.life = rnd(10,30);
		p.fadeOutSpeed = 0.04;
		p.frict = 0.92;
		p.delay = 15;

		var p = alloc(lib.getTile("bigSmokeBlue"), x+rnd(0,20,true), y+rnd(0,20,true));
		p.fadeIn(rnd(0.06, 0.15), 0.1);
		p.scale( rnd(0.3, 0.8));
		p.ds = 0.1;
		p.dx = rnd(0,3);
		p.rotation = rnd(0, 6.28);
		p.dr = rnd(0, 0.05);
		p.gy = rnd(0, 0.4);
		p.frict = 0.85;
		p.life = rnd(10, 30);
		p.fadeOutSpeed = 0.02;
		p.onUpdate = function() {
			p.ds*=0.92;
			p.dr*=0.85;
		}
	}


	public function streetLight(x,y) {
		if( itime%10!=0 )
			return;

		var p = alloc(lib.getTile("blueSmoke"), x+rnd(0,80,true), y+rnd(0,5,true));
		p.setScale( rnd(4, 6) );
		p.fadeIn(rnd(0.08, 0.11), 0.005);
		p.dx = rnd(0.3, 0.6);
		p.dy = -rnd(0.2, 0.4);
		p.dr = rnd(0.003, 0.007);
		p.rotation = rnd(0, 6.28);
		p.fadeOutSpeed = 0.003;
		p.life = rnd(30, 50);
	}


	public function bubbles(k:String, x1:Float,y1:Float, x2:Float,y2:Float) {
		var p = alloc(lib.getTile(k), rnd(x1,x2), rnd(y1+15,y2));
		p.alpha = 0;
		p.da = 0.1;
		p.maxAlpha = rnd(0.3, 0.8);
		p.setScale( rnd(1,2) );
		p.gy = -0.2;
		p.frict = 0.9;
		p.bounds = new flash.geom.Rectangle(x1,y1, x2-x1, y2-y1);
		p.life = rnd(15,20);
	}


	public function sleeping(e:Entity) {
		if( itime%10==0 ) {
			var p = alloc(lib.getTile("fxSleep"), e.xx+rnd(0,e.wid*0.25,true), e.yy-e.hei*rnd(0.6, 0.8), false);
			p.alpha = 0;
			p.da = 0.1;
			p.maxAlpha = rnd(0.9, 1);
			p.setScale( rnd(1.5, 2.5) );
			p.gy = -rnd(0.2, 0.3);
			p.dx = rnd(0,2);
			p.frict = rnd(0.9, 0.95);
			p.life = rnd(15,20);
		}
		if( itime%15==0 ) {
			var p = alloc(lib.getTile("fxBubble"), e.xx+rnd(0,e.wid*0.25,true), e.yy-e.hei*rnd(0.6, 0.8));
			p.alpha = 0;
			p.da = 0.1;
			p.maxAlpha = rnd(0.6, 1);
			p.setScale( rnd(1, 2) );
			p.gy = -0.2;
			p.dx = rnd(0,1,true);
			p.frict = rnd(0.85, 0.90);
			p.life = rnd(15,20);
			p.ds = -0.02;
		}
	}


	public function wokeUp(e:Entity) {
		var p = alloc(lib.getTile("blueCircle"), e.centerX, e.yy-e.hei*0.75 );
		p.alpha = 0.6;
		p.setScale( 2.5 );
		p.ds = 0.6;
		p.life = 0;

		var n = 10;
		for(i in 0...n) {
			var a = 0.5 - 4.14 * i/(n-1);
			var p = alloc(lib.getTile("blueLine"), e.centerX+Math.cos(a)*10, e.yy-e.hei*0.75+Math.sin(a)*10 );
			p.rotation = a;
			p.moveAng(a, 20);
			p.frict = 0.8;
			p.scaleX = 1.5;
			p.ds = -0.04;
			//p.scaleY = 2;
			p.life = rnd(8,10);
		}
	}


	public function slimeDrops(x:Float, y:Float, groundY:Float) {
		var p = alloc(lib.getTile("moneySlime"), x, y+rnd(0,3), false);
		p.alpha = 0;
		p.da = 0.02;
		p.maxAlpha = rnd(0.6, 1);
		p.scale( rnd(0.2, 0.6));
		p.scaleY *= rnd(1.5, 2);
		p.rotation = rnd(0,0.2,true);
		p.gy = rnd(0.5, 1);
		p.frict = 0.98;
		p.life = rnd(35, 60);
		p.groundY = groundY-10;
		p.bounceMul = 0;
		p.onBounce = function() {
			p.rotation = 0;
			p.setPos(p.x, groundY);
			p.scaleX *= 2;
			p.scaleY *= 0.2;
			p.dy = 0;
			p.gy = 0;
			p.onBounce = null;
		}
	}



	public function equipmentAdded(x:Float, y:Float) {
		var p = alloc(lib.getTile("fxNovaYellow"), x, y);
		p.ds = 0.4;
		p.life = 0;
		p.fadeOutSpeed = 0.06;
		p.onUpdate = function() p.ds*=0.86;
	}

	public function giftAdded(x:Float, y:Float) {
		var p = alloc(lib.getTile("fxNovaYellow"), x, y);
		p.ds = 0.4;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.87;

		for(i in 0...16 ) {
			var p = alloc(lib.getTile("yellowDot"), x+rnd(0,20,true), y+rnd(0,20,true));
			p.setScale( rnd(1,4) );
			p.gy = -rnd(0.2, 0.5);
			p.delay = i*0.3;
			p.frict = rnd(0.78, 0.85);
			p.moveAng( rnd(0, 6.28), rnd(10,20) );
			p.life = rnd(20,40);
		}
	}

	public function giftRemoved(x:Float, y:Float) {
		var p = alloc(lib.getTile("fxNovaBlue"), x, y);
		p.ds = 0.4;
		p.life = 0;
		p.onUpdate = function() p.ds*=0.87;

		for(i in 0...16 ) {
			var p = alloc(lib.getTile("blueBigDot"), x+rnd(0,20,true), y+rnd(0,20,true));
			p.setScale( rnd(1,4) );
			p.gy = -rnd(0.2, 0.5);
			p.delay = i*0.3;
			p.frict = rnd(0.78, 0.85);
			p.moveAng( rnd(0, 6.28), rnd(10,20) );
			p.life = rnd(20,40);
		}
	}


	public function bombWarning(e:Entity) {
		var p = alloc(lib.getTile("fxNovaRed"), e.centerX, e.centerY);
		p.scale( 2);
		p.ds = 0.2;
		p.life = 0;
		p.fadeOutSpeed = 0.05;
		p.onUpdate = function() p.ds*=0.9;

		for(i in 0...8 ) {
			var p = alloc(lib.getTile("yellowDot"), e.centerX+rnd(3,10,true), e.centerY-rnd(50,60));
			p.scale( rnd(1,3));
			p.gy = rnd(0.1, 0.3);
			p.frict = rnd(0.93, 0.98);
			p.moveAng(rnd(0,6.28), rnd(5, 20));
			p.delay = i*0.5;
			p.life = rnd(10,20);
			//p.rotation = p.getMoveAng();
			//p.onUpdate = function() {
				//p.rotation = p.getMoveAng();
			//}
		}
	}


	public function cancelFeedback(x:Float,y:Float) {
		var p = alloc(lib.getTile("fxNovaRed"), x,y);
		p.setScale(4);
		p.ds = 0.2;
		p.life = 0;
		p.fadeOutSpeed = 0.05;
		p.onUpdate = function() p.ds*=0.9;

		for(i in 0...30 ) {
			var p = alloc(lib.getTile("redDot"), x+rnd(3,30,true), y+rnd(3,30,true));
			p.setScale( rnd(1,4) );
			//p.gy = -rnd(0.1, 0.3);
			p.frict = rnd(0.90, 0.95);
			p.moveAwayFrom( x,y, rnd(2,6) );
			p.life = rnd(10,20);
		}
	}

	public function roomButtonFeedback(x:Float,y:Float) {
		var p = alloc(lib.getTile("fxNovaYellow"), x,y);
		p.setScale( 2 );
		p.ds = 0.6;
		p.life = 0;
		p.fadeOutSpeed = 0.07;
		p.onUpdate = function() p.ds*=0.9;
	}


	public function tutoArrowMarker(getX:Void->Null<Float>, getY:Void->Null<Float>, ?scale=1.0) {
		if( scale<=0 )
			return;

		var p = alloc( lib.getTile("fxNovaBlue"), getX(), getY() );
		p.setScale(scale*0.9);
		p.ds = 0.03;
		p.onUpdate = function() {
			if( getX()==null )
				p.kill();
			else
				p.setPos(getX(), getY());
		}
		p.life = 0;
	}

	public function tutoRefocus(getX:Void->Float, getY:Void->Float) {
		var x = getX();
		var y = getY();
		var s = 0.1;
		var f = 0.;
		var p = alloc(lib.getTile("tutoArrow"), 0,0);
		p.fadeIn(1, 0.3);
		p.setScale(1.1);
		p.life = 28;
		p.rotation = 1.7 + rnd(0,0.3,true);

		function _reposition() {
			x = getX();
			y = getY();
			var a = p.rotation;
			var d = MLib.fabs(Math.sin(f)*40);
			p.setPos(x-Math.cos(a)*(d+70), y-Math.sin(a)*(d+70));
			f+=0.21;
		}
		p.onUpdate = _reposition;
		_reposition();
	}


	public function ping(x:Float, y:Float, k:String, ?scale=1.0, ?spd=1.0) {
		var p = alloc(lib.getTile(k), x,y);
		p.alpha = 0.4;
		p.scale(0.7*scale);
		p.ds = 0.5*scale*spd;
		p.life = 16/spd;
		p.fadeOutSpeed = 0.03*spd;
		p.onUpdate = function() {
			p.ds*=0.85;
		}
	}


	public function shineSquare(k:String, x:Float, y:Float, w:Float, h:Float, fs:Float) {
		var p = alloc(lib.getTile(k), x+rnd(0,w), y+rnd(0,h));
		p.setScale(rnd(0.4,0.9)*fs);
		p.fadeIn(rnd(0.5,1), 0.09);
		p.life = rnd(4,9);
		p.frict = 0.93;
		p.dr = rnd(0.05,0.10, true);
		p.rotation = rnd(0,6.28);
		p.fadeOutSpeed = 0.04;
		return p;
	}

	public function tapDrag(x:Float, y:Float) {
		var p = alloc(lib.getTile("fxNovaBlue"), x,y);
		p.scale(2);
		p.ds = -0.09;
		p.life = 5;
		p.onUpdate = function() {
			if( Game.ME!=null && Game.ME.isDraggingClient() )
				p.kill();
		}
	}


	public function dragDust(ang:Float, x:Float,y:Float) {
		var p = alloc(lib.getTile("blueLine"), x+rnd(0,5,true), y+rnd(0,5,true));
		p.scaleX = rnd(0.6, 0.8);
		p.scaleY = rnd(1.4, 1.6);
		p.dx = rnd(0, 0.3, true);
		p.dy = rnd(0, 0.3, true);
		//p.gx = rnd(0, 0.1, true);
		//p.gy = rnd(0, 0.1, true);
		p.rotation = ang;
		p.life = rnd(4,8);
		p.frict = 0.85;
		//p.fadeOutSpeed = 0.04;
	}


	public function clientDragStarted(e:en.Client) {
		var p = alloc(lib.getTile("fxNovaBlue"), e.centerX, e.centerY);
		p.scale( 3);
		p.ds = 0.2;
		p.life = 0;
		p.fadeOutSpeed = 0.05;
		p.onUpdate = function() p.ds*=0.9;
	}

	public function love(e:Entity) {
		var p = alloc(lib.getTile("fxNovaRed"), e.centerX, e.centerY);
		p.ds = 0.8;
		p.life = 0;

		for(i in 0...6) {
			var p = alloc(lib.getTile("moneyLove"), e.centerX+rnd(0,10,true), e.centerY+rnd(0,10,true));
			p.setScale( rnd(0.6, 1.5) );
			p.rotation = rnd(0,0.2,true);
			p.moveAwayFrom(e.centerX, e.centerY, rnd(8,15));
			p.gx = rnd(0,0.3,true);
			p.gy = rnd(0,0.3,true);
			p.frict = rnd(0.90, 0.94);
			p.life = rnd(20, 50);
		}
	}


	public function equipmentDestroyed(x:Float, y:Float) {
		var p = alloc(lib.getTile("fxNovaRed"), x, y);
		p.ds = 0.2;
		p.life = 0;
		p.fadeOutSpeed = 0.07;
		p.onUpdate = function() p.ds*=0.86;

		for(i in 0...10 ) {
			var p = alloc(lib.getTile("redDot"), x+rnd(0,10,true), y+rnd(0,10,true));
			p.scale( rnd(1,4));
			p.gy = -rnd(0.1, 0.3);
			p.frict = rnd(0.8, 0.95);
			p.moveAwayFrom( x,y, rnd(2,6) );
			p.life = rnd(10,20);
		}
	}


	public function mainStatusCounter(col:String, x:Float, y:Float, w:Float, h:Float) {
		for(i in 0...20) {
			var p = alloc(lib.getTile(col+"BigDot"), x+rnd(0,w), y+rnd(0,h));
			p.scale( rnd(2, 4));
			p.fadeIn(1, 0.2);
			p.dx = rnd(0,1,true);
			p.dy = rnd(0,1,true);
			p.frict = rnd(0.9, 0.98);
			p.delay = i;
		}
	}


	public function godLight(r:Room, dir:Int) {
		var x = rnd(0,10,true) + (dir==1 ? r.globalLeft-20 : r.globalRight+20);
		var y = r.globalCenterY+rnd(0,30);
		//var h = rnd(0,1);

		var p = alloc(lib.getTile("godLight"), x, y);
		p.setCenterRatio(0, 0.5);
		p.rotation = dir==1? 1.57*0.3 : 3.14-1.57*0.3;
		p.scaleX = rnd(0.6, 0.8);
		p.scaleY = rnd(1, 2);
		p.fadeIn(rnd(0.25,0.35), 0.01);
		p.fadeOutSpeed = 0.01;
		p.life = rnd(30,50);
	}

	public function newStarBefore(x:Float, y:Float) {
		for(i in 0...90) {
			var a = rnd(0,6.28);
			var d = rnd(600,900);
			var p = alloc(lib.getTileRandom("yellowBigDot"), x+Const.ROOM_WID*0.5+Math.cos(a)*d, y+Math.sin(a)*d*0.33);
			p.moveTo(x+Const.ROOM_WID*0.5, y, rnd(30,37));
			p.fadeIn(rnd(0.5, 0.9), rnd(0.05, 0.15));
			p.setScale(rnd(2,5));
			p.frict = rnd(0.92,0.96);
			p.delay = i*0.25 + irnd(0,3);
			p.life = rnd(40,50);
			p.scaleMul = rnd(0.93,0.99);
		}
	}

	public function newStar(x:Float, y:Float) {
		var n = 20;
		for( dir in [-1,1] )
			for( i in 0...n ) {
				var r = i/n;
				var p = alloc( lib.getTileRandom("nameGlow"), x + Const.ROOM_WID*0.5 + (dir*r*0.5*Const.ROOM_WID), y+rnd(0,20,true) );
				p.setScale(rnd(1.5,2.5));
				p.fadeIn(1, 0.15);
				p.dx = rnd(0,2,true);
				p.dy = rnd(1,3,true);
				p.frict = 0.95;
				p.delay = i*0.6;
				p.life = rnd(20,40);
				p.onUpdate = function() {
					p.scale(0.95);
				}
			}

		for(i in 0...80) {
			var p = alloc(lib.getTileRandom("partyFx"), x+rnd(0,Const.ROOM_WID),y);
			p.moveAwayFrom(x+Const.ROOM_WID*0.5, y+150, rnd(5,15));
			p.frict = rnd(0.95,0.98);
			p.gy = rnd(0,0.4);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.05,true);
			var s = rnd(0.5, 1.5);
			p.delay = i*0.3 + irnd(0,3);
			p.setScale(s);
			p.life = rnd(50,100);
			var t = rnd(0,100);
			p.onUpdate = function() {
				p.scaleX = Math.cos(t*0.2)*s;
				t++;
			}
		}
	}


	public function titleExplosion(x:Float, y:Float, fs:Float) {
		var p = alloc( lib.getTile("nameGlow",2), x, y );
		p.setScale(6);
		p.scaleY = 0.6*p.scaleX;
		p.alpha = 0.6;
		p.life = 10;
		p.scaleMul = 0.98;
		p.fadeOutSpeed = 0.06;

		for(i in 0...120) {
			var p = alloc(lib.getTileRandom("partyFx"), x+rnd(0,150,true), y+rnd(0,50,true));
			p.moveAwayFrom(x, y+30, rnd(5,35)*fs);
			p.frict = rnd(0.95,0.98);
			p.gy = rnd(0.02,0.18)*fs;
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.05,true);
			var s = rnd(0.35, 0.6)*fs;
			p.delay = irnd(0,5);
			p.setScale(s);
			p.life = rnd(130,220);
			var t = rnd(0,100);
			p.onUpdate = function() {
				p.scaleX = Math.cos(t*0.2)*s;
				t++;
			}
		}
	}


	var shineX = 0.;
	public function updateTitleShineX() {
		shineX += 0.016;
		if( shineX>=1.1 )
			shineX = -0.2;
		if( shineX>1 )
			return;
	}

	public function titleDust(fs:Float) {
		var p = alloc(lib.getTile("yellowBigDot"), w()*rnd(0.1,0.9), h()*rnd(0.1,0.8));
		p.setScale(rnd(0.7,2)*fs);
		p.fadeIn(rnd(0.1, 0.3), 0.05);
		p.dx = -rnd(0,3);
		p.dy = rnd(0,3,true);
		p.gx = -rnd(0.1,0.2);
		p.gy = rnd(0, 0.1, true);
		p.frict = 0.9;
		p.fadeOutSpeed = 0.01;
		p.life = rnd(20,60);
	}


	public function titleShine(bx:Float, by:Float, w:Float, h:Float, fs:Float, bd:flash.display.BitmapData) {
		fs*=2;
		var dx = 0.;
		var dy = 0.;
		var tries = 50;
		do {
			dx = w*shineX + rnd(0,5,true);
			dy = rnd(0,h);
		} while( tries-->0 && Color.getAlpha( bd.getPixel32( Std.int(bd.width*dx/w), Std.int(bd.height*dy/h) ) )<0xff );
		if( tries<=0 )
			return;

		dy-=5;

		// Red glow
		var p = alloc(lib.getTile("nameGlow",0), bx-w*0.5+dx, by-h*0.5+dy);
		p.setScale(rnd(1,2)*fs);
		p.fadeIn(rnd(0.03,0.06), 0.01);
		p.fadeOutSpeed = 0.01;
		p.ds = -0.01;
		p.dx = 0.4;
		p.frict = 0.93;
		p.life = rnd(20,60);

		// Blue glow
		var p = alloc(lib.getTile("nameGlow",1), bx-w*0.5+dx, by-h*0.5+dy);
		p.setScale(rnd(0.4,0.6)*fs);
		p.fadeIn(rnd(0.08,0.16), 0.01);
		p.fadeOutSpeed = 0.01;
		p.ds = -0.01;
		p.dx = 0.2;
		p.frict = 0.93;
		p.life = rnd(20,60);

		var p = alloc(lib.getTile("yellowShine"), bx - w*0.5 + dx, by - h*0.5 + dy );
		//var p = alloc(lib.getTile("yellowShine"), bx - w*0.5 + dx, by - h*0.5 + dy );
		p.fadeIn( rnd(0.7,1), rnd(0.05,0.10) );
		//p.rotation = -0.9 + rnd(0,0.2,true);
		p.dr = rnd(0.10, 0.15);
		p.setScale(rnd(0.7,1.2)*fs);
		//p.setScale( rnd(0.3,1) );
		//p.ds = -rnd(0.01, 0.03);
		p.scaleMul = rnd(0.85, 0.95);
		p.rotation = rnd(0, 6.28);
		p.frict = rnd(0.97, 0.99);
		p.fadeOutSpeed = 0.06;
		p.life = rnd(4, 10);
		//p.onUpdate = function() {
			//if( p.dr<0.45 )
				//p.dr+=0.03;
		//}
	}

	public function teleportOut(x,y) {
		for(i in 0...40) {
			var p = alloc(lib.getTile("blueShine"), x+rnd(0,20,true), y+rnd(0,50,true));
			p.rotation = rnd(0,6.28);
			p.scale(rnd(1,2));
			p.moveAwayFrom(x,y, rnd(5,13));
			p.fadeIn(1, rnd(0.1,0.2));
			p.delay = irnd(0,4);
			p.gx = rnd(0.3, 1);
			p.dr = rnd(0,0.2,true);
			p.ds = -rnd(0.02, 0.05);
			p.frict = rnd(0.9,0.97);
			p.life = i*0.5 + rnd(20,30);
		}
		for(i in 0...20) {
			var p = alloc(lib.getTileRandom("lightningLine"), x+rnd(0,30,true), y+rnd(0,30,true));
			p.rotation = rnd(0,6.28);
			p.scale(rnd(1.5,3));
			p.moveAwayFrom(x,y, rnd(0,2));
			p.fadeIn(rnd(0.5,1), rnd(0.1,0.2));
			//p.dr = rnd(1,2,true);
			p.delay = irnd(0,6);
			p.gx = rnd(0.2, 0.4);
			p.ds = -rnd(0.04, 0.08);
			p.frict = rnd(0.9,0.97);
			p.life = i*0.5 + rnd(20,30);
		}
	}


	public function questBought() {
		var n = 30;
		for(i in 0...n) {
			var p = alloc( lib.getTile("nameGlow",1), -rnd(20,50), h()*0.55 - h()*0.3 + h()*0.6*i/n + rnd(0,30,true));
			p.alpha = rnd(0.6,1);
			p.setScale(rnd(0.5,1.3));
			p.dx = rnd(0,20);
			p.dy = rnd(0,2,true);
			p.frict = rnd(0.9, 0.96);
			p.life = rnd(40,60);
		}
		var n = 50;
		for(i in 0...n) {
			var p = alloc( lib.getTile("blueBigDot"), -rnd(0,40), h()*0.55 - h()*0.2 + h()*0.4*i/n + rnd(0,30,true));
			p.setScale(rnd(1,1.5));
			p.dx = rnd(20,50);
			p.dy = rnd(0,2,true);
			p.frict = rnd(0.9, 0.96);
			p.life = rnd(40,60);
		}

		var m = ui.side.Quests.CURRENT;
		if( m.isOpen ) {
			var p = alloc(lib.getTile("moneyGem"), m.wid*m.wrapper.scaleX*0.5, h()*0.5);
			p.setScale(2.5);
			p.ds = 0.5;
			p.onUpdate = function() p.ds*=0.9;
			p.life = 20;
		}
	}

	public function newDaySparks(x,y, fs:Float) {
		var a = rnd(0,6.28);
		var p = alloc(lib.getTile("dailySpark"), x+Math.cos(a)*rnd(30,70)*fs, y+Math.sin(a)*rnd(30,70)*fs);
		p.setScale(rnd(0.3,0.5)*fs);
		p.fadeIn( rnd(0.8, 1), 0.04 );
		p.life = rnd(20,40);
		p.moveAng(a+rnd(1.5,1.6,true), rnd(1,3));
		p.frict = 0.94;
		p.ds = -0.007;
		p.rotation = rnd(0,6.28);
		p.dr = rnd(0.1,0.3,true);
		p.fadeOutSpeed = 0.03;
	}

	public function newDayShine(x,y, fs:Float) {
		var p = alloc( lib.getTile("fxSunshine"), x,y );
		p.setScale(2*fs);
		p.rotation = rnd(0,6.28);
		p.fadeIn( 0.3, 0.03 );
		p.scaleMul = 0.99;
		p.dr = rnd(0.010, 0.015);
		p.life = 15;
		p.fadeOutSpeed = 0.01;
	}

	public function newDayMarker(x,y, fs:Float) {
		var p = alloc( lib.getTile("fxSunshine"), x,y );
		p.setScale(0.1);
		p.alpha = 0.5;
		p.ds = 0.6;
		p.dr = 0.03;
		p.life = 15;
		p.fadeOutSpeed = 0.03;
		p.onUpdate = function() p.ds*=0.9;

		var p = alloc( lib.getTile("fxSunshine"), x,y );
		p.setScale(0.1);
		p.alpha = 0.5;
		p.ds = 0.6;
		p.dr = -0.01;
		p.life = 15;
		p.fadeOutSpeed = 0.03;
		p.onUpdate = function() p.ds*=0.8;


		for(i in 0...60) {
			var p = alloc(lib.getTileRandom("partyFx"), x+rnd(0,20,true), y+rnd(0,20,true), false);
			var s = rnd(0.5,1.5)*fs;
			p.setScale(s);
			var t = rnd(0,100);
			p.onUpdate = function() {
				p.scaleX = Math.cos(t*0.2)*s;
				t++;
			}
			p.alpha = rnd(0.5, 0.8);
			p.moveAng(rnd(0,6.28), rnd(10,20)*fs);
			p.dy -= 5*fs;
			p.frict = rnd(0.96, 0.98);
			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.05, true);
			p.gy = rnd(0.2, 0.6)*fs;
			p.life = rnd(40, 60);
		}
	}

	public function snow() {
		for(i in 0...irnd(1,2)) {
			// Snow flake
			var maxGx = rnd(0.1, 0.6);
			var gxSpd = rnd(0.04, 0.08);
			var vp = Game.ME.viewport;
			var x = vp.x + rnd(-vp.wid*0.7, vp.wid*0.4);
			var y = vp.y + rnd(-vp.hei*0.7, vp.hei*0.4);
			var p = alloc(lib.getRandomTile("snow"), x,y, false);
			p.fadeIn(1, 0.02);
			p.fadeOutSpeed = 0.015;
			p.rotation = rnd(0,6.28);
			p.gy = rnd(0.2, 0.5);
			p.life = rnd(20,70);
			p.dr = rnd(0, 0.06, true);
			p.frict = 0.92;

			var s = rnd(0.4, 1.5);
			p.setScale(s);
			var t = rnd(0,100);
			p.onUpdate = function() {
				if( itime%3==0 && Game.ME.sceneToRoomY(p.y)<0 || Game.ME.shotel.hasRoomExceptFiller(Game.ME.sceneToRoomX(p.x), Game.ME.sceneToRoomY(p.y)) ) {
					p.fadeOutSpeed = 0.04;
					p.life = 0;
				}
				p.gx = 0.3 + Math.cos(t*gxSpd)*maxGx;
				p.scaleX = Math.cos(t*0.06)*s;
				if( p.y>=0 ) {
					p.fadeOutSpeed = 0.05;
					p.life = 0;
				}
				t++;
			}
		}

		// Snow dots
		//var gxSpd = rnd(0.04, 0.08);
		//var vp = Game.ME.viewport;
		//var x = vp.x + rnd(-vp.wid*0.6, vp.wid*0.4);
		//var y = vp.y + rnd(-vp.hei*0.7, vp.hei*0.3);
		//var p = alloc(lib.getRandomTile("snowDots"), x,y, true);
		//p.setScale( rnd(3, 6) );
		//p.fadeIn(rnd(0.1, 0.4), 0.01);
		//p.fadeOutSpeed = 0.010;
		//p.rotation = rnd(0,6.28);
		//p.gx = rnd(0.1, 0.4);
		//p.gy = rnd(0.3, 0.9);
		//p.frict = 0.92;
		//p.life = rnd(20,70);
		//p.onUpdate = function() {
			//if( Game.ME.sceneToRoomY(p.y)<0 || Game.ME.shotel.hasRoomExceptFiller(Game.ME.sceneToRoomX(p.x), Game.ME.sceneToRoomY(p.y)) ) {
				//p.fadeOutSpeed = 0.06;
				//p.life = 0;
			//}
		//}
	}

	public function autumnLeaves() {
		for(i in 0...irnd(1,2)) {
			// Snow flake
			var maxGx = rnd(0.1, 0.6);
			var gxSpd = rnd(0.04, 0.08);
			var vp = Game.ME.viewport;
			var x = vp.x + rnd(-vp.wid*0.7, vp.wid*0.4);
			var y = vp.y + rnd(-vp.hei*0.7, vp.hei*0.4);
			var p = alloc(lib.getRandomTile("leaf"), x,y, false);
			p.fadeIn(1, 0.03);
			p.fadeOutSpeed = 0.015;
			p.rotation = rnd(0,6.28);
			p.gy = rnd(0.2, 0.5);
			p.life = rnd(20,70);
			p.dr = rnd(0, 0.06, true);
			p.frict = 0.92;

			var s = rnd(0.6, 0.9);
			p.setScale(s);
			var t = rnd(0,100);
			p.onUpdate = function() {
				if( itime%3==0 && Game.ME.sceneToRoomY(p.y)<0 || Game.ME.shotel.hasRoomExceptFiller(Game.ME.sceneToRoomX(p.x), Game.ME.sceneToRoomY(p.y)) ) {
					p.fadeOutSpeed = 0.04;
					p.life = 0;
				}
				p.gx = 0.3 + Math.cos(t*gxSpd)*maxGx;
				p.scaleX = Math.cos(t*0.06)*s;
				if( p.y>=0 ) {
					p.fadeOutSpeed = 0.05;
					p.life = 0;
				}
				t++;
			}
		}
	}


	public function rate(x,y, fs:Float) {
		var p = alloc(lib.getTileRandom("rateStarOn"), x,y);
		p.ds = 0.03;
		p.life = 1;
		for(i in 0...30) {
			var p = alloc(lib.getTileRandom("partyFx"), x+rnd(0,20,true), y+rnd(0,20,true), true);
			var s = rnd(0.3,0.8)*fs;
			p.setScale(s);
			var t = rnd(0,100);
			p.onUpdate = function() {
				p.scaleX = Math.cos(t*0.2)*s;
				t++;
			}
			p.alpha = rnd(0.5, 0.8);
			p.moveAng(rnd(0,6.28), rnd(10,20)*fs);
			p.dy -= 5*fs;
			p.frict = rnd(0.96, 0.98);
			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.05, true);
			p.gy = rnd(0.2, 0.6)*fs;
			p.life = rnd(20, 40);
		}
	}

	public function saw(r:Room, x:Float, y:Float) {
		if( itime%5==0 ) {
			var p = alloc(lib.getTile("nameGlow",3), x+rnd(0,10,true),y-40+rnd(0,10,true));
			p.scale( rnd(3,5) );
			p.life = 10;
			p.fadeIn(rnd(0.1, 0.3), 0.1);
			p.fadeOutSpeed = 0.02;
		}

		var p = alloc(lib.getTile(Std.random(2)==0?"yellowShineLight":"redShine"), x+rnd(0,12,true),y+rnd(0,5,true));
		p.scale(rnd(0.7, 2));
		p.dx = -rnd(1,3);
		p.dy = rnd(1, 1.5, true);
		p.frict = 0.96;
		p.rotation = rnd(0,6.28);
		p.dr = rnd(0, 0.1, true);
		p.life = rnd(10,20);

		var p = alloc(lib.getTile("yellowLine"), x+rnd(0,12,true),y+rnd(0,5,true));
		p.dx = -rnd(8,20);
		p.dy = -rnd(2,25);
		p.frict = 0.97;
		p.gy = rnd(0.8, 1);
		p.groundY = r.globalBottom - r.padding;
		p.bounceMul = 0.8;
		p.onUpdate = function() {
			if( p.dx<0 && p.x<=r.globalLeft+r.padding )
				p.dx*=-1;
			p.rotation = p.getMoveAng();
		}
		p.onBounce = function() {
			p.scaleX *= 0.5;
		}
		p.life = rnd(20,60);
		p.onUpdate();
	}

	public function stockAdded(x:Float, y:Float) {
		var n = 20;
		for(i in 0...n)  {
			var p = alloc( lib.getTile("pinkBigDot"), x,y );
			p.scale( rnd(2,4) );
			p.moveAng( 6.28*i/n+rnd(0,0.2,true), rnd(4,12) );
			p.frict = 0.92;
		}
	}


	override function update() {
		super.update();

		var rendering = true;

		for(p in apool)
			p.update(rendering);

		for(p in npool)
			p.update(rendering);
	}
}

