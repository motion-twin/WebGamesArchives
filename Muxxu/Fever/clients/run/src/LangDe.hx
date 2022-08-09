
class LangDe implements haxe.Public {//}
	
	static var 	ITEM_NAMES  = [
		"Cocktail", "Zauberbuch", "Schuhe", "Spiegel", "Klee", "Voodoo-Puppe", "Voodoo-Maske",
		"Stock", "Brille", "Radar", "Prisma", "FeverX", "Regenschirm", "Würfel",
		"Windmühle", "Synthetischer Lolli", "Sanduhr", "ChromaX", "Zauberstab", "Verzauberte Gabel", "Arianes Faden",
		"Ini-Rune","Sed-Rune","Aarg-Rune","Olh-Rune","Al-Rune","Laf-Rune","Hep-Rune"
	];
	
	static var 	ITEM_DESC  = [
		"Verringert die Temperatur zu Beginn der Partie um 10°",
		"Markiere ein Spiel, dass du vermeiden möchtest",
		"Verdopppelt deine Laufgeschwindigkeit",
		"Medusen können dich nicht mehr paralysieren",
		"Entdeckt Spielekartons in deiner Nähe",
		"Monster beginnen mit einem Herz weniger",
		"Monster flüchten zu Beginn des Kampfes mit 2% Wahrscheinlichkeit",
		
		"Öffnet grüne Truhen",
		"Zeigt die Spieleliste für das nächststehende Monster",
		"Zeigt deine Position und noch unentdeckte Inseln",
		"Verwandelt einen Eiswürfel in drei\nRegenbögen",
		"Die gefeierte FeverX Spielekonsole!",
		"Jeden Tag einen zusätzlichen Regenbogen",
		"Gib "+col("1","#FF0000")+" , um einen Eiswürfel zu gewinnen\nJeder Versuch kostet einen Regenbogen.",
		
		"Die Temperature steigt nicht, wenn du verlierst",
		"Jeden Tag einen zusätzlichen Eiswürfel",
		"+25% mehr Zeit in Puzzle-Spielen",
		"Die FeverX verbraucht zuerst Regenbögen",
		"Brutale Monster verursachen einen Punkt weniger Schaden",
		"10% Chance, pro Angriff 2 Herzen zu zerbrechen",
		"Teleportiert dich zur zuletzt berührten Statue. Kosten einen Regenbogen.",
		
		"Ein seltsamer Stein...",
		"Ein mysteriöser Stein...",
		"Ein geheimnisvoller Stein...",
		"Ein unbekannter Stein...",
		"Ein ungewöhnlicher Stein...",
		"Ein sonderbarer Stein...",
		"Ein unheimlicher Stein...",
	];
	
	static var BONUS_ISLAND_NAMES = [ "Fulgo", "Ignik", "Rasen" ];
	static var BONUS_ISLAND_DESC = [ "Vernichte das nächststehende Monster", "Vernichte alle Monster auf der Insel", "Vernichte alle Monster in einer Reihe" ];
	
	static var BONUS_GAME_NAMES = [ "Camemberk", "Vol-o-vent" , "Burilame", ];
	static var BONUS_GAME_DESC = [
		grey("Berühre "+pink("[C]")+" zwischen 2 Duellen:")+"\nErhalte alle Herzen zurück",
		grey("Berühre "+pink("[V]")+" während eines Duells:")+"\nFlüchte aus dem laufenden Minispiel",
		grey("Berühre "+pink("[B]")+" zwischen 2 Duellen:")+"\nFüge deinem Gegner einen Punkt Schaden zu"
	];
	static var BONUS_DAILY_NAMES = ["Regenbogen-Abonnement","Einswürfel-Abonnement"];
	static var BONUS_DAILY_DESC = [
		"Sammle einen " +pink(BONUS_GAME_NAMES[0]) + ", einen " + pink(BONUS_GAME_NAMES[1]) + " und einen " + pink(BONUS_GAME_NAMES[2]) + " , um jeden Tag einen zusätzlichen Regenbogen zu erhalten.",
		"Sammle einen " +pink(BONUS_ISLAND_NAMES[0])+", einen "+pink(BONUS_ISLAND_NAMES[1])+" und einen "+pink(BONUS_ISLAND_NAMES[2])+" um jeden Tag einen zusätzlichen Eiswürfel zu erhalten.",
		"Jeden Tag einen zusätzlichen Regenbogen",
		"Jeden Tag einen zusätzlichen Eiswürfel",
	];
	
	static var GODS = [
		"Koan", "Barchenold", "Piluvien", "Dumerost",
		"Chankron", "Malvenel", "Lifolet", "Tarabluff",
		"Sidron", "Chomniber", "Pata", "Droenix",
		"Lancurno","Jomil","Tokepo","Grazuli",
	];
	static var BLESS = "Das Auge von %1 wacht über dich";
	
	// ----------------- //
	
	static var PERMANENT_OBJECT = 	"Permanenter Gegenstand";
	static var NO_MORE_ICECUBE = 	"Du hast keine Eiswürfel mehr!";
	static var NO_MORE_RAINBOW = 	"Du hast keine Regenbögen mehr!";
	static var NO_CARTRIDGE = 		"Kein Spielekarton!";
	static var NO_STATUE = 			"Keine Statue entdeckt!";
	static var TOO_MUCH_RAINBOW = 	"Davon hast du schon genug!";
	static var NEED_KEY = 			"Du brauchst einen Schlüssel!";
	static var NEED_WAND = 		"Du brauchst einen Stock!";
	
	static var HEARTS_DESC  = [ "Herzcontainer", "Warenlager der gebrochenen Herzen", "x Herzstücke", "Sammle die fehlende Herzstücke und gewinne ein Extra-Leben"];

	// ----- //
	static var ENDING_TEXT = "Nach dem Sieg über den großen Bakelit steht Pusty nun das Dimensionsportal offen.\nDer tapferste aller Pinguine zögert keine Sekunde: Trotz der Wunden aus seinem letzten Kampf, setzt er seinen Fuß auf das mysteriöse Portal und watschelt voran...\nEin Meer von Farben umgibt Pusty ! Stück für Stück erholt sich das Energiefeld wieder. Nach einigen Metern scheint sich der Pfad in eine neue Welt zu öffnen! Eine vertraute Welt, aber...\nSogar von hier aus wirkt die Atmosphäre wenig freundlich. Unser tapsiger Held spürt die baldige Rückkehr von Bakelit... Und das wird kein Zuckerschlecken werden!";
	static var ENDING_QUESTION =  "Willst du beim Archipel von %1 bleiben und deine letzten Feinde vernichten, oder willst du den Sprung zu %2 und in ein neues Abenteuer wagen?";
	static var ENDING_EXPLORE = "Zurück zu %1";
	static var ENDING_LEAVE_TO = "Auf nach %1";
	
	static var ARCHIPELS =  ["Gonkrogme","Sultura","Baniflok","Grizantol","Marshoukrev","Dishigan","Lakulite","Koleporsh","Murumuru","Frisantheme","Zulebi"];
	
	static var GENERIC_ERROR = "Ein Fehler ist aufgetreten. Bitte starte das Spiel neu." ;
	
	static var CREATE_WORLD = "Welt wird erstellt...";
	static var CHECK_INVENTORY = "Inventar zeigen";
	static var BACK_TO_GAME = "Zurück zum Spiel";
	static var ISLAND = "Insel";
	static var NO_MONSTER = "Weit und breit kein Monster!";
	static var FEVER_X_LABELS = ["Spielen","Level"];
	static var SELECT_STEP = "Wähle\n ein Level";
	static var SERVER_CNX = "Verbindung zum Server...";
	
	
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


