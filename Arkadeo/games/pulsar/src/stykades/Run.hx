package stykades;
import Protocol;
import mt.bumdum9.Lib;
import api.AKApi;
import api.AKProtocol;

class Run extends Stykades {
	var spawnDelay:Int;
	var deathLimit:Int;
	var dif:Float;
	var difInc:Float;
	var next:Int;
	var bonusCount:Int;
	
	public var progression:Float;
	public static var me:Run;
	
	public function new() {
		super();
		me = this;
		deathLimit = 80 + AKApi.getLevel() * 10;
		spawnDelay = 120 - 2 * AKApi.getLevel();
		difInc = 0.5 + AKApi.getLevel() / 20;
		next = 15;
		dif = next;
		bonusCount = 0;
		// START SPAWN
		if( Game.me.have(AMBUSH_TANK) ) {
			for( k in 0...2) {
				for( di in 0...4 ) {
					var max = [Game.HEIGHT - Game.BORDER_Y * 2, Game.WIDTH - Game.BORDER_X * 2][di % 2];
					var n = (k + 1) * (max / 3);
					var pos = Game.me.borderToPos(di, n);
					var e = new fx.Spawn(TANK, pos.x, pos.y);
					e.borderPos = { di:di, n:n };
				}
			}
		}
	}
	
	override function update() {
		super.update();
		// EMPTY SCREEN
		var bads = Game.me.bads.length + fx.Spawn.ALL.length;
		var lim = 8;
		if( bads < lim ) {
			next -= (lim - bads);
		}
		// BONUS
		if( bonusCount == 0 && Game.me.seed.random(250)  == 0 ) {
			bonusCount++;
			new fx.Bonus();
		}
		var delay = spawnDelay;
		// INC DIF
		var co = death / deathLimit;
		dif += ( 1 + co * difInc ) * Cs.DIFFICULTY_COEF_PROGRESSION ;
		if( dif > next ) {
			next = delay + Game.me.seed.random(delay);
			spawnRandom();
		}// AUTOSPAWN
		else if( (Game.me.have(AUTOSPAWN_GYRO)) && (age % delay) == 0 ) 		new fx.Spawn(GYRO, Game.WIDTH >> 1, Game.HEIGHT >> 1);
		else if( (Game.me.have(AUTOSPAWN_FOLLOWER)) && (age + 20) % 40 == 0 ) 	new fx.Spawn(FOLLOWER, Game.WIDTH >> 1, Game.HEIGHT >> 1);
		// PROGRESSION
		progression = co;
		AKApi.setProgression( co );
		// END
		if( co >= 1 ) win();
	}
	
	override function launch(data:DataWave) {
		// DIF
		var sum = 0.0;
		for( bt in data.bads) {
			var bdata = Bad.DATA[Type.enumIndex(bt)];
			sum += bdata.dif;
		}
		sum *= data.max;
		sum /= data.bads.length;
		dif -= sum*20;
		super.launch(data);
	}
	
	function win() {
		Game.me.hero.invincible = true;
		Game.me.hero.shooting = false;
		var wave = new seq.WinWave();
		wave.onFinish = callback( AKApi.gameOver, true);
		AKApi.saveState(Game.me.runState);
		kill();
	}
}
