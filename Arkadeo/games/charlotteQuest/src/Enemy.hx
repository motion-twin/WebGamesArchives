import Entity;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

class Enemy extends Entity {
	public static var WAVE_ID = 0;
	public static var WAVES : Array<{total:Int, list:Array<Enemy>}> = [];

	var score			: api.AKConst;
	var waveId			: Int;
	var wrand			: mt.Rand;
	public var hasToBeKilled	: Bool;
	public var hitsPlayer		: Bool;
	
	public function new() {
		super();
		
		waveId = WAVE_ID;
		var wave = getWave();
		wave.total++;
		wave.list.push( this );
		wrand = new mt.Rand(0);
		wrand.initSeed( game.seed + waveId*109 );
		alertOutside = wave.list.length==1;
		hitsPlayer = true;
		score = api.AKApi.const(1);
		
		initLife(2);
		game.enemies.add( this );
		hasToBeKilled = true;
		game.sdm.add(spr, Game.DP_ENEMY);
		autoKill = LeaveScreen;
	}
	
	public static function initWave() {
		WAVES[ ++WAVE_ID ] = {
			total : 0,
			list : new Array(),
		}
	}

	public override function toString() { return "Enemy#"+uid; }
	
	public override function unregister() {
		super.unregister();
		game.enemies.remove(this);
	}
	
	public inline function getWave() {
		return WAVES[waveId];
	}
	
	public inline function waveCount() {
		return WAVES[waveId].list.length;
	}
	
	public function waveKilled() {
		return getWave().list.length==0;
	}
	
	function getRandomPopSide(popLevel:Int) : Int {
		if( game.isLeague() )
			// Toutes directions
			return wrand.random(4);
		else if( game.glevel==popLevel )
			// Droite
			return 1;
		else if( game.glevel<popLevel+8 ) {
			// Direction du couloir + côtés
			var next = game.curRoom.getNextDir();
			var dirs =
				if( next.dx==1 ) [0,1,2];
				else if( next.dx==-1 ) [0,3,2];
				else if( next.dy==1 ) [1,2,3];
				else [3,0,1];
			return dirs[ wrand.random(dirs.length) ];
		}
		else
			// Toutes directions
			return wrand.random(4);
	}
	
	function getOppositeDir(dir:Int) {
		return switch( dir ) {
			case 0 : 2;
			case 1 : 3;
			case 2 : 0;
			case 3 : 1;
			default : throw "dir"+dir;
		}
	}
	
	
	public override function checkHit(e:Entity, precise) {
		return
			if( hasCD("shield") || e.hasCD("shield") )
				false;
			else
				super.checkHit(e, precise);
	}

	public override function onDie() {
		super.onDie();
		getWave().list.remove(this);
		//fx.bigHit(this);
		var pt = getPoint();
		if( game.perf>=0.9 ) {
			var mc = fx.anim( new lib.Puf(), pt.x, pt.y );
			mc.blendMode = flash.display.BlendMode.ADD;
		}
		
		if( game.perf>=0.75 )
			fx.splash(game.player, this);
	
		if( waveKilled() )
			game.addSkill(0.2);
		else
			game.addSkill(0.03);
	}
	
	public override function hit(pow, ?from) {
		if( hasCD("shield") )
			return;
		super.hit(pow, from);
		setCD("shield", 1);
		if( game.isLeague() )
			game.addScore(score);
	}
	
	public override function update() {
		super.update();
		

		if( hitsPlayer && checkHit(game.player, true) && !game.player.hasCD("shield") ) {
			kill();
			if( !game.player.hasCD("uber") )
				game.player.hit(1, this);
		}
	}
}

