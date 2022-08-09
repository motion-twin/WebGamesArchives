import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Lib;
import mt.deepnight.retro.SpriteLibBitmap;
import mt.deepnight.Color;

import Const;
import en.Mob;

class Entity {
	public static var BASE_SPEED = api.AKApi.const(8);
	public static var ALL : Array<Entity> = new Array();
	public static var SELECTABLES : Array<Entity> = new Array();
	static var UNIQ = 0;
	
	var hero			: en.Hero;
	var game			: mode.Play;
	var fx				: Fx;
	//var level			: Level;
	var rseed			: mt.Rand;
	public var uid		: Int;
	public var side		: Int; // 0==ally, 1==enemy
	public var cd		: mt.deepnight.Cooldown;
	var perf			: Float;
	
	var sightCache		: IntHash<Bool>;
	var advancedSightCollisions	: Bool;
	
	public var cx		: Int;
	public var cy		: Int;
	public var xr		: Float;
	public var yr		: Float;
	public var xx		: Float;
	public var yy		: Float;
	public var zz		: Float;
	public var roomId	: Int;
	
	public var zpriority: Int;
	
	public var radius(default,setRadius)	: Float;
	public var weight	: Float;
	
	public var life		: Int;
	public var maxLife	: Int;
	
	public var dx		: Float;
	public var dy		: Float;
	public var dz		: Float;
	public var frict	: Float;
	public var realFrict: Float;
	public var path		: Array<{cx:Int, cy:Int, xr:Float, yr:Float}>;
	var lastPathTarget	: Null<{cx:Int, cy:Int}>;
	var motivation		: Int;
	public var maxPathLen: Int;
	public var speed	: Float;
	public var wallBounce: Float;
	
	public var sprite	: BSprite;
	public var shadow	: Null<Sprite>;
	public var lookDir	: Int;
	#if debug
	public var hitZone	: Sprite;
	#end
	var lifeBar			: Bitmap;
	var barOffsetX		: Int;
	var barOffsetY		: Int;
	var barSize			: Int;
	var showBar			: Bool;
	
	public var collides		: Bool;
	public var killed		: Bool;
	public var onScreen		: Bool;
	public var zsortable	: Bool;
	public var selectable(default,setSelectable)	: Bool;
	
	public function new() {
		uid = UNIQ++;
		side = -1;
		game = mode.Play.ME;
		fx = game.fx;
		roomId = -1;
		initSeed(0);
		cd = new mt.deepnight.Cooldown();
		path = new Array();
		sightCache = new IntHash();
		advancedSightCollisions = false;
		
		zpriority = 0;
		wallBounce = 0.7;
		collides = true;
		showBar = false;
		selectable = false;
		lookDir = 1;
		weight = 1;
		motivation = 0;
		setSpeed(1);
		maxPathLen = 23;
		cx = cy = 5;
		zz = 0;
		xr = yr = 0.5;
		dx = dy = dz = 0;
		frict = 0.4;
		killed = false;
		barOffsetX = 0;
		barOffsetY = -26;
		barSize = 12;
		radius = 10;
		zsortable = true;
		
		sprite = new BSprite(game.char);
		sprite.setCenter(0.5, 1);

		lifeBar = new Bitmap(null, flash.display.PixelSnapping.NEVER, false);
		game.sdm.add(lifeBar, Const.DP_BAR);
		initLife(1);
		
		register();
		hero = game.hero;
	}
	
	function setSelectable(b) {
		if( b && !selectable )
			SELECTABLES.push(this);
		if( !b && selectable )
			SELECTABLES.remove(this);
		selectable = b;
		return b;
	}
	
	public function isOver(x:Float,y:Float) {
		return x>=xx-10 && x<xx+10 && y>=yy-20 && y<=yy;
	}
	
	public function canBeHit() {
		return true;
	}
	
	public function setRadius(v) {
		radius = v;
		#if debug
		if( hitZone!=null )
			hitZone.parent.removeChild(hitZone);
		hitZone = new Sprite();
		game.sdm.add(hitZone, Const.DP_BG_FX);
		//hitZone.graphics.lineStyle(1, 0xFF00FF, 0.4);
		//hitZone.graphics.beginFill(0xFF00FF, 0.2);
		//hitZone.graphics.drawCircle(0,0, radius);
		#end
		return v;
	}
	
	public inline function isNeutral() {
		return side==-1;
	}
	public inline function isAlly() {
		return side==0;
	}
	public inline function isEnemy() {
		return side==1;
	}
	
	public inline function rnd(min,max,?sign) { return rseed.range(min,max,sign); }
	public inline function irnd(min,max,?sign) { return rseed.irange(min,max,sign); }
	
	public function setShadow(b:Bool) {
		if( shadow!=null ) {
			shadow.parent.removeChild(shadow);
			shadow = null;
		}
		if( b && !api.AKApi.isLowQuality() ) {
			shadow = new Sprite();
			game.sdm.add(shadow, Const.DP_BG_FX);
			shadow.graphics.beginFill(0x0, 0.4);
			shadow.graphics.drawEllipse(-7,-4, 14,8);
			shadow.x = sprite.x;
			shadow.y = sprite.y;
		}
	}
	
	public function play3dSound(sfx:mt.deepnight.Sfx, ?vol=1.0) {
		var d = distance(game.hero);
		if( !Math.isNaN(d) )
			sfx.play( vol * Math.max(0, 1-Math.max(0,d-150)/250), (xx-hero.xx)/350 );
	}
	
	public function setSpeed(sfactor:Float) {
		speed = sfactor * BASE_SPEED.get()/100;
	}
	
	public function initLife(l:Int) {
		if( lifeBar.bitmapData!=null )
			lifeBar.bitmapData.dispose();
			
		lifeBar.bitmapData = new BitmapData(barSize,4, true, 0x0);
		life = maxLife = l;
		updateLife();
	}
	
	public inline function updateLife() {
		if( showBar ) {
			var w = Math.min(barSize-2, maxLife*2);
			var r = Math.min(1,life/maxLife);
			var c1 = r<=0.34 ? 0xFF6600 : (r<=0.6 ? 0xFFFF00 : 0xACFF00);
			var c2 = r<=0.34 ? 0xCC1F06 : (r<=0.6 ? 0xFEBF01 : 0x91D700);
			lifeBar.bitmapData.fillRect( new flash.geom.Rectangle(0,0, w+2,4), Color.addAlphaF(0, 0.5) );
			lifeBar.bitmapData.fillRect( new flash.geom.Rectangle(1,1,w*r,1), Color.addAlphaF(c1) );
			lifeBar.bitmapData.fillRect( new flash.geom.Rectangle(1,2,w*r,1), Color.addAlphaF(c2) );
		}
	}
	
	public function slowDown(d) {
		if( !cd.has("slow") ) {
			dx*=0.3;
			dy*=0.3;
		}
		cd.set("slow", d, false);
	}
	
	function popDamage(d:Int) {
		fx.pop(xx,yy, d, 0xFFFF00);
	}
	
	public function hit(d:Int) {
		if( cd.has("shield") || d<=0 )
			return;
			
		if( cd.has("weakness") )
			d+=1;
			
		life-=d;
		popDamage(d);
		fx.blink(this);
		if( life<=0 ) {
			life = 0;
			onDie();
		}
		updateLife();
	}
	
	public inline function stun(d) {
		cd.set("stun",d);
		dx = dy = 0;
	}
	
	function splat() {
	}
	
	public function onDie() {
		splat();
		destroy();
	}
	
	public inline function updateFromScreenCoords() {
		cx = Std.int(xx/Const.GRID);
		xr = (xx - cx*Const.GRID) / Const.GRID;
		cy = Std.int(yy/Const.GRID);
		yr = (yy - cy*Const.GRID) / Const.GRID;
	}
	
	public inline function updateScreenCoords() {
		xr = Std.int(xr*1000)/1000;
		yr = Std.int(yr*1000)/1000;
		xx = Const.GRID*(cx+xr);
		yy = Const.GRID*(cy+yr);
	}
	
	public inline function initSeed(?n=0) {
		rseed = new mt.Rand(0);
		rseed.initSeed(uid + game.seed + n*42);
	}
	
	public function destroy() {
		if( killed )
			return;
		killed = true;
		game.killList.push(this);
	}
	
	public inline function getCollision(x,y) {
		return game.currentLevel.getCollision(x,y);
	}
	
	public inline function getSightCollision(x,y) {
		return advancedSightCollisions ? game.currentLevel.getSightCollision(x,y) : getCollision(x,y);
	}
	
	public function register() {
		game.sdm.add(sprite, Const.DP_ENTITY);
		ALL.push(this);
	}
	
	public function detach() {
		sprite.parent.removeChild(sprite);
		sprite.destroy();
		if( shadow!=null )
			shadow.parent.removeChild(shadow);
		#if debug
		hitZone.parent.removeChild(hitZone);
		#end
		lifeBar.parent.removeChild(lifeBar);
		lifeBar.bitmapData.dispose();
		ALL.remove(this);
		if( selectable )
			SELECTABLES.remove(this);
	}
	
	public inline function sightCheck(e:Entity) {
		if( sightCache.exists(10000+e.uid) )
			return sightCache.get(10000+e.uid);
		else {
			var r = Lib.bresenhamCheck(cx,cy, e.cx, e.cy, function(x,y) return !getSightCollision(x,y));
			sightCache.set(10000+e.uid, r);
			e.sightCache.set(10000+uid, r);
			return r;
		}
	}
	
	public inline function sightCheckCoord(tcx:Int, tcy:Int) {
		var id = tcx+tcy*game.currentLevel.wid;
		if( sightCache.exists(id) )
			return sightCache.get(id);
		else {
			var r = Lib.bresenhamCheck(cx,cy, tcx, tcy, function(x,y) return !getSightCollision(x,y));
			sightCache.set(id, r);
			return r;
		}
	}
	
	public inline function isOnScreen() {
		return game.viewPortCase.contains(cx,cy);
	}
	
	public function getMassTarget(range:Int) : {x:Float, y:Float} {
		var masses = new IntHash();
		var w = game.currentLevel.wid;
		
		function incSpot(x:Int,y:Int, v:Float) {
			if( !masses.exists(x+y*w) )
				masses.set( x+y*w, {x:x, y:y, v:v} );
			else
				masses.get( x+y*w ).v += v;
		}
		
		var n = 0;
		for(e in game.mobs)
			if( inRange(e, range) ) {
				var s = 20;
				incSpot(e.cx, e.cy, s);
				incSpot(e.cx-1, e.cy, s*0.5);
				incSpot(e.cx+1, e.cy, s*0.5);
				incSpot(e.cx, e.cy-1, s*0.5);
				incSpot(e.cx, e.cy+1, s*0.5);
				n++;
			}
			
		if( n==0 )
			return null;
		
		var spots = [];
		for(s in masses)
			if( sightCheckCoord(s.x, s.y) )
				spots.push(s);
		spots.sort(function(a,b) return Reflect.compare(b.v, a.v));
		
		if( spots.length==0 )
			return null;
		
		return { x:(spots[0].x+0.5)*Const.GRID, y:(spots[0].y+0.5)*Const.GRID };
	}
	
	public function getMobsInRange(range:Int, ?chkSight=false) {
		var all = [];
		for(e in game.mobs)
			if( e.onScreen && inRange(e, range) && (!chkSight || sightCheck(e)) )
				all.push(e);
		return all;
	}
	
	public function getPropsInRange(range:Int) {
		var all = [];
		for(e in en.Prop.ALL)
			if( e.onScreen && inRange(e, range) )
				all.push(e);
		return all;
	}
	
	public function getAnticipatedCoord() {
		if( path.length>0 ) {
			var pt = path[0];
			return { x:(pt.cx+pt.xr)*Const.GRID, y:(pt.cy+pt.yr)*Const.GRID };
		}
		else
			return {x:xx+dx*500, y:yy+dy*500};
	}
	
	
	public function getBestAng(fromX:Float, fromY:Float, range:Int) : Null<Float> {
		var all = getMobsInRange(range, true);
		if( all.length==0 )
			return null;
			
		var angs : IntHash<Float> = new IntHash();
		var bestScore = 0.;
		var bestAng = 0.;
		var precision = 11; // lower = more precise
		for(e in all) {
			var a = Math.round( Math.atan2(e.yy-fromY, e.xx-fromX)*precision ) / precision;
			var id = Std.int(a*precision);
			var s = e.targetScore + (angs.exists(id) ? angs.get(id) : 0);
			if( s>bestScore ) {
				bestScore = s;
				bestAng = a;
			}
			angs.set(id, s);
		}
		
		if( bestScore==0 )
			return null;
		else
			return bestAng;
	}
	
	
	public function getBestDir(fromX:Float, fromY:Float, range:Int, lineRadius:Float, angs:Array<Float>) {
		var all = getMobsInRange(range, true);
		if( all.length==0 )
			return null;
			
		var step = lineRadius*1.6;
		var results = new Array();
			
		for(a in angs) {
			var data = {ang:a, score:0., mobs:[], spots:[]}
			results.push(data);
			var d = 0.;
			while( d<range) {
				var x = fromX + Math.cos(a)*d;
				var y = fromY + Math.sin(a)*d;
				data.spots.push({x:x, y:y});
				for(e in all)
					if( Lib.distance(x,y, e.xx, e.yy) <= lineRadius+e.radius+5 ) {
						data.mobs.push(e);
						data.score+=e.targetScore;
					}
				d+=step;
			}
		}
		
		results.sort( function(a,b) return Reflect.compare(b.score, a.score)  );
		
		if( results[0].score<=0 )
			return null;
		else
			return results[0];
	}
	
	public function getSingleTarget(range:Int) : Mob {
		var all = getMobsInRange(range);
		
		all.sort(function(a,b) {
			return -Reflect.compare(a.targetScore, b.targetScore);
		});
		
		for(e in all)
			if( sightCheck(e) )
				return e;
		return null;
	}
	
	public function stop() {
		lastPathTarget = null;
		path = [];
		dx*=0.6;
		dy*=0.6;
		onMoveDone();
	}
	
	public function wander() {
		//if( cd.has("wander") )
			//return;
			//
		//var spots = game.currentLevel.getSpotsInRoom(roomId);
		//var pt = game.currentLevel.getFarSpotInRoom(roomId, cx,cy, 5, rseed);
		//if( pt!=null ) {
			//gotoDumb(
			//cd.set("wander", 30*3);
		//}
		var pt = game.currentLevel.getSpotInRoom(roomId, cx,cy, 2,5, rseed);
		if( pt!=null ) {
			gotoDumb((pt.cx+0.5)*Const.GRID, (pt.cy+0.5)*Const.GRID);
			fx.markerCaseTxt(pt.cx,pt.cy, "wander", 0xFFFFFF);
		}
		//var tries = 25;
		//var r = 3;
		//do {
			//var tcx = cx + irnd(-r,r);
			//var tcy = cy + irnd(-r,r);
			//if( !getCollision(tcx,tcy) && sightCheckCoord(tcx,tcy) ) {
				//gotoDumb((tcx+0.5)*Const.GRID, (tcy+0.5)*Const.GRID);
				//fx.markerCaseTxt(tcx,tcy, "wander", 0xFFFFFF);
				//break;
			//}
		//} while(tries-->0);
	}
	
	public function gotoDumb(x:Float, y:Float) {
		lastPathTarget = null;
		var tcx = Std.int(x/Const.GRID);
		var tcy = Std.int(y/Const.GRID);
		var txr = (x-tcx*Const.GRID)/Const.GRID;
		var tyr = (y-tcy*Const.GRID)/Const.GRID;
		path = [{ cx:tcx, cy:tcy, xr:txr, yr:tyr }];
		motivation = 20;
	}
	
	function getDoorsNearMe() {
		var doors = en.Door.getDoors(roomId);
		var r = [];
		for(d in doors)
			if( d.canBeReachedBy(this) )
				r.push(d);
				
		return r;
	}
	
	public function gotoFreeCoord(x:Float, y:Float) : Bool { // renvoie FALSE si le pathfinder n'a pas été appelé
		if( maxPathLen<=0 ) {
			gotoDumb(x,y);
			return false;
		}
		
		var l = game.currentLevel;
			
		var tcx = Std.int(x/Const.GRID);
		var tcy = Std.int(y/Const.GRID);
		
		var txr = (x-tcx*Const.GRID)/Const.GRID;
		var tyr = (y-tcy*Const.GRID)/Const.GRID;
		
		// Vers un mur
		if( l.getHardCollision(tcx,tcy) ) {
			gotoDumb(x,y);
			return false;
		}
		
		// Point dans le champ de vision
		var old = advancedSightCollisions;
		advancedSightCollisions = false;
		if( sightCheckCoord(tcx,tcy) ) {
			advancedSightCollisions = old;
			gotoDumb(x,y);
			return false;
		}
		advancedSightCollisions = old;
		
		// On y va déjà
		if( lastPathTarget!=null && this!=hero && tcx==lastPathTarget.cx && tcy==lastPathTarget.cy )  {
			motivation = 60;
			return true;
		}
		
		l.pathFinder.maxHomeDistance = 20;
		l.pathFinder.maxGoalDistance = 15;
		var p = l.pathFinder.getPath({x:cx, y:cy}, {x:tcx, y:tcy});
		
		// Pas de chemin
		if( p.length==0 ) {
			gotoDumb(x,y);
			return false;
		}
		
		lastPathTarget = {cx:tcx, cy:tcy};
		p = l.pathFinder.smooth(p);
		path = Lambda.array( Lambda.map(p, function(pt) {
			return {cx:pt.x, cy:pt.y, xr:0.5, yr:0.8}
		}) );
		path[path.length-1].xr = txr;
		path[path.length-1].yr = tyr;
		path.shift();
		motivation = 60;
		return true;
	}
	
	
	function onMoveDone() {
	}
	
	function onHitWall() {
	}
	function onHitGround() {
	}
	
	public function onTouchEntity(e:Entity) {
	}

	public function inRange(e:Entity, range:Int) {
		var dc = range/Const.GRID+1;
		return Math.abs(e.cx-cx)<dc && Math.abs(e.cy-cy)<dc && Lib.distance(xx,yy,e.xx,e.yy)<=range;
	}
	
	public function isTouchedBy(e:Null<Entity>) {
		return Math.abs(cx-e.cx)<=2 && Math.abs(cy-e.cy)<=2 && distance(e) <= radius+e.radius+4;
	}
	
	public inline function distance(e:Entity) {
		return mt.deepnight.Lib.distance(xx,yy, e.xx,e.yy-5);
	}
	
	public inline function preUpdate() {
		perf = api.AKApi.getPerf();
		cd.update();
		realFrict = cd.has("stun") ? 0.6 : frict;
		if( (uid+game.time)%20==0 )
			sightCache = new IntHash();
	}
	
	public inline function postUpdate() {
		var r = game.currentLevel.getRoomId(cx,cy);
		if( r>=0 )
			roomId = r;
	}
	
	public inline function jump(d) {
		dz = d;
	}
	
	public function onActivate() {
	}
	
	public function update() {
		// Suivi du path
		if( zz==0 && path.length>0 && !cd.has("stun") && !cd.has("moveLock") ) {
			var next = path[0];
			var a = Math.atan2( (next.cy+next.yr)-(cy+yr), (next.cx+next.xr)-(cx+xr) );
			var s = speed * (cd.has("slow") ? 0.3 : 1);
			dx += Math.cos(a)*s;
			dy += Math.sin(a)*s;
			if( mt.deepnight.Lib.distance(cx+xr, cy+yr, next.cx+next.xr, next.cy+next.yr) <= 0.1 ) {
				path.shift();
				motivation = 60;
				if( path.length==0 )
					stop();
			}
			if( motivation<=0 ) {
				stop();
			}
		}
		
		
		// Collisions circulaires
		if( zz<4 && weight>0 && (onScreen || (game.time+uid)%10==0) ) {
			for( e in ALL )
				if( e!=this && e.zz<4 && e.weight>0 && Math.abs(e.cx-cx)<=1 && Math.abs(e.cy-cy)<=1 ) {
					var sd = mt.deepnight.Lib.distanceSqr(xx,yy,e.xx,e.yy);
					if( sd<=(radius+e.radius)*(radius+e.radius) ) {
						var a = Math.atan2(yy-e.yy, xx-e.xx);
						var repel = 0.08;
						var wr = Math.min(1, e.weight/(e.weight+weight));
						if( wr>=0.95 ) wr = 1;
						if( wr<=0.05 ) wr = 0;
						dx += Math.cos(a) * repel * wr;
						dy += Math.sin(a) * repel * wr;
						e.dx += Math.cos(3.14+a) * repel * (1-wr);
						e.dy += Math.sin(3.14+a) * repel * (1-wr);
						onTouchEntity(e);
						e.onTouchEntity(this);
					}
				}
		}
			
			
		var wrepel = 0.15;
		// Gestion X
		if( collides && getCollision(cx-1,cy) && getCollision(cx+1, cy) ) {
			dx = 0;
			xr = 0.5;
		}
		xr+=dx;
		if( collides ) {
			if( xr<=0.5 && getCollision(cx-1,cy) ) {
				if( xr<=0.2 )
					xr = 0.2;
				if( dx<0 ) {
					onHitWall();
					dx *= -wallBounce;
				}
				dx+=wrepel;
				motivation--;
			}
			if( xr>=0.5 && getCollision(cx+1,cy) ) {
				if( xr>=0.8 )
					xr = 0.8;
				if( dx>0 ) {
					onHitWall();
					dx *= -wallBounce;
				}
				dx-=wrepel;
				motivation--;
			}
		}
		while(xr>1) { xr--; cx++; }
		while(xr<0) { xr++; cx--; }
		dx*=realFrict;
		if( Math.abs(dx)<=0.001 )
			dx = 0;
		
		// Gestion Y
		yr+=dy;
		if( collides ) {
			if( yr<=0.2 && getCollision(cx,cy-1) ) {
				yr = 0.2;
				if( dy<0 ) {
					dy *= -wallBounce;
					onHitWall();
				}
				motivation--;
			}
			if( yr>=1 && getCollision(cx,cy+1) ) {
				yr = 1;
				if( dy>0 ) {
					dy *= -wallBounce;
					onHitWall();
				}
				motivation--;
			}
		}
		while(yr>1) { yr--; cy++; }
		while(yr<0) { yr++; cy--; }
		dy*=realFrict;
		if( Math.abs(dy)<=0.001 )
			dy = 0;
		
		// Gestion Z
		if( zz>0 || dz!=0 ) {
			zz+=dz;
			dz-=0.5;
			if( zz<=0 ) {
				dz = zz = 0;
				onHitGround();
			}
		}
		
		// Direction
		if( sprite.scaleX>0 && lookDir<0 ) sprite.scaleX*=-1;
		if( sprite.scaleX<0 && lookDir>0 ) sprite.scaleX*=-1;
		
		// Update graphique
		onScreen = isOnScreen();
		updateScreenCoords();
		sprite.visible = onScreen && life>0;
		lifeBar.visible = showBar && onScreen && life<maxLife && life>0;
		#if debug hitZone.visible = onScreen; #end
		if( shadow!=null )
			shadow.visible = onScreen && perf>=0.8;
		if( onScreen ) {
			var x = Std.int(xx);
			var y = Std.int(yy);
			sprite.x = x;
			sprite.y = Std.int(yy-zz);
			lifeBar.x = Std.int(x-lifeBar.width*0.5 + barOffsetX);
			lifeBar.y = y + barOffsetY;
			if( shadow!=null ) {
				shadow.x = x;
				shadow.y = y;
			}
			#if debug
			hitZone.x = x;
			hitZone.y = y;
			#end
			if( life>0 )
				sprite.alpha = cd.has("shield") && game.time%2==0 ? 0.4 : 1;
		}
	}
	
}

