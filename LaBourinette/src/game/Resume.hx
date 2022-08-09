package game;

typedef TeamResume = {
	var leaguePts : Int;
	var money : Int;
	var injures : Int;
	var bobos : Int;
	var itemsDestroyed : Int;
	var itemsDamaged : Int;
	var drugsUsed : Int;
	var hooligansVictories : Array<Int>;
	var hooligansDeads : Array<Int>;
	var corruptions : Int;
}

typedef Resume = Array<TeamResume>;