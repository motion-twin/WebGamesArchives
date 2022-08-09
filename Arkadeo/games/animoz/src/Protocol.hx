import Protocol;
import mt.bumdum9.Lib;

@:build( ods.Data.build("data.ods", "animals", "id", { prefix : "_" }) ) @:native("_aa") enum BallType { }

typedef DataBall = {
	id		: BallType,
	//name	: String,
	//desc : String,
}

typedef DataText = {
	id		: Int,
	txt		: String,
}

typedef RoundRules = {
	notPlayable	: Array<BallType>,
	blockEffect	: Array<BallType>,
}

typedef RunState = {
	pool	: Array<BallType>,
}
