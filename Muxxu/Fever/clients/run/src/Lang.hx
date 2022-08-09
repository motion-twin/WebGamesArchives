
class Lang implements haxe.Public {//}
	
	static var 	ITEM_NAMES  = [
		"Cocktail", "Grimoire", "Chaussures", "Miroir", "Trèfle", "Poupée vaudou", "Masque vaudou",
		"Baguette",	"Lunettes", "Radar", "Prisme", "FeverX", "Parapluie", "Dé",
		"Moulin à vent", "Glace chimique", "Sablier", "ChromaX", "Bague magique", "Fourchette enchantée", "Fil d'ariane",
		"Rune Ini","Rune Sed","Rune Aarg","Rune Olh","Rune Al","Rune Laf","Rune Hep"
	];
	
	static var 	ITEM_DESC  = [
		"Diminue de 10° la température au début du match",
		"Notez un jeu que vous voulez interdire",
		"Double la vitesse de marche",
		"Les méduses ne peuvent plus vous paralyser",
		"Détecte les cartouches de jeu à proximité",
		"Les monstres démarrent avec un coeur en moins",
		grey("Touche "+pink("[V]")+" durant une épreuve :")+"\nFuyez le mini-jeu gratuitement", //"Les monstres ont 2% de chance de s'enfuir au début du combat",
		
		"Ouvre Les coffres verts",
		"Dévoile la liste des jeux du monstre le plus proche",
		"Indique votre position et les îles découvertes",
		"Transforme un glaçon en trois\narc-en-ciel",
		"La célèbre console FeverX !",
		"+1 arc-en-ciel supplémentaire chaque jour",
		"Faite "+col("1","#FF0000")+" pour gagner un glaçon\nChaque essai coûte un arc-en-ciel",
		
		"Lorsque vous perdez un duel, la température ne monte pas",
		"+1 glaçon supplémentaire chaque jour",
		"+25% de temps sur les jeux de réflexion",
		"La FeverX consomme en priorité des arcs-en-ciel",
		"les monstres brutaux vous infligent un dégât de moins",
		"10% de chance de briser 2 coeurs en une attaque",
		"Vous téléporte à la dernière statue touchée pour un arc-en-ciel",
		
		"Une pierre étrange...",
		"Une pierre mystérieuse...",
		"Une pierre énigmatique...",
		"Une pierre inconnue...",
		"Une pierre obscure...",
		"Une pierre singulière...",
		"Une pierre inquiétante...",
	];
	
	static var BONUS_ISLAND_NAMES = [ "Fulgo", "Ignik", "Rasen" ];
	static var BONUS_ISLAND_DESC = [ "Détruit le monstre le plus proche", "Détruit tous les monstres sur l'île", "Détruit les monstres sur une ligne" ];
	
	static var BONUS_GAME_NAMES = [ "Camembeurk", "Vol-o-vent" , "Burilame", ];
	static var BONUS_GAME_DESC = [
		grey("Touche "+pink("[C]")+" entre deux épreuves :")+"\nRegagnez tous vos coeurs",
		grey("Touche "+pink("[V]")+" durant une épreuve :")+"\nFuyez le mini-jeu en cours",
		grey("Touche "+pink("[B]")+" entre deux épreuves :")+"\nInflige un dégât à l'adversaire"
	];
	static var BONUS_DAILY_NAMES = ["abonnement arc-en-ciel","abonnement glaçon"];
	static var BONUS_DAILY_DESC = [
		"Récupérez un " +pink(BONUS_GAME_NAMES[0]) + ", un " + pink(BONUS_GAME_NAMES[1]) + " et un " + pink(BONUS_GAME_NAMES[2]) + " pour recevoir un arc-en-ciel supplémentaire chaque jour.",
		"Récupérez un " +pink(BONUS_ISLAND_NAMES[0])+", un "+pink(BONUS_ISLAND_NAMES[1])+" et un "+pink(BONUS_ISLAND_NAMES[2])+" pour recevoir un glaçon supplémentaire chaque jour.",
		"+1 arc-en-ciel supplémentaire chaque jour",
		"+1 glaçon supplémentaire chaque jour",
	];
	
	static var GODS = [
		"Koan", "Barchenold", "Piluvien", "Dumerost",
		"Chankron", "Malvenel", "Lifolet", "Tarabluff",
		"Sidron", "Chomniber", "Pata", "Droenix",
		"Lancurno","Jomil","Tokepo","Grazuli",
	];
	static var BLESS = "L'oeil de %1 veille sur toi";
	
	// ----------------- //
	
	static var PERMANENT_OBJECT = 	"objet utilisé en permanence";
	static var NO_MORE_ICECUBE = 	"vous n'avez plus de glaçons !";
	static var NO_MORE_RAINBOW = 	"vous n'avez plus d'arc-en-ciel !";
	static var NO_CARTRIDGE = 		"Pas de cartouche de jeu !";
	static var NO_STATUE = 			"Aucune statue découverte !";
	static var TOO_MUCH_RAINBOW = 	"vous en avez déjà assez !";
	static var NEED_KEY = 			"Vous avez besoin d'une clé !";
	static var NEED_WAND = 		"Vous avez besoin d'une baguette !";
	
	static var HEARTS_DESC  = [ "réceptacle cardiaque", "Espace de stockage pour coeurs abandonnés", "x quarts de coeurs", "Retrouver les quarts manquants pour gagner une vie supplémentaire"];

	// ----- //
	static var ENDING_TEXT = "Le grand bakélite Sargon anéanti, le portail dimensionnel tend désormais les bras à Pousty.\nLe plus valeureux des pingouins n'hésite pas : malgré les blessures de son dernier combat, c'est d'un pied palmé décidé qu'il franchit la mystérieuse porte...\nUn maelström de couleurs enveloppe Pousty ! Peu à peu, les énergies refluent. A quelques mètres, le passage semble ouvrir sur un autre monde ! Un monde semblable mais...\nMême d'ici, on sent une atmosphère bien moins accueillante. Notre héros palmipède ressent déjà la menace Bakélite, et cette fois, ça ne sera pas une partie de plaisir !";

	static var ENDING_QUESTION =  "Voulez-vous rester sur l'archipel de %1 pour éliminer vos derniers ennemis, ou faire le grand saut et rejoindre %2 pour une nouvelle aventure ?";
	static var ENDING_EXPLORE = "Retourner à %1";
	static var ENDING_LEAVE_TO = "Partir à %1";
	
	static var ARCHIPELS =  ["Gonkrogme","Sultura","Baniflok","Grizantol","Marshoukrev","Dishigan","Lakulite","Koleporsh","Murumuru","Frisantheme","Zulebi"];
	
	static var GENERIC_ERROR = "Une erreur est survenue. Merci de relancer le jeu." ;
	
	static var CREATE_WORLD = "génération du monde...";
	static var CHECK_INVENTORY = "voir l'inventaire";
	static var BACK_TO_GAME = "retourner au jeu";
	static var ISLAND = "ile";
	static var NO_MONSTER = "pas de monstre en vue !";
	static var FEVER_X_LABELS = ["jouer","étape"];
	static var SELECT_STEP = "selectionnez\n  une étape";
	static var SERVER_CNX = "connexion au serveur...";
	
	
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


