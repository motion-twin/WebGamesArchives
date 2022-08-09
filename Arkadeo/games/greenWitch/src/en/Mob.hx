package en;

import Const;
import mt.deepnight.Lib;

class Mob extends Entity {
	static var VALUE = api.AKApi.const(100);
	
	public var targetScore		: Float;
	public var baseScore		: Int;
	public var strength			: Int;
	var defaultAnim				: Null<String>;
	var coward					: Bool;
	
	public function new(x,y) {
		super();
		
		baseScore = 1;
		targetScore = 0;
		strength = 1;
		side = 1;
		coward = false;
		
		cx = x;
		cy = y;
		defaultAnim = "walk";
		
		cd.set("moveDecision", rnd(10,30));
		setShadow(true);
	}
	
	function getLoot() {
		return api.AKApi.const(0);
	}
	function getXp() {
		return api.AKApi.const(1);
	}
	
	override function setSpeed(f:Float) {
		var d = game.isLeague() ? 1 : Math.min(1, 0.5 + 0.5*api.AKApi.getLevel()/10);
		super.setSpeed(f * d);
	}
	
	public inline function getXpValue() {
		var xp = getXp();
		return xp!=null ? xp.get() : 0;
	}

	public function toString() {
		return "MOB"+[cx,cy];
	}
	
	public override function hit(d) {
		super.hit(d);
		updateTargetScore();
		mt.deepnight.Sfx.playOne([
			S.BANK.hit01, S.BANK.hit04,
		], mt.deepnight.Lib.rnd(0.3, 0.4));
	}
	
	override function splat() {
		fx.death(xx,yy);
		fx.blood(xx,yy);
	}
	
	override public function onDie() {
		super.onDie();
		api.AKApi.addScore(VALUE);
		if( game.isProgression() ) {
			var xp = getXp();
			if( xp!=null )
				game.hero.addXp(this, xp);
		}
		var loot = getLoot();
		if( loot!=null && game.isLeague() )
			new en.it.Gold(cx,cy, loot.get());
	}
	
	public function updateTargetScore() {
		var weapon = switch( game.hero.weaponType) {
			case W_Lightning :
				life>=4 ? (life<=10 ? 70 : 50) : 0;
				
			case W_Basic :
				life==1 ? 50 : 0;
				
			case W_Lazer :
				life>=2 ? 30 : 0;
				
			case W_Grenade :
				0;
		}
		
		var d = distance(hero);
		return targetScore = weapon + baseScore +
			(d<=40 ? 50 : 0) + // Trop proche
			75 * (1 - Math.min(1, d/100)) + // Distance
			25 * (1 - Math.min(1,life/5)); // Santé
	}
	
	inline function getClassName() {
		return Std.string(Type.getClass(this));
	}
	
	override public function register() {
		super.register();
		game.mobs.push(this);
		
		var k = getClassName();
		if( !game.mobCounts.exists(k) )
			game.mobCounts.set(k, 1);
		else
			game.mobCounts.set(k, game.mobCounts.get(k)+1);
	}
	
	override public function detach() {
		super.detach();
		game.mobCounts.set(getClassName(), game.mobCounts.get(getClassName())-1);
		game.mobs.remove(this);
	}
	
	
	function fleeRoom() : Bool {
		var doors = Lambda.filter(Door.getDoors(roomId), function(d) {
			if( hero.roomId!=roomId && d.inRoom(hero.roomId) ) // on ignore les portes qui mèneraient au héros
				return false;
			else
				return true;
		});
		var best = doors.first();
		for(d in doors) {
			var ddist = distance(d);
			if( (best==null || hero.distance(d)>ddist || ddist<distance(best)) && hero.distance(d)>ddist )
				best = d;
		}
		if( best!=null )
			if( distance(best)>60) {
				// Porte éloignée
				fx.markerCaseTxt(best.cx, best.cy, "bestDoor", 0xFFFF00);
				var pt = best.getPointNotInRoom(hero.roomId);
				gotoFreeCoord((pt.cx+0.5)*Const.GRID, (pt.cy+1)*Const.GRID);
				decisionCD(15);
				cd.set("forceFlee", 30);
				return true;
			}
			else {
				// Porte proche, on cherche un point dans la salle suivante
				var pt = game.currentLevel.getSpotInRoom(best.getOtherRoom(roomId), best.cx, best.cy, 6,8, rseed);
				if( pt!=null ) {
					fx.markerCaseTxt(pt.cx, pt.cy, "afterDoor", 0xFFFF82);
					gotoFreeCoord((pt.cx+0.5)*Const.GRID, (pt.cy+0.5)*Const.GRID);
					decisionCD(60);
					return true;
				}
			}
			
		return false;
	}
	
	
	function cowardAI() {
		// Force le rappel à fleeRoom() pour avoir un comportement consistant
		if( cd.has("forceFlee") )
			if( fleeRoom() )
				return;
				
		// Même salle
		if( roomId==hero.roomId )
			if( fleeRoom() )
				return;
				
		// Salle différente mais héros visible
		if( roomId!=hero.roomId && sightCheck(hero) )
			if( fleeRoom() )
				return;
				
		// Héros proche d'une des portes de la salle
		if( roomId!=hero.roomId ) {
			var doors = Door.getDoors(roomId);
			for( d in doors )
				if( hero.distance(d)<120 && distance(d)<160 )
					if( fleeRoom() ) {
						fx.markerCaseTxt(d.cx, d.cy, "dangerDoor", 0xFF0000);
						return;
					}
		}
	
		
		// Fuite bête
		if( sightCheck(hero) ) {
			fx.markerCaseTxt(hero.cx, hero.cy, "saw", 0xFF0000);
			
			// Fuite vers un endroit hors du champ de vision du héros
			var a = Math.atan2(hero.yy-yy, hero.xx-xx) + 3.14;
			var tries = 25;
			do {
				var ta = a+rnd(0.2, 0.8, true);
				var d = rnd(5,8);
				var tcx = Math.round(cx + Math.cos(ta)*d);
				var tcy = Math.round(cy + Math.sin(ta)*d);
				if( !getCollision(tcx,tcy) && !hero.sightCheckCoord(tcx,tcy) ) {
					fx.markerCaseTxt(tcx, tcy, "flee", 0x00FFFF);
					gotoFreeCoord((tcx+0.5)*Const.GRID, (tcy+0.5)*Const.GRID);
					decisionCD(40);
					return;
				}
			} while(tries-->0);
			
			// Pas d'issue : fuite à l'opposé
			decisionCD(30);
			a+=rnd(0, 0.3, true);
			var x = xx+Math.cos(a)*100;
			var y = yy+Math.sin(a)*100;
			fx.markerCaseTxt(Std.int(x/Const.GRID), Std.int(y/Const.GRID), "dumbFlee", 0xFF80FF);
			gotoDumb( xx+Math.cos(a)*100, yy+Math.sin(a)*100 );
			return;
		}

		// Tout va bien
		wander();
		decisionCD(20);
		return;
	}
	
	inline function decisionCD(d:Int) {
		cd.set("moveDecision", onScreen ? d : d+30);
	}
	
	function defaultAI() {
		var dhero = distance(hero);
		if( dhero<=250 && sightCheck(hero) )  {
			// Voit le héros
			gotoDumb(hero.xx, hero.yy);
			decisionCD(15);
			cd.set("sawRecently", 60);
			return;
		}
		else if( cd.has("sawRecently") ) {
			// Il a aperçu le héros récemment...
			gotoFreeCoord(hero.xx, hero.yy);
			decisionCD(50);
			return;
		}
		
		if( roomId!=hero.roomId ) {
			// Dans une salle différente
			var links = Door.getBetween(this, roomId, hero.roomId);
			if( links.length==0 || dhero>250 ) {
				// Salle éloignée (pas de connexion directe) ou joueur éloigné
				wander();
				decisionCD(30);
				return;
			}
			else {
				links.sort(function(a,b) return Reflect.compare(distance(a), distance(b)));
				var link = links[0];
				// Salle proche
				if( distance(link)<40 ) {
					gotoFreeCoord(hero.xx, hero.yy); // vers le héros
					decisionCD(40);
				}
				else {
					gotoFreeCoord(link.xx, link.yy); // vers la porte
					decisionCD(50);
				}
			}
		}
		else {
			// Même salle mais loin
			if( dhero<250 ) {
				// Proche
				gotoFreeCoord(hero.xx, hero.yy);
				decisionCD(30);
				return;
			}
			else {
				// Loin
				wander();
				decisionCD(30);
				return;
			}
		}
	}
	
	function moveAI() {
		if( cd.has("moveDecision") )
			return;
			
		if( coward )
			cowardAI();
		else
			defaultAI();
	}
	
	public override function onTouchEntity(e:Entity) {
		super.onTouchEntity(e);
		
		if( cd.has("attack") )
			return;
			
		if( e.isAlly() ) {
			cd.set("attack", 30);
			e.hit(strength);
		}
	}
	
	function onTouchDoor(d:Door) {
		d.hit(strength);
		cd.set("attack", 30);
	}
	
	
	override public function update() {
		var hero = game.hero;

		// Déplacement
		moveAI();
		
		if( onScreen ) {
			if( !sprite.hasAnim() && defaultAnim!=null ) {
				sprite.playAnim(defaultAnim);
				sprite.offsetAnimFrame(Std.random);
			}
			lookDir = hero.xx>xx ? 1 : -1;
			if( (game.time+uid)%10 == 0 )
				updateTargetScore();
		}
		else
			sprite.stopAnim();
		
		if( strength>0 && !cd.has("attack") ) {
			// Attaque joueur
			if( hero.isTouchedBy(this) ) {
				onTouchEntity(hero);
				if( hero.counterAttack>0 )
					hit(hero.counterAttack);
			}
				
			// Attaque tourelle
			if( hero.turret!=null && hero.turret.isTouchedBy(this) )
				onTouchEntity(hero.turret);
				
			// Attaque porte
			for(d in getDoorsNearMe())
				if( d.isClosed() )
					onTouchDoor(d);
		}
		
		// Stuck -> Suicide
		if( !cd.hasSet("stuckCheck", 30) )
			if( getCollision(cx,cy) ) {
				if( !cd.hasSet("stuck", 60) )
					cd.onComplete("stuck", destroy);
			}
			else
				cd.unset("stuck");
		
		super.update();
	}
}


