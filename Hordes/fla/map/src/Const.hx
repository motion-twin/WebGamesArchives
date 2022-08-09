import MapCommon;

class Const implements haxe.Public{
	static var uniq			= 0;
	static var DP_BG		= uniq++;
	static var DP_FOG		= uniq++;
	static var DP_FX		= uniq++;
	static var DP_INTERF	= uniq++;
	static var DP_TOP		= uniq++;

	static var WID			= 300;
	static var HEI			= 300;
	static var CWID			= 100;
	static var CHEI			= 100;
	static var MWID			= 12;
	static var MHEI			= 12;
	static var BGWID		= 6; // background texture width in squares
	static var BGHEI		= 6;

	static var BIG_MAP_WID	= 17; // width à partir de laquelle une map est considérée comme "big"

	static var OFF_ALPHA	= 60;
	static var BLACK_ALPHA	= 90;

	static var BUILDING_NAMES	: Array<String> = null;

	static var HORRIBLE_WORDS	= [
		"Psychoses",
		"Démence",
		"Agonie",
		"Boire",
		"Dormir",
		"Sang",
		"Rage",
		"Haine",
		"Tuer",
		"Tues-les",
		"Meurtre",
		"Drogues",
		"La mort t'attend",
		"Tu vas mourir",
		"Tu mourras cette nuit",
		"Rejoins les ombres",
		"Cauchemars",
		"Mutilations",
		"Aucun espoir",

		"Ils t'espionnent",
		"Ils veulent ta mort",
		"Ne leur fais pas confiance",
		"Enfuis toi loin",
		"Ne les écoute pas",
		"Ils te tueront",
		"Ton voisin veut ta mort",
		"Ils veulent te pendre",
		"Ils vont te tuer",
		"Tu y passeras",
		"Goûte leur sang",
		"On t'observe",
		"Ils sont FOUS",
		"On veut ta peau",
		"Goûte leur chair",
		"Manges en un",
		"Tues en un",
		"Fais lui payer",
		"Venge-toi",
		"Trahis-les",
		"Sans pitié",
		"Je ne suis pas fou",
		"Je ne vois rien",
		"Ils sont fous",
		"A mort",
		"Tue les tous",
		"Ils mourront",
		"Qu'ils meurent",
		"Dévore-les",
		"Abandonne",
	];



	/*------------------------------------------------------------------------
	INITIALIZE
	------------------------------------------------------------------------*/
	static function init(bl:Array<OutMapBuildings>, cityName:String) {
		BUILDING_NAMES = new Array();
		for (b in bl) {
			BUILDING_NAMES[b._id] = b._n;
		}
		BUILDING_NAMES[1] = cityName;
//		var codec = new mt.net.Codec("=(154+Zx187°%6");
//		var str = Std.resource("xml_buildings");
//		str = codec.run(str);
//		str = StringTools.urlDecode(str);
//		var xml = Xml.parse(str);
//		BUILDING_NAMES = new Array();
//		var doc = new haxe.xml.Fast( xml.firstElement() );
//		for (b in doc.nodes.building) {
//			BUILDING_NAMES[Std.parseInt(b.att.id)] = b.att.name;
//		}
	}

}
