package stykades;
import Protocol;
import mt.bumdum9.Lib;
import api.AKApi;
import api.AKProtocol;

class Score extends Stykades {
	
	var timeLimit:Int;
	var bonusCount:Int;
	var dif:Float;
	var difInc:Float;
	var next:Int;
	var chrono:Chrono;
	var spawnDelay:Int;
	var difficultyUpgrades:Int;
	var difficultyLocked:Bool;
	
	var difficultyTimeProgress:Float;
	
	inline static var DIFFICULTY_COOLDOWN = 100;
	inline static var DURATION = 8000;
	
	var upgrades : Array<UpgradeType>;
	public function new() {
		super();
		timeLimit = DURATION;
		spawnDelay = 80;
		
		bonusCount = 0;
		difficultyLocked = true;
		difficultyTimeProgress = (Cs.DIFFICULTY_COEF_LEAGUE_MAX - Cs.DIFFICULTY_COEF_LEAGUE) / timeLimit;
		difInc = 2.5;
		next = 10;
		dif = 10;
		chrono = new Chrono();
		chrono.timer = timeLimit;
		chrono.display();
		upgrades =  [LORD_SPAWN_BONUS, DIAGON_EGG_BONUS, RAPTOR_FIRE, TANK_ARC, FOLLOWER_DIVIDE, SHIELD_REFLECT];
	}
	
	override function update() {
		super.update();
		// CHRONO
		chrono.timer = timeLimit - age;
		if( Game.me.timer % 10 == 0 ) chrono.display();
		// BONUS
		if( bonusCount * 1000 < age && Game.me.seed.random(300 + 300 * bonusCount)  == 0 ) {
			bonusCount++;
			new fx.Bonus();
		}
		
		#if dev
		api.AKApi.setStatusText( "difficulté : " + Std.int(100 * Cs.DIFFICULTY_COEF_LEAGUE ) / 100);
		#end
		
		var lim = 8;
		// EMPTY SCREEN
		var bads = Game.me.bads.length + fx.Spawn.ALL.length;
		if( bads < lim && !difficultyLocked ) {
			Cs.DIFFICULTY_COEF_LEAGUE += Cs.DIFFICULTY_PROGRESS;
			difficultyLocked = true;
		} else if( bads >= lim ) {
			difficultyLocked = false;
		}
		
		if( bads < lim ) {
			next -= (lim - bads);
		}
		
		// INC DIF
		Cs.DIFFICULTY_COEF_LEAGUE += difficultyTimeProgress;
		
		var co = age / timeLimit;
		dif += ( 1 + co * difInc ) * Cs.DIFFICULTY_COEF_LEAGUE ;
		
		if( dif > next ) {
			var delay = spawnDelay;
			next = delay + Game.me.seed.random(delay);
			spawnAll();
		}
		// END
		if( age == timeLimit ) win();
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
		dif -= sum * 20;
		
		super.launch(data);
	}
	
	override function onPower(?t) {
		if( t == TEMPO ) timeLimit += 1200;
		chrono.display();
	}
	
	function win() {
		//BONUS de points car victoire au temps
		AKApi.addScore( AKApi.const( Std.int( AKApi.getScore() * Cs.LEAGUE_TIME_BONUS_PERCENT ) ) );
		//
		Game.me.hero.invincible = true;
		Game.me.hero.shooting = false;
		var wave = new seq.WinWave();
		wave.onFinish = callback( AKApi.gameOver, true);
		AKApi.saveState(Game.me.runState);
		kill();
	}
}
