package data;

enum ExploKind {
	Bunker;
	Hotel;
	Hospital;
}

enum ExploResourceKind {
	Common;
	Rare;
	Unusual;
}

enum ExploDoorKind {
	Normal;
	ClassicKey;
	MagneticKey;
	BumpKey;
}

typedef ExploCell = {
	var walkable: Bool;
	var zombies : Int;
	var kills	: Int;
	var room 	: Null<ExploRoom>;
	var details : Int;// seed pour la génération des détails random
}

typedef ExploRoom = {
	var locked	: Bool;
	var doorKind: ExploDoorKind;
	var drops	: List<String>;
	var distance: Int;
}
