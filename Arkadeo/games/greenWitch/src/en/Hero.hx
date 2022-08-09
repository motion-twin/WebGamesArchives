package en;

import flash.display.Sprite;

import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.deepnight.retro.SpriteLibBitmap;

import Const;

class Hero extends Entity {
	static var ATTACH_POINTS : Array<{x:Float, y:Float}>;
	static var STAFF_POINTS : Array<{x:Float, y:Float}>;
	static var LEVELS = api.AKApi.aconst([20, 50, 100, 250, 500]);
	
	public var xp(default,null)			: mt.flash.Volatile<Int>;
	public var level(default,null)		: mt.flash.Volatile<Int>;
	
	var body				: BSprite;
	var arms				: BSprite;
	var armFrame			: Int;
	var halo				: flash.display.Bitmap;
	var invokeCursor		: Null<Sprite>;
	public var dead			: mt.flash.Volatile<Bool>;
	
	var bloodFeedback		: flash.display.Bitmap;
	
	public var weaponType	: WeaponType;
	public var ammo			: Int;
	public var turret		: Null<Turret>;
	public var turretType	: Null<TurretType>;
	public var turrets		: Int;
	public var turretCasts	: Int;
	public var counterAttack	: mt.flash.Volatile<Int>;
	public var extraAmmo		: mt.flash.Volatile<Int>;
	public var extraTurret		: mt.flash.Volatile<Int>;
	
	public var openedDoors	: IntHash<Door>;
	public var targetEntity	: Null<Entity>;
	
	public function new() {
		super();
		
		barOffsetY = -32;
		openedDoors = new IntHash();
		advancedSightCollisions = true;
		
		turretCasts = 0;
		xp = 0;
		level = 0;
		dead = false;
		ammo = 0;
		turrets = 5;
		side = 0;
		counterAttack = 0;
		extraAmmo = 0;
		extraTurret = 0;
		
		var s = new Sprite();
		var w = game.buffer.width;
		var h = game.buffer.height;
		var m = new flash.geom.Matrix();
		m.createGradientBox(w*2, h*2, 0, -w*0.5, -h*0.5);
		s.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [0xFF0000,0xFF0000,0xFF0000], [0,0.5,1], [0,90,255], m);
		s.graphics.drawRect(0, 0, w, h);
		bloodFeedback = Lib.flatten(s);
		bloodFeedback.visible = false;
		bloodFeedback.blendMode = flash.display.BlendMode.ADD;
		game.buffer.dm.add(bloodFeedback, Const.DP_BLOOD);
		
		body = game.char.get("hero");
		body.setCenter(0.5, 1);
		sprite.addChild(body);
		
		arms = game.char.get("heroArms");
		arms.setCenter(0,0);
		sprite.addChild(arms);
		
		weight = 2;
		
		showBar = true;
		setShadow(true);
		
		halo = new flash.display.Bitmap(game.char.getBitmapData("halo"));
		halo.scaleX = halo.scaleY = 2;
		game.sdm.add(halo, Const.DP_BG_FX);
		halo.blendMode = flash.display.BlendMode.OVERLAY;
		
		STAFF_POINTS = [
			{x : 12, y : -30},
			{x : 19, y : -28},
			{x : 18, y : -15},
			{x : 16, y : -5},
			{x : 10, y : -2},
		];
		
		ATTACH_POINTS = new Array();
		for(f in 0...game.char.countFrames("hero")) {
			var bd = game.char.getBitmapData("hero", f);
			var bounce = bd.getColorBoundsRect(0xFFFFFFFF, 0xFFFF00FF, true);
			ATTACH_POINTS[f] = {x:bounce.x, y:bounce.y}
			bd.dispose();
			var fbounce = game.char.getRectangle("hero", f);
			game.char.source.setPixel32(Std.int(fbounce.x+bounce.x), Std.int(fbounce.y+bounce.y), 0x0);
		}
		
		applyLevel();
		setWeapon(W_Basic);
		setTurret(T_Gatling);
	}
	
	function applyLevel() {
		if( game.isLeague() ){
			// MODE LEAGUE
			initLife(10);
			setSpeed(1.5);
			counterAttack = 0;
			extraAmmo = 0;
			extraTurret = 0;
		}
		else {
			// MODE LEVEL UP (Attention !! Le level du héros commence à 0)
			speed = Math.min( 1.8, 1 + level*0.05) * Entity.BASE_SPEED.get()/100;
			initLife( level + 5 );
			if( level<=3 )
				counterAttack = 0;
			else if( level<=6 )
				counterAttack = 1;
			else if( level<=10 )
				counterAttack = 2;
			else
				counterAttack = 3;
				
			if( level<3 )
				extraAmmo = 0;
			else if( level<8 )
				extraAmmo = 5;
			else
				extraAmmo = 15;
				
			if( level<5 )
				extraTurret = 0;
			else if( level<8 )
				extraTurret = 1;
			else
				extraTurret = 2;
		}
		#if debug
		initLife(9999);
		#end
	}
	
	public function addXp(?from:Entity, n:api.AKConst) {
		if( game.isProgression() ) {
			xp+=n.get();
			var next = getNextLevelXp(level);
			if( xp>=next ) {
				xp-=next;
				onLevelUp();
			}
			game.hud.refresh();
			if( from!=null )
				fx.xp(from.xx,from.yy, n.get());
		}
	}
	
	public function onLevelUp() {
		level++;
		applyLevel();
		life = maxLife;
		updateLife();
		
		fx.levelUp();
		game.explosion(false, xx,yy, 130, 3, 2);
		
		game.hud.refresh();
	}
	
	public static inline function getNextLevelXp(l:Int) {
		return l>=LEVELS.length ? LEVELS[LEVELS.length-1].get() : LEVELS[l].get();
	}
	
	public function setTurret(t:TurretType) {
		turretType = t;
		switch( t ) {
			case T_Gatling :
				turrets = 5;
			case T_Shield :
				turrets = 2;
			case T_Slow :
				turrets = 3;
			case T_Burner :
				turrets = 3;
		}
		turrets+=extraTurret;
		game.hud.blinkTurret();
		game.hud.refresh();
	}
	
	public function setWeapon(w:WeaponType) {
		weaponType = w;
		switch( w ) {
			case W_Basic : ammo = 90;
			case W_Grenade : ammo = 30;
			case W_Lazer : ammo = 30;
			case W_Lightning : ammo = 20;
		}
		ammo+=extraAmmo;
		game.hud.blinkWeapon();
		game.hud.refresh();
	}
	
	override public function detach() {
		super.detach();
		halo.bitmapData.dispose();
		halo.parent.removeChild(halo);
	}
	
	public function toString() {
		return "HERO"+[cx,cy];
	}
	
	public inline function isMoving() {
		return path.length>0;
	}
	
	public function getStaffPoint() {
		var pt = STAFF_POINTS[armFrame];
		return {
			x : xx + lookDir * pt.x,
			y : yy + pt.y,
		}
	}
	
	
	public function aim(x:Float,y:Float) {
		var pi = Math.PI;
		var delta = y-yy;
		var a = Math.atan2(y-(yy-8), x-xx);
		a+=pi*0.5;
		if( a>=pi )
			a-=pi*2;
		a = Math.abs(a);
		
		if( a<pi*0.20 ) armFrame = 0;
		else if( a<pi*0.4 ) armFrame = 1;
		else if( a<pi*0.65 ) armFrame = 2;
		else if( a<pi*0.8 ) armFrame = 3;
		else armFrame = 4;
		cd.set("armLock", 35);
		
		lookDir = x<xx ? -1 : 1;
		cd.set("lookLock", 50);
	}
	
	public function heal(n:Int) {
		if( dead )
			return;
			
		life+=n;
		if( life>maxLife )
			life = maxLife;
		fx.pop(xx,yy, "+"+n, 0xFFAC00, 2);
		updateLife();
	}
	
	public function saveState() : PlayerState {
		return {
			life	: life,
			xp		: xp,
			level	: level,
		}
	}
	
	public function loadState(s:Null<PlayerState>) {
		if( api.AKApi.getLevel()==1 )
			return;
			
		if( s==null ) // Mode MISSION
			s = {
				level	: Math.round(game.asProgression().level/2),
				xp		: 0,
				life	: 999,
			}
			
		level = s.level;
		applyLevel();
		xp = s.xp;
		life = Std.int( Math.min(maxLife, s.life) );
		updateLife();
		game.hud.refresh();
	}
	
	override function canBeHit() {
		return !dead;
	}
	
	override public function slowDown(d) {
		if( !dead )
			super.slowDown(d);
	}
	
	override public function hit(d:Int) {
		if( d<=0 || dead )
			return;
			
		if( turret!=null && turret.absorbDamageRange>0 && distance(turret)<=turret.absorbDamageRange ) {
			fx.shieldHit(this);
			turret.hit(d);
			return;
		}
		
		super.hit(d);
		
		mt.deepnight.Sfx.playOne([S.BANK.heroHit01, S.BANK.heroHit02, S.BANK.heroHit03], Lib.rnd(0.5,1));
		
		game.addSkill(-0.1);
		
		if( api.AKApi.isLowQuality() )
			fx.blink(this, 0xFFD900);
		else {
			var pow = Math.min(1, d/5);
			game.tw.terminate(bloodFeedback);
			bloodFeedback.visible = true;
			bloodFeedback.alpha = 0.5 + pow*0.5;
			game.tw.create(bloodFeedback, "alpha", 0, TEase, 300+pow*1000).onEnd = function() {
				bloodFeedback.visible = false;
			}
		}
	}
	override public function onDie() {
		if( !dead ) {
			S.BANK.explode03().play();
			dead = true;
			weight = 0;
			collides = false;
			lifeBar.visible = showBar = false;
			stop();
			cancelInvoke();
			game.explosion(false, xx,yy, 200, 2, 2.5);
			game.onHeroDeath();
		}
	}
	

	public override function stop() {
		super.stop();
		fx.cancelOrder();
	}
	

	public function cancelInvoke() {
		if( invokeCursor!=null ) {
			invokeCursor.parent.removeChild(invokeCursor);
			invokeCursor = null;
		}
	}
	
	public function invoke(x:Float, y:Float, ratio:Float) {
		if( invokeCursor==null ) {
			invokeCursor = new Sprite();
			game.sdm.add(invokeCursor, Const.DP_INTERF);
		}
		
		var tcx = Std.int(x/Const.GRID);
		var tcy = Std.int(y/Const.GRID);
		
		invokeCursor.x = Std.int( tcx*Const.GRID );
		invokeCursor.y = tcy*Const.GRID;
		
		var col = 0xFF0000;
		if( sightCheckCoord(tcx,tcy) )
			col = 0x80FF00;
			
		var g = invokeCursor.graphics;
		g.clear();
		var bx = Std.int(Const.GRID*0.5 - 6);
		g.beginFill(0x0, 0.6);
		g.drawRect(bx,-5, 12,4);
		g.beginFill(col, 1);
		g.drawRect(bx+1,-4, 10*ratio,2);
		g.beginFill(col, 0.5);
		g.drawRect(1, 1, Const.GRID-2, Const.GRID-2);
	}
	
	
	override function popDamage(d) {
		fx.pop(xx,yy, -d, 0xFF0000, 2);
	}
	
	public function canCastTurret() {
		return turrets>0;
	}
	
	public function castTurret(tcx,tcy) {
		if( !canCastTurret() || !sightCheckCoord(tcx,tcy) )
			return;
			
		turretCasts++;
		if( turret!=null )
			turret.explode();
			
		if( game.isProgression() )
			game.asProgression().endTutoStep(3);
			
		game.addSkill(0.1);
		turrets--;
		game.hud.refresh();
		if( turrets==1 )
			game.notify(Lang.LowTurret, 0xFFFF00);
		if( turrets==0 )
			game.warning(Lang.OutOfTurret);
		switch( turretType ) {
			case T_Gatling :
				turret = new en.tur.Gatling(tcx,tcy);
				
			case T_Shield :
				turret = new en.tur.Shield(tcx,tcy);
			
			case T_Slow :
				turret = new en.tur.Slow(tcx,tcy);
				
			case T_Burner :
				turret = new en.tur.Burner(tcx,tcy);
		}
		S.BANK.hit03().play();
	}
	
	public inline function loseAmmo() {
		if( ammo>0 ) {
			game.inactivity = 0;
			ammo--;
			game.hud.refresh();
			if( ammo==0 )
				game.warning(Lang.OutOfAmmo);
			else if( ammo==10 || ammo==5 )
				game.notify(Lang.LowAmmo({_n:ammo}), 0xFFFF00);
		}
	}
	
	public function shoot() {
		if( cd.has("shoot") || cd.has("unstable") || cd.has("shootCheck") )
			return;
			
		if( ammo<=0 ) {
			game.addSkill(-0.1);
			return;
		}
		
		cd.set("shootCheck", 5); // frame skip
		var moving = isMoving();
		
		switch( weaponType ) {

			case W_Basic :
				var e = getSingleTarget(160);
				if( e!=null ) {
					cd.set("shoot", !moving ? 7 : 10 );
					aim(e.xx, e.yy);
					var pt = getStaffPoint();
					new en.sh.Bullet(pt.x, pt.y, e, !moving);
					loseAmmo();
				}
			
			case W_Lightning :
				var e = getSingleTarget(100);
				if( e!=null ) {
					cd.set("shoot", !moving ? 25 : 40 );
					aim(e.xx, e.yy-6);
					var pt = getStaffPoint();
					fx.lightning(pt.x, pt.y, e.xx, e.yy-6, 0x0080FF, !moving);
					e.hit(10);
					e.slowDown(20);
					var extraHits = 3;
					for(e2 in e.getPropsInRange(40))
						e2.hit(1);
					for(e2 in e.getMobsInRange(40))
						if( e!=e2 ) {
							e2.hit(1);
							extraHits--;
							if( extraHits<=0 )
								break;
						}
					loseAmmo();
				}
				
			case W_Grenade :
				var pt = getMassTarget(130);
				if( pt!=null ) {
					cd.set("shoot", !moving ? 30 : 40 );
					aim(pt.x, pt.y);
					new Grenade(pt.x, pt.y);
					loseAmmo();
				}
				
			case W_Lazer :
				var center = {x:xx, y:yy-12};
				var a = getBestAng(center.x, center.y, 140);
				if( a!=null ) {
					cd.set("shoot", !moving ? 13 : 23 );
					aim(center.x + Math.cos(a)*150, center.y + Math.sin(a)*150);
					new en.sh.Lazer(center.x, center.y, a, 0xFF00FF, !moving);
					loseAmmo();
				}

				/*
				var range = 140;
				var center = {x:xx, y:yy-12};
				var width = 18;
				var pi = Math.PI;
				var data = getBestDir(center.x, center.y, range, width*0.5, [0, pi*0.5, pi, pi*1.5]);
				if( data!=null ) {
					var ang = data.ang;
					cd.set("shoot", !moving ? 40 : 50 );
					for(pt in data.spots)
						fx.burn(pt.x, pt.y);
					for(e in data.mobs) {
						e.hit(5);
						e.slowDown(40);
						e.cd.set("shield", 1);
					}
					
					var tx = xx+Math.cos(ang)*range;
					var ty = yy+Math.sin(ang)*range;
					aim(tx,ty);
					
					var spt = getStaffPoint();
					fx.lazer(spt.x,spt.y, ang, range-15, width, 0xFF00FF);
					var endX = spt.x+Math.cos(ang)*(range-15);
					var endY = spt.y+Math.sin(ang)*(range-15);
					fx.hitSmoke(endX, endY);
					fx.burn(endX, endY);
					cd.set("armLock", 50);
				}
				*/
		}
	}
	
	override public function update() {
		if( dead )
			return;
			
		var moving = isMoving();
		
		// Position par défaut bras
		if( !cd.has("armLock") )
			armFrame = 2;
		
		// Anim de rotation bras
		if( !cd.has("armMove") ) {
			var cur = arms.frame;
			if( cur!=armFrame ) {
				if( cur<armFrame )
					arms.setFrame(cur+1);
				else
					arms.setFrame(cur-1);
				cd.set("armMove", 3);
			}
		}
		
		// Anim de mouvement
		var suffix = armFrame==0 ? "Up" : "";
		if( dx==0 && dy==0 )
			body.playAnim("front"+suffix);
		else {
			if( lookDir>0 && dx<-0.01 || lookDir<0 && dx>0.01 )
				body.playAnim("back"+suffix);
			else
				body.playAnim("front"+suffix);
		}
			
		// Tir
		shoot();

		// Direction
		if( !cd.has("lookLock") ) {
			if( dx<=-0.02 )
				lookDir = -1;
			if( dx>=0.02 )
				lookDir = 1;
		}
		
		super.update();
		sprite.x = sprite.x - lookDir*5;
		
		// Particules bâton
		if( game.time%3==0 ) {
			var pt = getStaffPoint();
			fx.staff(pt.x, pt.y, weaponType);
		}
		
		// Position bâton
		var pt = ATTACH_POINTS[body.frame];
		arms.x = Std.int(-body.width*0.5 + pt.x);
		arms.y = -body.height + pt.y;
		
		// Lumière sol
		if( perf<0.7 )
			halo.visible = false;
		else {
			halo.visible = true;
			halo.x = xx - halo.width*0.5;
			halo.y = yy - halo.height*0.5;
		}

		// Manipulation des portes
		for(d in openedDoors)
			if( d.broken || d.killed || !d.canBeReachedBy(this) ) {
				openedDoors.remove(d.uid);
				d.set(true);
			}
		for( d in getDoorsNearMe() )
			if( !d.broken ) {
				openedDoors.set(d.uid, d);
				d.set(false);
			}
		
		// Manipulation d'objets divers
		if( targetEntity!=null && targetEntity.isTouchedBy(this) ) {
			targetEntity.onActivate();
			targetEntity = null;
		}
		
		// Tourelle bouclier
		if( game.time%15==0 && turret!=null && distance(turret)<turret.absorbDamageRange )
			fx.shieldGlow(this);
			
		if( cd.has("slow") )
			sprite.filters = [ new flash.filters.GlowFilter(0x1DE276,1, 2,2, 5) ];
		else
			sprite.filters = [];
	}
}