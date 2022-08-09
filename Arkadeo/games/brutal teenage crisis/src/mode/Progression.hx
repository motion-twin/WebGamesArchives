package mode;

import flash.display.Sprite;

import com.gen.LevelGenerator;
import Const;
import mt.deepnight.Lib;
import mt.deepnight.Color;

class Progression extends Mode {
	public var exit		: en.Exit;
	public var heroLeft	: Bool;
	public var lid		: Int;
	var powerUps		: Int;

	public function new(g) {
		lid = api.AKApi.getLevel();

		super(g);


		powerUps = 5 + Std.int(lid*0.03);
		heroLeft = false;
		hero.setCredits(3);
	}

	override function isProgression() {
		return true;
	}

	public function onExit() {
		fx.exit();
		hero.leaveGameArea();

		for(e in en.Mob.ALL)
			if( exit.atDistance(e, 200) )
				e.hit(exit.xx, exit.yy, 100);

		for(e in en.mob.Walker.ALL)
			if( e.climbing )
				e.hit(hero.xx, hero.yy, 1);

		delayer.add( function() {
			gameOver(true);
		}, 1500);
	}

	override function newLevel() {
		super.newLevel();

		diff = mt.MLib.round( 100 * lid/com.gen.LevelGenerator.MAX_LEVEL );

		level = new Level();
		level.generateProgression(lid);
		level.render();

		hero = new en.Hero();
		exit = new en.Exit(level.lgen.exit.cx, level.lgen.exit.cy);

		// Locks
		for( t in level.lgen.targets )
			switch( t.type ) {
				case LT_Silver : new en.mob.lock.Silver(t.cx, t.cy);
				case LT_Gold : new en.mob.lock.Golden(t.cx, t.cy);
				case LT_Movable : new en.mob.lock.Movable(t.cx, t.cy);
			}

		en.mob.Lock.prepareActionOrder();
		en.mob.Lock.activateNext();
		en.mob.Lock.activateNext();

		// First mobs
		addMob();

		// KP
		addKPoints();

		// Tutorial
		if( lid==1 ) {
			var lock = en.mob.Lock.ALL[0];
			var mob = en.mob.Walker.ALL[0];
			cine.create({
				tutorial(lock.cx, lock.cy, Lang.TutorialLocks) > end;
				tutorial(mob.cx, mob.cy, Lang.TutorialMobs) > end;
				end("heroLand");
				tutorial(hero.cx, hero.cy, Lang.TutorialHero) > end;
			});
		}
	}


	override function addPowerUp() {
		super.addPowerUp();
		if( powerUps>0 ) {
			powerUps--;

			var pt = level.getRandomSpotFar();

			var rlist = new mt.RandList();
			rlist.add( function() new en.it.Bomb(pt.cx, pt.cy), 100 );
			rlist.add( function() new en.it.SuperPower(pt.cx, pt.cy), 3 );
			rlist.add( function() new en.it.MegaBomb(pt.cx, pt.cy), 10 );
			rlist.draw(rseed.random)();

			nextPowerUp = Const.seconds(8);
		}
	}

	public function unlockExit() {
		exit.open();
	}

	public function addMob() {
		var pt = level.getRandomSpotFar( rseed.irange(0,1) );

		if( rseed.random(100)<3 )
			// Bonus bomber
			new en.mob.Bomber(pt.cx, pt.cy);
		else {
			// Random mob (based on generator)
			var needed = level.lgen.mobs.copy();
			for(e in en.Mob.ALL)
				needed.remove(e.type);

			if( needed.length==0 )
				return;

			var t = needed[rseed.random(needed.length)];

			switch( t ) {
				case MT_Simple		: new en.mob.Simple(pt.cx, pt.cy);
				case MT_Classic		: new en.mob.Classic(pt.cx, pt.cy);
				case MT_Big			: new en.mob.Big(pt.cx, pt.cy);
				case MT_Smart		: new en.mob.Smart(pt.cx, pt.cy);
				case MT_Bomber		: new en.mob.Bomber(pt.cx, pt.cy);
				case MT_Fly			: new en.mob.Fly();
			}
		}

		var d = countRealMobs()<5 ? Const.seconds(0.25) : Const.seconds(lid>50 ? 0.75 : 1);
		cd.set( "mobSpawn", d );
	}

	public function onMobKill() {
		cd.set("mobSpawn", cd.get("mobSpawn") + rseed.range(5,15));
	}

	inline function needMob() {
		return countRealMobs() < level.lgen.mobs.length;
	}

	override function update() {
		super.update();

		if( !hasTutorial() ) {
			// Respawn ennemis
			if( !hero.hasLeft && (countRealMobs()==0 || !cd.has("mobSpawn") && needMob()) )
				addMob();
		}
	}
}
