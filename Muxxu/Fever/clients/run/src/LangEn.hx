
class LangEn implements haxe.Public {//}
	
	static var 	ITEM_NAMES  = [
		"Cocktail", "Spell Book", "Shoes", "Mirror", "Clover", "Voodoo Doll", "Voodoo Mask",
		"Wand",	"Sunglasses", "Radar", "Prism", "FeverX", "Umbrella", "Dice",
		"Windmill", "Synthetic Ice Lolly", "Hourglass", "ChromaX", "Magic Wand", "Enchanted Fork", "Ariadne's Thread",
		"Ini Rune","Sed Rune","Arg Rune","01h Rune","Al Rune","Laf Rune","Hep Rune"
	];
	
	static var 	ITEM_DESC  = [
		"Lowers the temperature at the start of the match by 10°",
		"Select a game you wish to block",
		"Doubles walking speed",
		"Jellyfish can no longer paralyse you",
		"Detects nearby game cartridges",
		"Monsters start with one less heart",
		"Monsters have a 2% chance of running away at the start of the fight",		// TODO
		
		"Opens green chests",
		"Reveals the game list for the closest monster",
		"Shows your position and the islands you have discovered",
		"Transforms an ice cube into three\rainbow",
		"The awesome FeverX console!",
		"An extra rainbow every day",
		"Get "+col("1","#FF0000")+" to win an ice cube\nEach attempt costs one rainbow",
		
		"When you lose a duel, the temperature doesn't increase",
		"An extra ice cube every day",
		"25% more time on puzzle games",
		"The FeverX uses rainbows first",
		"Brutal monsters inflict one point of damage less",
		"10% chance of breaking two hearts in one attack",
		"Teleports you to the last statue you touched. Costs one rainbow",
		
		"A strange stone...",
		"A mysterious stone...",
		"An enigmatic stone...",
		"An unknown stone...",
		"An unusual stone...",
		"A solitary stone...",
		"A rolling stone...",
	];
	
	static var BONUS_ISLAND_NAMES = [ "Fulgor", "Ignik", "Razir" ];
	static var BONUS_ISLAND_DESC = [ "Destroy the closest monster", "Destroy all monsters on the island", "Destroy all the monsters on the same row" ];
	
	static var BONUS_GAME_NAMES = [ "Camemberk", "Vol-au-vent" , "Blade", ];
	static var BONUS_GAME_DESC = [
		grey("Hit "+pink("[C]")+" between two challenges :")+"\nRestores all your hearts",
		grey("Hit "+pink("[V]")+" during a challenge :")+"\nEscape from the mini-game in course",
		grey("Hit "+pink("[B]")+" between two challenges :")+"\nInflicts one point of damage on your enemy"
	];
	static var BONUS_DAILY_NAMES = ["Rainbow subscription","Ice cube subscription"];
	static var BONUS_DAILY_DESC = [
		"Collect a " +pink(BONUS_GAME_NAMES[0]) + ", a " +pink(BONUS_GAME_NAMES[1]) + " and a " +pink(BONUS_GAME_NAMES[2]) + " to receive an extra rainbow every day.",
		"Collect a " +pink(BONUS_ISLAND_NAMES[0])+ ", an " +pink(BONUS_ISLAND_NAMES[1])+ " and a " +pink(BONUS_ISLAND_NAMES[2]) + " to receive an extra ice cube every day.",
		"One extra rainbow every day",
		"One extra ice cube every day",
	];
	
	static var GODS = [
		"Koan", "Barchenold", "Piluvien", "Dumerost",
		"Chankron", "Malvenel", "Lifolet", "Tarabluff",
		"Sidron", "Chomniber", "Pata", "Droenix",
		"Lancurno","Jomil","Tokepo","Grazuli",
	];
	static var BLESS = "The eye of %1 watches over you";
	
	// ----------------- //
	
	static var PERMANENT_OBJECT = 	"Permanent object";
	static var NO_MORE_ICECUBE = 	"You have no ice cubes remainng!";
	static var NO_MORE_RAINBOW = 	"You have no rainbows remaining!";
	static var NO_CARTRIDGE = 		"No game cartridges!";
	static var NO_STATUE = 			"No statues discovered!";
	static var TOO_MUCH_RAINBOW = 	"You already have enough!";
	static var NEED_KEY = 			"You need a key!";
	static var NEED_WAND = 		"You need a wand!";
	
	static var HEARTS_DESC  = [ "Cardiac Chamber", "Warehouse of abandoned hearts", "x quarter hearts", "Collect the missing quarters to earn an extra life"];

	// ----- //
	static var ENDING_TEXT = "With the great Bakelite sergeant destroyed, the dimensional portal reaches out to Pousty.\nThe bravest of penguins doesn't hesitate for a moment: despite the injuries sustained in his last fight, it is with a determined step forward that his webbed foot crosses the mysterious portal...\nA myriad of colour engulfs Pousty! Little by little, the energy field calms again. After a few metres, the passage seems to open into another world! It looks like this one, although... \nEven from here, the atmosphere feels less welcoming. Our web-footed hero senses the return of Bakelite, and this time, we're playing for keeps!";

	static var ENDING_QUESTION =  "Do you want to stay on %1 to eliminate the last remaining enemies, or take the leap to %2 for a new adventure?";
	static var ENDING_EXPLORE = "Returning to %1";
	static var ENDING_LEAVE_TO = "Leaving for %1";
	
	static var ARCHIPELS =  ["Gonkrogme","Sultura","Cabanas","Grizantol","Marshoukrev","Dishigan","Lakulite","Koleporsh","Murumuru","Frisantheme","Zulebi"];
	
	static var GENERIC_ERROR = "A error has occured. Please restart the game." ;
	
	static var CREATE_WORLD = "generating world...";
	static var CHECK_INVENTORY = "show inventory";
	static var BACK_TO_GAME = "back to the game";
	static var ISLAND = "island";
	static var NO_MONSTER = "no monsters in sight!";
	static var FEVER_X_LABELS = ["play","level"];
	static var SELECT_STEP = "select\n  a level";
	static var SERVER_CNX = "connecting to server...";
	
	
	static function col(str,col) {
		return "<font color='"+col+"'>"+str+"</font>";
	}
	static function grey(str) {
		return col(str,"#777777");
	}
	static function pink(str) {
		return col(str,"#FF00FF");
	}
	
	static function rep(str, a, b="b", c="c", d="d") {
		str = StringTools.replace(str, "%1", a);
		str = StringTools.replace(str, "%2", b);
		str = StringTools.replace(str, "%3", c);
		str = StringTools.replace(str, "%4", d);
		return str;
	}
	
	
	static public function init() {
		
		var c:Dynamic = null;
		#if fr
		return;
		#elseif en
		c = LangEn;
		#elseif de
		c = LangDe;
		#elseif es
		c = LangEs;
		#end
		
		for( f in Type.getClassFields(c) ) {
			var v : Dynamic = Reflect.field(c, f);
			if( Reflect.isFunction(v) ) continue;
			Reflect.setField(Lang, f, v );
		}
	}
		
	
	
//{
}


