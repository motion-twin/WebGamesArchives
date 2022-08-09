enum GEventKind {
	IsleWon(pid:Int); // pid conquers a new island
	IsleRaz(pid:Int, oid:Int); // pid raz the island of oid
	Frag(pid:Int, oid:Int); // pid kills oid
	Giveup(pid:Int); // pid gives up
}

typedef GEvent = {
	var tick : Int;
	var date : Float;
	var kind : GEventKind;
}