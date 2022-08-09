package game;

enum DiceComment {
	Impale; // (+3) less than or equal 1/100 of limit
	Critical; // (+2) less than or equal 1/5 of limit
	GoodSuccess; // (+1) less than or equal 1/2 or limit
	NormalSuccess; // (+0) less than or equal limit
	MarginalFailure; // (-1) greater than limit but less than 1.5 limit
	SignificantFailure; // (-2) greater than 1.5 limit but less than 2 limit
	Fumble; // (-3) 99 or 100 (100 for above 100)
}

class DiceRoll {
	public var dices : Int;
	public var limit : Float;
	public var result : Int;
	public var success : Bool;
	public var comment : DiceComment;
	public function new(){
	}
	public function toString() : String {
		return result+"/"+limit+" => "+comment;
	}
}

#if !js

class Dice {
	public static var DONE_FACTOR = 2.5;
	public static var EASY_FACTOR = 2;
	public static var MEDIUM_FACTOR = 1;
	public static var HARD_FACTOR = 0.5;
	public static var HELL_FACTOR = 0.25;


	public static var D6 = new Dice(6);
	public static var D100 = new Dice(100);

	var max : Int;

	public function new( max:Int ){
		this.max = max;
	}

	public function roll( nDices:Int=1, ?seed:mt.Rand ) : Int {
		var sum = 0;
		for (i in 0...nDices)
			sum += 1 + (if (seed == null) Std.random(max) else seed.random(max));
		return sum;
	}

	public function rollAndComment( ?limit:Float, ?seed:mt.Rand ) : DiceRoll {
		var limit = if (limit == null) max / 2 else limit;
		var result = roll(1, seed);
		var comment = if (result <= 1/100 * limit) Impale
			else if (result <= 1/5 * limit) Critical
				else if (result <= 1/2 * limit) GoodSuccess
					else if (result <= limit) NormalSuccess
						else if (result < 1.5 * limit) MarginalFailure
							else if (result < 2 * limit) SignificantFailure
								else Fumble;
		var res = new DiceRoll();
		res.dices = 1;
		res.limit = limit;
		res.result = result;
		res.success = result <= limit;
		res.comment = comment;
		return res;
	}

	/*
	  Generate a difficulty factor for a roll depending of a previous roll.
	  This is a A+B factor, for instance the batter touch the ball with "comment".
	  How precise his throw will be.
	 */
	public static function successFactor(comment:DiceComment){
		return switch (comment){
			case Impale: DONE_FACTOR;
			case Critical: EASY_FACTOR;
			case GoodSuccess: EASY_FACTOR;
			case NormalSuccess: MEDIUM_FACTOR;
			case MarginalFailure: MEDIUM_FACTOR;
			case SignificantFailure: HARD_FACTOR;
			case Fumble: HELL_FACTOR;
		}
	}

	/*
	  This factor depends of an oponent's roll.
	 */
	public static function limitFactor(comment:DiceComment){
		return switch (comment){
			case Impale: HELL_FACTOR;
			case Critical: HARD_FACTOR;
			case GoodSuccess: MEDIUM_FACTOR;
			case NormalSuccess: MEDIUM_FACTOR;
			case MarginalFailure: EASY_FACTOR;
			case SignificantFailure: EASY_FACTOR;
			case Fumble: DONE_FACTOR;
		}
	}
}

#end