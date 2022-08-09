class Level {
	public var goal : Int;
	public var dogSpeed : Float;
	public var dogLazerLength : Float;
	public var dogLazerSpeed : Float;
	public var sparksSpeed : Float;
	public var lazerSparkSpeed : Float;
	public var lazerSparkDelay : Float;

	public function new(d){
		goal = d.goal;
		dogSpeed = d.dogSpeed;
		dogLazerSpeed = d.dogLazerSpeed;
		dogLazerLength = d.dogLazerLength;
		sparksSpeed = d.sparksSpeed;
		lazerSparkSpeed = d.lazerSparkSpeed;
		lazerSparkDelay = d.lazerSparkDelay;
	}

	static var data = [
		new Level({
			goal:50,
			dogSpeed: 0.9 *  Game.FAST_SPEED,
			dogLazerLength: 110,
			dogLazerSpeed: 5,
			sparksSpeed: 0.5 *  Game.FAST_SPEED,
			lazerSparkSpeed: 0.6 * Game.SLOW_SPEED,
			lazerSparkDelay: 2000.0,
		}),
		new Level({
			goal:60,
			dogSpeed: 1.1 *  Game.FAST_SPEED,
			dogLazerLength: 115,
			dogLazerSpeed: 5.5,
			sparksSpeed: 0.7 *  Game.FAST_SPEED,
			lazerSparkSpeed: 0.7 * Game.SLOW_SPEED,
			lazerSparkDelay: 1800.0,
		}),
		new Level({
			goal:70,
			dogSpeed: 1.3 *  Game.FAST_SPEED,
			dogLazerLength: 120,
			dogLazerSpeed: 6,
			sparksSpeed: 1 *  Game.FAST_SPEED,
			lazerSparkSpeed: 0.8 * Game.SLOW_SPEED,
			lazerSparkDelay: 1600.0,
		}),
		new Level({
			goal:75,
			dogSpeed: 1.5 *  Game.FAST_SPEED,
			dogLazerLength: 120,
			dogLazerSpeed: 6.5,
			sparksSpeed: 1.1 *  Game.FAST_SPEED,
			lazerSparkSpeed: 0.9 * Game.SLOW_SPEED,
			lazerSparkDelay: 1400.0,
		}),
		new Level({
			goal:80,
			dogSpeed: 1.7 *  Game.FAST_SPEED,
			dogLazerLength: 120,
			dogLazerSpeed: 7,
			sparksSpeed: 1.2 *  Game.FAST_SPEED,
			lazerSparkSpeed: 1.0 * Game.SLOW_SPEED,
			lazerSparkDelay: 1200.0,
		}),
		new Level({
			goal:85,
			dogSpeed: 1.8 *  Game.FAST_SPEED,
			dogLazerLength: 120,
			dogLazerSpeed: 7.5,
			sparksSpeed: 1.3 *  Game.FAST_SPEED,
			lazerSparkSpeed: 1.1 * Game.SLOW_SPEED,
			lazerSparkDelay: 1000.0,
		}),
		new Level({
			goal:90,
			dogSpeed: 1.9 *  Game.FAST_SPEED,
			dogLazerLength: 125,
			dogLazerSpeed: 8,
			sparksSpeed: 1.4 *  Game.FAST_SPEED,
			lazerSparkSpeed: 1.2 * Game.SLOW_SPEED,
			lazerSparkDelay: 800.0,
		}),
		new Level({
			goal:90,
			dogSpeed: 1.9 *  Game.FAST_SPEED,
			dogLazerLength: 130,
			dogLazerSpeed: 8,
			sparksSpeed: 1.5 *  Game.FAST_SPEED,
			lazerSparkSpeed: 1.3 * Game.SLOW_SPEED,
			lazerSparkDelay: 800.0,
		}),
		new Level({
			goal:90,
			dogSpeed: 2.0 *  Game.FAST_SPEED,
			dogLazerLength: 135,
			dogLazerSpeed: 8,
			sparksSpeed: 1.6 *  Game.FAST_SPEED,
			lazerSparkSpeed: 1.4 * Game.SLOW_SPEED,
			lazerSparkDelay: 800.0,
		}),
		new Level({
			goal:90,
			dogSpeed: 2.1 *  Game.FAST_SPEED,
			dogLazerLength: 140,
			dogLazerSpeed: 8,
			sparksSpeed: 1.7 *  Game.FAST_SPEED,
			lazerSparkSpeed: 1.5 * Game.SLOW_SPEED,
			lazerSparkDelay: 800.0,
		}),
		new Level({
			goal:90,
			dogSpeed: 2.2 *  Game.FAST_SPEED,
			dogLazerLength: 150,
			dogLazerSpeed: 8,
			sparksSpeed: 1.8 *  Game.FAST_SPEED,
			lazerSparkSpeed: 1.5 * Game.SLOW_SPEED,
			lazerSparkDelay: 800.0,
		}),
	];

	public static function get(idx:Int){
		return data[Std.int(Math.min(data.length-1, idx))];
	}
}