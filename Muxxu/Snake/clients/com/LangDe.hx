import Protocole;

class LangDe implements haxe.Public
{//}
	static var PIX = "<font color='#92d930'>.</font>";
	static var PIX2 = "<font color='#52b31e'>.</font>";
	static var DARK_PINK = "#FF8888";
	static var PINK = "#FFAAAA";
	static var WHITE = "#FFFFFF";

	static var MOJO_LEFT = "Übrige Mojos";
	static var MOJO_FULL = "Überzählige Mojo";
	static var CARD_LEFT = "Nicht genügend Karten: ";
	static var CARD_FULL = "Zuviele Karten: ";
	static var START_GAME = "Partie beginnen";
	
	static var SELECT_CARDS = "Gib alle deine Mojopunkte aus, um die Partie zu beginnen.";
	static var TOO_MUCH_CARDS = "Du musst einige Karten ablegen, bevor du eine Partie spielen kannst.";
	
	static var EACH_USE = "Bei jedem Gebrauch: ";
	static var I_SUBSCRIBE = "Ich bin dabei!";

	static var UP_LEVEL = "Lev." ;
	
	static var BROWSER_PARAMS = [ "Nach Preis sortieren", "Zu teure Karten verbergen", "Regenerierende Karten verbergen" ];
	static var BROWSER_TUTO = "Gib deine 6 Mojopunkte für Karten aus.";
	static var BROWSER_NO_CARD = "Du erreichst mit deinen ausgewählten Karten"+PIX2+" keine 6 Mojopunkte"+PIX2+".\n Um Mitternacht stehen dir alle Karten wieder zur Verfügung!\n\nIn der Boutique kannst du außerdem zusätzliche "+PIX2+" Karten kaufen:";
	static var BROWSER_HAND_LIMIT = "Du kannst nur %0 der Karten spielen.";
	static var BROWSER_MULTI_LIMIT = "Du kannst diese Karte nur einmal einsetzen.";
	static var BROWSER_MIDNIGHT = "Diese Karte wird dir um Mitternacht wieder zur Verfügung stehen.";
	static var BUY_CARD = "Eine Karte kaufen";
	static var BUY = "kaufen";
	
	static var SUCCESS = "Aufgabe erledigt!";
	static var FRUIT_UNKNOWN = "unbekannte Frucht";

	static var FRUIT_TAGS = ["Zucker", "Rot", "Blatt", "Klein", "Nuss", "Blüte", "Zitrus", "Grüne", "Liane", "Alien", "Beere", "Lang", "Kürbis", "Birne", "Blau","Apfel","Kacke"];
	
	static var CONTROL = "Steuerung";
	static var CHOOSE_CONTROL = "Wähle deine Steuerung aus:";
	static var CONTROL_NAMES = ["Maus","Tastatur A","Tastatur B"];
	static var DESC_CONTROL = [
			"Die Schlange folgt dem "+pink("Maus")+"-Zeiger. Beschleunige mit der "+pink("linken")+" Maustaste.",
			"Drücke die Pfeiltasten "+pink("oben unten links")+" und "+pink("rechts")+", um die Schlange zu lenken.\n Mit der "+pink("Leertaste")+" kannst du beschleunigen.",
			"Drücke die "+pink("linke")+" und "+pink("rechte")+" Pfeiltaste, um die Schlange zu drehen.\n Mit der"+pink("oben")+" Pfeiltaste kannst du beschleunigen.",
			pink("Konzentriere dich")+" auf einen Punkt im Spielfeld, um die Schlange dorthin zu bewegen.\nUm zu beschleunigen, konzentriere dich "+pink("stärker")+".",
	];
	static var PAUSE_TITLE = 	"Pause";
	static var PAUSE_OFF = 		"Fortführen";
	static var GORE = 			"Blut";
	static var YES = 			"Ja";
	static var NO = 			"Nein";
	static var QUIT = 			"Beenden";
	static var OPTIONS = 		"Optionen";
	
	static var STATS = ["Spielzeit", "Eingesammelte Fruechte", "Vollstaendige Fruchtleiste", "Maximale Laenge"];
	static var SECTION_FRIENDS = "Meine Freunde";
	static var SECTION_ARCHIVE = "Mein Archiv";
	static var SECTION_TOP = "Pantheon";

	static var SECTION_DRAFT = "Mein Turnier";
	static var SECTION_RAINBOW = "Regenbogen"; 
	
	static var CNX_IMPOSSIBLE = "Verbindung unmöglich"; //NEW
	static var CNX_TRY = "Wartet...";					//NEW 

	// NEW
	static var LOADING = "Lädt...";
	static var ENCYLOPEFRUIT_PROGRESSION = "Fruchtlexikon";
	static var BONUS = "Bonus";
	static var PLAY_AGAIN = "Nochmal spielen";
	static var LENGTH_UNIT = "cm";
	static var TRAINING_GAME = "Testpartie";
	static var TRAINING_INSTRUCTION = "In dieser Testpartie kannst du dich mit der Steuerung vertraut machen.\nNach jedem Tod kannst du die Steuerungsart wechseln.";
	
	static var CAL_UNIT = "Kalorien";
	static var WEIGHT_UNIT = "mg";
	static var FRUIT_PROPS = ["Score", "Vitamine", "Naehrwert", "Haltbarkeit"];
	static var TIME_UNIT = "Sek";
	
	static var CARD_PRICE = "Kartenpreis: ";
	static var DRAW = "Es wird gerade eine Karte gezogen...";
	static var CARD_ADDED = "Die Karte wurde deiner Sammlung hinzugefügt.";
	static var NOT_ENOUGH_TOKEN = "Dir fehlen einige Jetons!";
	
	static var TIME_INTERVAL = ["Diese Woche", "Diesen Monat", "Dieses Jahr"];
	
	// COLLECTIONS
	static var PAGE = "Seite";
	static var CARDS = "Karten";
	static var COMPLETION = "Vollständig";
	static var COLLECTION_SECTIONS = ["Sammlung","Boutique","Tombola", "Basar"];
	static var LOTTERY_DESC = "Jeden Tag um Mitternacht wird unter allen Lotterie-Teilnehmern die Karte des Tages verlost.";
	static var YESTERDAY_WINNER = "Gestriger Gewinner: ";
	static var COLLECTION_TITLE_SHOP = 		"Die Schlangenboutique";
	static var COLLECTION_TITLE_LOTTERY = 	"Die Tombola";
	static var COLLECTION_TITLE_BAZAR = 	"Der Basar von Mephistouf"; //Mephistouf
	static var SHOP_ITEMS = ["Zusätzliche Karte", "Päckchen mit 10 Karten", "Lotterielos"];
	static var SHOP_DESC = [
		"Die Karte wird zufällig gezogen:\n- Gewöhnliche Karte: 60%\n- Normale Karte: 30%\n- Seltene Karte: 10%",
		"Zufällig gezogenes Päckchen mit 10 Karten:\n -6x gewöhnliche Karten\n- 3x normale Karten \n- 1x seltene Karte",
		"Ein Lotterielos für die Karte des Tages!\nDie Ziehung ist heute um Mitternacht...",
	];
	static var DAILY_CARD = "Karte des Tages:";
	static var LOTTERY_STATS = ["Du besitzt:", "Verkaufte Tickets:", "Gewinnchance:"];
		
	
		// NEW !
	static var PLAY = "Spielen";
	static var GAME_WILL_START = "Es geht los in ";
	static var SECONDES = "Sekunden";
	static var START = "Los!";
	
	
	static var BAZAR_OFFER = [
		"Deine Karte %1 interessiert mich... Ich gebe dir %2 Jetons dafür. Was sagst du?",
		"Ich muss unbedingt deine Karte %1 haben. Das ist eine %3 Karte, also geb ich dir %2 Jetons dafür",
		"Ich gebe dir %2 Jetons für deine Karte %1. In Ordnung?",
		"Ich geb dir %2 Jetons im Tausch gegen deine Karte %1. Abgemacht?",
		"%4 und %5 passen super zusammen, jetzt fehlt mir nur noch die %1. Gibst du sie mir für %2 Jetons?",
		"Wow, du hast %1!! Wenn du sie mir gibst, kriegst du %2 Jetons. Ok?",
		"Pff, außer deiner %1 interessiert mich nichts... Ich geb dir %2 Jetons dafür?",
	];
	static var BAZAR_RAISE = [
		"Argh! Ok, %2 Jetons, aber das ist mein letztes Angebot!",
		"Mir dir ist nicht gut Kirschen essen! Hier, %2 Jetons!",
		"Was? Aber das ist nur eine %3 Karte? Tss... Also gut, dann eben für %2 Jetons..",
	];
	static var BAZAR_STAY = [
		"Nein, mehr gibt's nicht! Ich biete %2 Jetons - nimm sie oder lass es!",
		"%2 Jetons für diese Karte. Du wirst kein höheres Gebot kriegen. Das ist mein letztes Wort",
		"Nein nein nein. Ich tu dir schon einen Gefallen, dir die %1 abzunehmen. %2 Jetons oder nichts.",
		"Also weißt du, ich werde eine %1 auch woanders für %2 Jetons kriegen...",
		"Ich zahle nie mehr als %2 Jetons für eine %3 Karte",
		"Hm, ich hätte sie ja gern, aber mehr als %2 Jetons hab ich nicht...",
	];
	static var BAZAR_NEXT = [
		"Hältst du mich für einen Narren? Vergiss deine Karte...",
		"Nun, ich denke wir kämen ins Geschäft. Aber nicht bei dieser Karte...",
		"Ich zahle nie mehr als eine %1 wert ist. Lassen wir's einfach!",
		"Gut, dann heb ich mir mein Geld eben für eine andere Karte auf...",
		"Macht nichts, die nächste Karte bitte...",
	];
	static var BAZAR_GIVE_UP = [
		"Macht nichts!",
		"Schade.",
		"Gut, wenn du sie brauchst...",
		"Macht nichts. Ich weiß, wo ich so eine finden kann.",
		"Wie du willst!",
		"Es liegt ganz bei dir!",
		"Mist, zu diesem Preis werde ich nie eine finden",
	];
	static var BAZAR_QUIT = [
		"Mit dir kann man einfach nicht verhandeln. Ich bin raus!",
		"Ok, ich denk ich finde leicht einen weniger knausrigen Verkäufer.",
		"Ich habe nicht genug Jetons, sorry...",
		"Ich muss weg. Bis später!",
		"Ich komm morgen wieder, wenn du bessere Laune hast",
		"Ich bin grad in einem 'KRRRR' Tunnel. Ich... 'KRRRRK' bis nächste 'KRRRK'..."
	];
	static var BAZAR_FINISH = [
		"Sonst interessiert mich gerade nichts weiter...",
		"Abgesehen von der einen, interessiert mich sonst nichts an deiner Sammlung",
	];
	static var BAZAR_DEAL = [
		"Prima! Die suche ich schon seit 3 Tagen!",
		"Danke!",
		"Cool!",
		"Danke vielmals!",
		"Es ist eine Freude, mit dir Geschäfte zu machen!",
	];
	
	static var BAZAR_NO = [ "Ich behalte sie", "Nein!", "Lieber sterbe ich", "Niemals!", "Nein danke"];
	static var BAZAR_UP = [ "Das reicht nicht", "Mehr Jetons!", "Leg noch was drauf", "Mieser Preis","Ein bisschen noch?" ];
	static var BAZAR_YES = [ "Einverstanden!", "Ok!", "Nimm sie!" ];
	
	static var BAZAR_CHOICES = ["Ich behalte sie", "Zu wenig", "Einverstanden" ];
	static var BAZAR_NO_ENTER = "Du brauchst wenigstens " + col("%1","#FF6666") + " Karten, wenn du auf den Basar willst!!";
	static var BAZAR_END = "Mephistouf ist weg! Falls er gute Laune hat, kommt er morgen wieder und kauft deine neuen Karten.";
	static var FREQ = ["gewöhnliche", "normale", "seltene"];
	
	
	// DRAFT
	static var DRAFT_DESC_CLOSE = "Jeden Tag finden Turniere für %1 Spieler zwischen %2 Uhr und %3 Uhr statt.\n\nDas Turnier ist aktuell " + col("geschlossen", WHITE) + ", nächstes Turnier in %4 ";
	static var DRAFT_DESC_OPEN = "Turnier-Anmeldungen sind noch für %1 möglich.\nSo viele Plätze sind noch frei: %2!";
	static var DRAFT_SUBSCRIBE_ERROR = ["Deine Anmeldung wurde abgelehnt!", "Du hast nicht genug Jetons.", "Kein freier Turnierplatz mehr."];
	
	static var DRAFT_RULES = white("Turnierregeln") + ": Jeder Spieler erhält "+pink("10 neue Karten")+". Davon wählt er "+pink("eine")+" und gibt den Stapel an seinen Nachbarn weiter. ...solange bis alle Karten verteilt sind. Jeder spielt soviele Partien wie den mit 10 gewählten Karten möglich. Am Ende gewinnt "+pink("die höchste Punktezahl")+" das Turnier.\nEine Turnierpartie kann zwischen "+green("1")+" und "+green("6")+" Mojo-Punkte wert sein.\nJeder behält seine 10 Karten, die besten 3 gewinnen einen Preis.";
	
	static var DRAFT_TEASING = "Turniere werden täglich zwischen %1h und %2h ausgetragen --- Die 10 für das Turnier ausgewählten Karten werden zu deiner Sammlung hinzugefügt --- Du kannst eine Partie in einem Turnier mit nur einem 1 Mojo-Punkt starten --- Sieh dir deine gespielten Turnier-Partien im Bereich Rangliste an --- ";
	static var DRAFT_CARD_NOT_AVAILABLE = "Diese Karte kann nicht im Turnier benutzt werden.";
	static var DRAFT_LEFT_TIME = "Restzeit" ;

	static var DRAFT_CHOOSE = "Wähle eine Karte!" ; 

	static var SERVER_CONNECT = "Verbinde zum Server...";
	static var WAITING_FOR_PLAYER = "Warte auf Spieler: ";
	static var PLEASE_WAIT = "Bitte warten";
	static var WAITING_NEW_PLAYERS = "Warte auf %1 zusätzliche(n) Spieler";
	static var ABORT = "Das Turnier wurde " + red("abgesagt") + " !\n" + green("(Das ist ein Skandal)") + "\nDeine " + Data.DRAFT_COST + " Jetons wurden zurückgezahlt.";
	static var DISCONNECT = "Du bist ausgeloggt.\nKeine Sorge, du kannst dem Turnier erneut beitreten.";
	static var RECONNECT = "Wieder einloggen";
	static var CANT_CONNECT = "Einloggen zum Server nicht möglich. Probiere es in einigen Minuten noch einmal.";
	static var PRIZES = "Preise";
	static var POS = ["1.", "2.", "3."];
	static var TOURNAMENT = "Turnier";

	
	static public inline function white(str) {
		return col(str, WHITE);
	}
	
	static public inline function pink(str) {
		return col(str, "#FF0088");
	}
	static public inline function red(str) {
		return col(str, "#FF5555");
	}
	static public inline function green(str) {
		return col(str, "#88DD00");
	}
	
	static public function col(str,col) {
		return "<font color='" + col + "'>" + str + "</font>";
	}
		
	static public function killLatin(str) {
		return mt.db.Phoneme.removeAccentsUTF8(str);
	}
	

	
	static public function init() {
		
		var c:Dynamic = null;
		#if fr
		return;
		#elseif en
		c = LangEn;
		#elseif de
		c = LangDe;
		#end
		
		for( f in Type.getClassFields(c) ) {
			var v : Dynamic = Reflect.field(c, f);
			if( Reflect.isFunction(v) ) continue;
			Reflect.setField(Lang, f, v );
		}
	}
	
//{
}

