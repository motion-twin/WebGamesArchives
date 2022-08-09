package data;

typedef FightStat = {
	var side			: Bool;
	var dino			: Int;
	var user			: Int;
	var dead 			: Bool;
	//counts
	var attacks 		: Int;
	var groupAttacks 	: Int;
	var counters 		: Int;
	var multis			: Int;
	var assaults 		: Int;
	var startLife		: Int;
	//shall we instead store startLife, because finalLife would be startLife - lostLife
	var finalLife		: Int;
	//should be easy to compute with incured sum, mais kept for debug and test
	var lostLife		: Int;
	var regeneratedLife	: Int;
	var esquives 		: Int;
	//status
	var poison 			: Int;
	var stoned			: Int;
	var sleep			: Int;
	//real sum of damages and incured
	var given	 		: Array<{count:Int, lost:Int}>;
	var received 		: Array<{count:Int, lost:Int}>;
	
}