import Protocole;

class Lang implements haxe.Public
{//}
	static var PIX = "<font color='#92d930'>.</font>";
	static var PIX2 = "<font color='#52b31e'>.</font>";
	static var DARK_PINK = "#FF8888";
	static var PINK = "#FFAAAA";
	static var WHITE = "#FFFFFF";

	static var MOJO_LEFT = "mojo restant";
	static var MOJO_FULL = "mojo en trop";
	static var CARD_LEFT = "Pas assez de cartes : ";
	static var CARD_FULL = "Trop de cartes : ";
	static var START_GAME = "Démarrer la partie";
	
	static var SELECT_CARDS = "Dépensez tous vos points de mojo pour lancer une partie.";
	static var TOO_MUCH_CARDS = "Retirez des cartes de votre main pour lancer une partie.";
	
	static var EACH_USE = "A chaque utilisation : ";
	static var I_SUBSCRIBE = "Jouer maintenant !";

	static var UP_LEVEL = "niv." ;
	
	static var BROWSER_PARAMS = [ "Trier par couts", "Masquer cartes trop chères", "Masquer cartes en régénération" ];
	static var BROWSER_TUTO = "Choisissez vos cartes pour un total de 6 points de mojo.";
	static var BROWSER_NO_CARD = "Vous ne pouvez pas atteindre 6 points"+PIX2+" de mojo avec vos cartes actives"+PIX2+".\nToute vos cartes seront\n réactivées à minuit !\n\nVous pouvez également acheter des"+PIX2+" cartes supplémentaires en boutique:";
	static var BROWSER_HAND_LIMIT = "Vous ne pouvez jouer que %0 cartes";
	static var BROWSER_MULTI_LIMIT = "Vous ne pouvez jouer qu'un seul exemplaire de cette carte.";
	static var BROWSER_MIDNIGHT = "Cette carte sera de nouveau utilisable à minuit.";
	static var BUY_CARD = "acheter une carte";
	static var BUY = "acheter";
	
	static var SUCCESS = "Quête réussie!";
	static var FRUIT_UNKNOWN = "fruit inconnu";

	static var FRUIT_TAGS = ["sucre", "rouge", "feuille", "petit", "noix", "fleur", "agrume", "vert", "liane", "alien", "baie", "long", "courge", "poire", "bleu", "pomme", "crotte", "orange", "jaune", "rose"];
	
	static var CONTROL = "controles";
	static var CHOOSE_CONTROL = "choisissez votre mode déplacement :";
	static var CONTROL_NAMES = ["souris","clavier A","clavier B"];
	static var DESC_CONTROL = [
			"Le serpent suis le pointeur de la "+white("souris")+". Utiliser le "+white("clic gauche")+" pour accélérer.",
			"Flèche "+white("haut bas gauche")+" et "+white("droite")+" pour choisir l'orientation du serpent.\n"+white("Barre espace")+" pour accélérer.",
			"Flèches "+white("gauche")+" et "+white("droite")+" de votre clavier pour faire pivoter le serpent.\nFlèche "+white("haut")+" pour accélérer.",
			white("Concentrez vous")+" sur un point de l'arène pour que le serpent s'y dirige.\nPour accélérer, concentrez-vous "+white("plus fort")+".",
	];
	static var PAUSE_TITLE = 	"jeu en pause";
	static var PAUSE_OFF = 		"reprendre";
	static var GORE = 			"sang";
	static var YES = 			"oui";
	static var NO = 			"non";
	static var QUIT = 			"quitter";
	static var OPTIONS = 		"options";
	
	static var STATS = ["temps de jeu", "fruits ramassés", "frutibar maximum", "longueur maximum"];
	static var SECTION_FRIENDS = "mes amis";
	static var SECTION_ARCHIVE = "mes archives";
	static var SECTION_TOP = "panthéon";
	static var SECTION_DRAFT = "mon tournoi";
	static var SECTION_RAINBOW = "Arc-en-ciel";

	
	static var CNX_IMPOSSIBLE = "Connexion impossible";
	static var CNX_TRY = "tentative";

	static var LOADING = "chargement";
	static var ENCYLOPEFRUIT_PROGRESSION = "Progression Encyclopefruit";
	static var BONUS = "Bonus";
	static var PLAY_AGAIN = "rejouer";
	static var LENGTH_UNIT = "cm";
	static var TRAINING_GAME = "Partie d'essai";
	static var TRAINING_INSTRUCTION = "Apprenez à manier le serpent grâce à cette partie.\nA chaque échec vous pourrez changer les controles.";
	
	static var CAL_UNIT = "calories";
	static var WEIGHT_UNIT = "mg";
	static var FRUIT_PROPS = ["score", "vitamine", "nutrition", "conservation"];
	static var TIME_UNIT = "sec";
	
	static var CARD_PRICE = "prix d'une carte : ";
	static var DRAW = "tirage en cours...";
	static var CARD_ADDED = "carte ajoutée a votre collection";
	static var NOT_ENOUGH_TOKEN = "pas assez de jetons !";
	
	static var TIME_INTERVAL = ["Cette semaine", "Ce mois-ci", "Cette année"];
	
	// COLLECTIONS
	static var PAGE = "page";
	static var CARDS = "cartes";
	static var COMPLETION = "complétion";
	static var COLLECTION_SECTIONS = ["Collection","Boutique","Tombola","Bazar"];
	static var LOTTERY_DESC = "Tous les soirs à minuit, la carte du jour est tirée au sort entre tous les participants de la loterie.";
	static var YESTERDAY_WINNER = "Gagnant d'hier : ";
	static var COLLECTION_TITLE_SHOP = 		"La boutique de Serpentin";
	static var COLLECTION_TITLE_LOTTERY = 	"La tombola de Loterine";
	static var COLLECTION_TITLE_BAZAR = 	"La bazar de Mephistouf";
	static var SHOP_ITEMS = ["Carte supplémentaire", "Lot de 10x cartes", "Ticket de loterie"];
	static var SHOP_DESC = [
		"La carte est tirée au hasard:\n- carte commune : 60%\n- carte normale : 30%\n- carte rare : 10%",
		"Lot de 10 cartes tirées au hasard :\n -6x cartes communes\n- 3x cartes normales\n- 1x carte rare",
		"Un ticket de loterie pour la carte du jour !\nTirage ce soir à minuit...",
	];
	static var DAILY_CARD = "Carte du jour :";
	static var LOTTERY_STATS = ["Vous possédez :", "Tickets vendus :", "Chance de gain :"];
	
	// NEW !
	static var PLAY = "jouer";
	static var GAME_WILL_START = "La partie commencera dans ";
	static var SECONDES = "secondes";
	static var START = "commencer!";
	
	
	static var BAZAR_OFFER = [
		"Je suis interessé par ta carte %1... Je t'en donne %2 jetons. Qu'est ce que tu en dis ?",
		"Il me faut absolument ta carte %1, C'est une carte %3, donc je t'en donne %2 jetons !",
		"Je te donne %2 jetons contre ta carte %1. Ca te va ?",
		"Je peux te donner %2 jetons en échange de ta carte %1. Ca marche ?",
		"J'ai une super combo à tester avec %4 et %5 il me manque juste %1, tu me l'échanges pour %2 jetons ?",
		"Waaah tu as %1 !! Si tu veux je te donne %2 jetons en échange, ok ?",
		"Mouef... Bon à part %1, je ne vois rien qui m'intéresse... Je te la prend contre %2 jetons ?",
	];
	static var BAZAR_RAISE = [
		"Arch ! Bon %2 jetons, mais c'est mon dernier mot !",
		"T'es dur en affaire toi ! Va pour %2 jetons !",
		"Quoi ? Mais c'est juste une carte %3 ! Tsss.. Bon ok pour %2 jetons alors...",
	];
	static var BAZAR_STAY = [
		"Non y'a pas moyen ! C'est %2 jetons à prendre ou à laisser !",
		"%2 jetons pour cette carte, tu trouveras pas mieux, alors je touche pas à mon prix.",
		"Non non non, je te rends déjà service en te débarassant de %1 donc c'est %2 ou rien du tout !",
		"J'arriverai à trouver une carte %1 pour %2 jetons ailleurs tu sais... ",
		"Je monterai jamais au dessus de %2 jetons pour une %3",
		"Bah j'aimerais bien mais j'ai que %2 jetons sur moi...",
	];
	static var BAZAR_NEXT = [
		"Tu m'as pris pour un pigeon ? Laisse tomber pour cette carte...",
		"Bon je crois qu'on y arrivera pas pour cette carte...",
		"Je paierai pas plus pour %1, donc passons à la suite !",
		"Bon je crois que je vais plutot garder mes sous pour une autre carte...",
		"Tant pis, voyons voir la suite...",
	];
	static var BAZAR_GIVE_UP = [
		"Pas grave !",
		"Dommage.",
		"Bon si tu en as besoin...",
		"Bon pas grave, je sais ou je peux en trouver une.",
		"Comme tu veux !",
		"C'est toi qui vois !",
		"Argh, j'arriverai jamais à en trouver une...",
	];
	static var BAZAR_QUIT = [
		"Bon y'a pas moyen de faire affaire avec toi, je décolle !",
		"Ok je pense que je peux trouver un vendeur moins radin.",
		"J'ai pas assez de tokens, désolé...",
		"Je crois qu'on m'appelle, à plus !",
		"Bon je reviendrai demain, voir si t'es plus sympa",
		"Je passe sous un 'crr' tunnel, j'crchh' à la prochaine 'cccrrrhh'"
	];
	static var BAZAR_FINISH = [
		"Il y a plus rien qui m'intéresse pour l'instant...",
		"Bon à part ça, il n'y a pas de cartes qui m'intéressent dans ta collection",
	];
	static var BAZAR_DEAL = [
		"Chouette !! je la cherchais depuis 3 jours !",
		"Merci !",
		"Cool !",
		"Merci beaucoup !",
		"C'est un plaisir de faire des affaires avec toi !",
	];
	
	static var BAZAR_NO = [ "Je la garde", "Non!", "Plutôt crever", "Jamais!", "Non merci"];
	static var BAZAR_UP = [ "C'est pas assez", "Plus de jetons!", "Encore un effort", "Prix pourri","Un peu plus ?" ];
	static var BAZAR_YES = [ "D'accord!", "Ok!", "Tope-là!" ];
	
	static var BAZAR_CHOICES = ["Je la garde", "Plus cher", "D'accord" ];
	static var BAZAR_NO_ENTER = "Il te faut au moins " + col("%1","#FF6666") + " cartes pour pouvoir entrer dans le bazar !!";
	static var BAZAR_END = "Mephistouf est parti ! Si il est de bonne humeur, il reviendra probablement demain pour t'acheter de nouvelles cartes.";
	static var FREQ = ["commune", "normale", "rare"];
	
	
	// DRAFT
	static var DRAFT_DESC_CLOSE = "Chaque jour des tournois de %1 joueurs sont lancés entre %2 heures et %3 heures.\n\nLe tournoi est actuellement " + col("fermé", WHITE) + ", prochain tournoi dans %4 ";
	static var DRAFT_DESC_OPEN = "Les inscriptions pour le tournoi sont ouvertes pendant %1.\nIl reste encore %2 place(s) libre(s) !";
	static var DRAFT_SUBSCRIBE_ERROR = ["Votre inscription n'est pas acceptée!", "Vous n'avez pas assez de jetons.", "Plus de place libre pour ce tournoi."];
	
	static var DRAFT_RULES = white("Règles du tournoi")+" : Chaque joueur reçoit "+pink("10 nouvelles cartes")+", il en choisit "+pink("une")+" puis fait passer le paquet à son voisin. On répète l'opération jusqu'à épuisement des cartes. Chacun joue ensuite autant de parties qu'il le peut avec les 10 cartes choisies, puis "+pink("le plus haut score")+" emporte le tournoi.\nUne partie de tournoi peut contenir entre "+green("1")+" et "+green("6 pts")+" de mojo.\nChacun repart avec ses 10 cartes et les 3 meilleurs reçoivent un prix.";
	static var DRAFT_TEASING = "Les tournois sont disponibles tous les jours entre %1h et %2h --- Les 10 cartes séléctionnées dans un tournoi iront dans votre collection --- Dans un tournoi une partie peut être lancée avec seulement un point de mojo --- Visionnez les parties de votre tournoi dans la section classement --- ";
	static var DRAFT_CARD_NOT_AVAILABLE = "Cette carte ne peut plus être utilisée pour le tournoi.";
	static var DRAFT_LEFT_TIME = "Temps restant" ;

	static var DRAFT_CHOOSE = "Choisissez une carte !" ; 

	static var SERVER_CONNECT = "connexion au serveur...";
	static var WAITING_FOR_PLAYER = "En attente du joueur : ";
	static var PLEASE_WAIT = "veuillez patienter";
	static var WAITING_NEW_PLAYERS = "Attente de %1 joueur(s) supplémentaire(s)";
	static var ABORT = "Le tournoi a été " + red("annulé") + " !\n" + green("(C'est un scandale)") + "\nVos " + Data.DRAFT_COST + " jetons ont été remboursés.";
	static var DISCONNECT = "Vous êtes déconnecté.\nPas de panique, vous pouvez rejoindre le tournoi à nouveau :";
	static var RECONNECT = "Reconnecter";
	static var CANT_CONNECT = "Impossible de se connecter au serveur. Merci de réessayer dans quelques instants.";
	static var PRIZES = "Récompenses";
	static var POS = ["1er", "2ème", "3ème"];
	static var TOURNAMENT = "Tournoi";

	
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
		#elseif es
		c = LangEs;
		#end
		
		for( f in Type.getClassFields(c) ) {
			var v : Dynamic = Reflect.field(c, f);
			if( Reflect.isFunction(v) ) continue;
			Reflect.setField(Lang, f, v );
		}
	}
	
	static function rep(str, a, b = "b", c = "c", d = "d", e = "e") {
		str = StringTools.replace(str, "%1", a);
		str = StringTools.replace(str, "%2", b);
		str = StringTools.replace(str, "%3", c);
		str = StringTools.replace(str, "%4", d);
		str = StringTools.replace(str, "%5", e);
		return str;
	}
	

		
	
//{
}
