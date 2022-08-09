package mode;


import flash.display.Sprite;

import Const;
import mt.deepnight.Lib;
import mt.deepnight.Color;

class League extends Mode {

	public function new(g) {
		super(g);
		hero.setCredits(3);
		nextPowerUp = Const.seconds(6);
	}

	override function isLeague() {
		return true;
	}

	override function newLevel() {
		super.newLevel();
		level = new Level();
		level.readFromFile(0);
		level.render();

		cd.unset("mobSpawn");

		hero = new en.Hero();

		addKPoints();
	}

	override function addPowerUp() {
		super.addPowerUp();

		var pt = level.getRandomSpotFar();

		var rlist = new mt.RandList();
		rlist.add( function() new en.it.Bomb(pt.cx, pt.cy), 100 );
		rlist.add( function() new en.it.SuperPower(pt.cx, pt.cy), 5 );
		rlist.add( function() new en.it.MegaBomb(pt.cx, pt.cy), 10 );
		rlist.draw(rseed.random)();

		nextPowerUp = Const.seconds( rseed.range(5,7) );
	}

	public inline function getMaxMobs() {
		return Std.int( 3 + diff*0.05 );
	}

	public function addMob() {
		var pt = level.getRandomSpotFar( rseed.irange(0,1) );

		var rlist = new mt.RandList();
		// Petit lent
		rlist.add( function() new en.mob.Simple(pt.cx, pt.cy), Std.int(Math.max(0, 500 * (1-diff/20))) );

		// Normal
		rlist.add( function() new en.mob.Classic(pt.cx, pt.cy), 100 );

		// Explosif
		rlist.add( function() new en.mob.Bomber(pt.cx, pt.cy), 3 );

		// Gros
		if( diff>=50 && en.mob.Big.COUNT<2 )
			rlist.add( function() new en.mob.Big(pt.cx, pt.cy), 10 );

		// Intello
		if( diff>=90 )
			rlist.add( function() new en.mob.Smart(pt.cx, pt.cy), 10 );

		// Volant
		if( diff>=250 )
			rlist.add( function() new en.mob.Fly(), 10 );

		rlist.draw(rseed.random)();
		var d = 30 * ( 0.25 + 1.25 * Math.max(0, 1-diff/60) );
		cd.set( "mobSpawn", d );
	}

	override function update() {
		super.update();

		if( !hasTutorial() ) {
			// Respawn ennemis
			if( !cd.has("mobSpawn") && countRealMobs() < getMaxMobs() )
				addMob();

			// Montée auto de la difficulté
			var diffFreq : Float = Const.AUTODIFF;
			diffFreq -= 15*skill;
			if( !cd.hasSet("autoDiff", diffFreq) )
				diff++;
		}
	}

}
