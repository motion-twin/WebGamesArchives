package mode;

import Const;
import Type;
import Level;

class League extends Play {
	static var AUTO_DIFF_FREQ = api.AKApi.const(30);
	
	var round			: mt.flash.Volatile<Int>;
	var timedEvents		: Array<{t:Float, cb:Void->Void}>;
	
	public function new() {
		round = 0;
		timedEvents = new Array();
		super();
		
		cd.set("dt", AUTO_DIFF_FREQ.get());
	}
	
	inline function addTimedEvent(seconds:Int, cb:Void->Void) {
		timedEvents.push({t:time+seconds*30, cb:cb});
		timedEvents.sort(function(a,b) return Reflect.compare(a.t, b.t));
	}
	
	inline function addTimedItem(seconds:Int, i:Class<en.Item>) {
		addTimedEvent(seconds, function() {
			var pt = currentLevel.getFarSpot(rseed, hero.cx, hero.cy);
			Type.createInstance(i, [pt.cx, pt.cy]);
		});
	}
	
	
	
	override function onLevelComplete() {
		round++;
		repopCivilians();
	}
	
	function repopCivilians() {
		var a : Array<Entity> = [hero];
		for(i in 0...5+round) {
			var pt = currentLevel.getMetaOnceFarFromOthers("middle", rseed, a);
			a.push( new en.it.Civilian(pt.cx, pt.cy) );
		}
	}
	
	override public function generateLevel() {
		super.generateLevel();
		
		
		setLevel( Level.createLeagueLevel(), rseed.irange(5,8) );
		currentLevel.draw();
		
		
		//#if debug
		//for( pack in 0...3 ) { // HACK
			//var pt = currentLevel.getFarSpot(rseed, hero.cx, hero.cy, 10);
			//for( i in 0...7 )
				//new en.mob.Skeleton(pt.cx, pt.cy);
		//}
		//#end
		
		// Distributeurs tourelles
		var all = Type.allEnums(TurretType);
		if( isProgression() ) {
			while( all.length>2 )
				all.splice(rseed.random(all.length),1);
		}
		var a = [];
		for(e in all) {
			var pt = currentLevel.getMetaOnceFarFromOthers("onWall", rseed, a);
			new en.Dispenser(pt.cx, pt.cy, DispenserEffect.D_GiveTurret(e));
		}
		
		// Distributeurs armes
		var a = [];
		for(i in 0...2) {
			var all = Type.allEnums(WeaponType);
			for(e in all) {
				var pt = currentLevel.getMetaOnceFarFromOthers("onWall", rseed, a);
				new en.Dispenser(pt.cx, pt.cy, DispenserEffect.D_GiveWeapon(e));
			}
		}
		
		// Coffres
		var a : Array<Entity> = [hero];
		var t = 0;
		while( t < 60*5 ) {
			addTimedEvent(t, function() {
				var pt = currentLevel.getFarSpot(rseed, hero.cx, hero.cy);
				new en.it.Gold(pt.cx, pt.cy, 3);
			});
			t += rseed.irange(5,40);
		}
		
		// Civils
		repopCivilians();
		
		// Cartes
		var a = [];
		for(i in 0...rseed.irange(4,6)) {
			var pt = currentLevel.getMetaOnceFarFromOthers("onWall", rseed, a);
			a.push( new en.Map(pt.cx, pt.cy) );
		}
		
		
		// Item : réparation
		var t = rseed.irange(20,40);
		for(i in 0...rseed.irange(2,5)) {
			addTimedItem(t, en.it.Repair);
			t+=rseed.irange(15,40);
		}
		
		// Item : soins
		var t = rseed.irange(20,40);
		for(i in 0...rseed.irange(0,3)) {
			addTimedItem(t, en.it.Heal);
			t+=rseed.irange(10,40);
		}
		
		refillLevel();
	}
	
	function refillLevel() {
		for(i in 0...30) {
			cd.unsetAll("repop_");
			repop();
		}
	}
	
	function repop() {
		/***/
		// Gros rouges
		repopMob(difficulty, 4, en.mob.Bleuarg, 30*15);
		
		// Déverrouilleurs
		repopMob(difficulty*0.5, 3, en.mob.Unlocker, 30*20);
		
		// Hordes
		var n = difficulty>=1 ? rseed.irange(3,5) : rseed.irange(2,3);
		repopMob(10+difficulty*15, 50, en.mob.Horde, 30*10, n);
		
		// Chauve-souris
		repopMob(10+difficulty*5, 20, en.mob.Bat, 30*5, rseed.irange(1,4));

		// Canons
		if( difficulty>=6 )
			repopMob(difficulty-4, 5, en.mob.FireCannon, 30*15);
		
		// Kamikazes
		if( difficulty>=3 )
			repopMob(difficulty-2, 4, en.mob.Kamikaze, 30*20);
		
		// Bombardiers
		if( difficulty>=4 )
			repopMob(difficulty-2, 4, en.mob.Bomber, 30*15);
		
		// Fantômes
		if( difficulty>=5 )
			repopMob(difficulty-4, 5, en.mob.Ghost, 30*13);
		/***/
	}
	
	
	override public function update() {
		super.update();
		if( !cd.hasSet("repop", 10) )
			repop();
			
		while( timedEvents.length>0 && timedEvents[0].t<=time )
			timedEvents.splice(0,1)[0].cb();
			
		// Toutes les secondes
		if( !cd.hasSet("dt", AUTO_DIFF_FREQ.get()) )
			difficulty += skill * 1/30;
	}
}