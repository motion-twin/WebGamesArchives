class TextFr implements mt.Protect {//}

	  /////////////////
	 /// INTERFACE ///
	////////////////

	public static var FUEL_TITLE = "RESERVOIR VIDE !!!";
	public static var FUEL_TEXT = "<p><b>Vous n'avez plus  de capsules d'hydrogène !</b></p><p>L'ESCorp vous transmettra <font color='#00FF00'>gratuitement</font> trois nouvelles capsules ce soir a minuit.</p><p>Cependant vous pouvez continuer a jouer dès maintenant grâce a la banque interstellaire !</p>";
	public static var FUEL_BANK = "BANQUE INTERSTELLAIRE";

	public static var PAUSE_TEXT = [ "SELECTIONNER UNE CAPSULE OU APPUYER SUR \"P\" POUR QUITTER LA PAUSE","APPUYER SUR \"P\" POUR QUITTER LA PAUSE"];

	public static var WARNING_ZONE = "POINTEUR HORS DE LA ZONE DE JEU !";
	public static var START_CLIC_GREEN = "CLIQUEZ SUR LA ZONE VERTE POUR COMMENCER";

	public static var WARNING_FAR = "Cette position ne peut être atteinte en un seul voyage !\nDéplacez vous de cases en cases pour atteindre ce point .";
	public static var WARNING_CARDS = "Attention ! Vous vous appretez a quitter la zone prescrite.\nVotre balle standard n'est pas assez puissante pour cette zone.\n Vous devez obtenir les accréditations :";
	public static var WARNING_CNX = "Connexion perdue !\nLes données de la partie n'ont pas été sauvegardés.";

	public static var ERROR_CRC = "Erreur de reception des données. Cette erreur peut etre provoquée par l'ouverture de deux sessions simultanées dans des onglets ou navigateurs différents.";

	public static var CONNECTION_SERVER = "CONNEXION AU SERVEUR...";

	public static var PREF_FLAGS = ["CONTROLE CLAVIER","MOUVEMENTS VISIBLE","ZONE AVERTISSEMENT","BALLE SUPER CONTRASTE "];
	public static var PREF_TITLE = "PREFERENCES";
	public static var PREF_MOUSE = "SENSIBILITE SOURIS";
	public static var PREF_QUALITY = "QUALITE GRAPHIQUE";

	public static var CAPS_NAME = ["NEANT","GLACE","FEU","FOUDRE"];


	  ////////////
	 /// GAME ///
	////////////

	public static var ITEM_NAMES =		[
		"First Level",
		"Accreditation Alpha",
		"Accreditation Beta",
		"Accreditation Ceta",
		"Balle de Forage",
		"Appel de detresse",
		"Douglas",
		"Debris centrale",
		"Debris coupant",
		"Debris singulier",
		"Debris fumant",
		"Debris curieux",
		"Debris minuscule",
		"Debris anodin",
		"Extension envellope",
		"Symboles étranges",
		"Salmeen",
		"---",
		"Missile",

		"Carte des marchands",
		"Missile bleu",
		"Missile noir",
		"Pierre de Lycans",
		"Pierre de Spignysos",
		"Etoile rouge",
		"Etoile orange",
		"Etoile jaune",
		"Etoile verte",
		"Etoile turquoise",
		"Etoile bleue",
		"Etoile violette",
		"Editeur minier",
		"Medaillon partie ronde",
		"Medaillon partie croissantee",
		"Medaillon partie creuse",
		"Medaillon Moltearien",
		"Balle OX-Soldat",
		"Balle OX-Delta",
		"Balle Asphalt",
		"Missile Rouge",
		"Ambro-X",
		"Radar ok",
		"Generateur",

		"Noyaux anti-matiere",
		"Noyaux anti-matiere",
		"Noyaux anti-matiere",
		"Noyaux anti-matiere",

		"Proces verbal d'evasion",
		"Bouclier atmospherique",
		"Blindage externe",
		"Stabilisateurs hydroliques",
		"Epave de réacteur",
		"Réacteur de surface",
		"Combinaison",
		"Cousin de Salmeen",
		"Badge FURI",
		"Karbonis-Belt Pass",

		"Extension d'envellope 2",
		"Crystal rose A",
		"Crystal rose B",
		"Crystal rose C",
		"Crystal rose D",
		"Crystal rose E",
		"Parchemin A",
		"Parchemin B",
		"Parchemin C",
		"Parchemin D",
		"Parchemin E",
		"Parchemin F",
		"Parchemin G",
		"Parchemin H",
		"Acc. syntrogènique",
		"Extension d'envellope 3",
		"Jumeleur de Saumir",
		"Rétrofuseur du Dr Sactus",

		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",
		"Tablette Karbonite",

		"Ingenieur Karbonite",
		"Mine Fora 7R-Z",

		"Element de carte PID no1",
		"Element de carte PID no2",
		"Element de carte PID no3",
		"Element de carte PID no4",
		"Element de carte PID no5",
		"Element de carte PID no6",
		"Element de carte PID no7",
		"Element de carte PID no8",
		"Element de carte PID no9",
		"Element de carte PID no10",
		"Element de carte PID no11",
		"Element de carte PID no12",
		"Element de carte PID no13",
		"Element de carte PID no14",
		"Element de carte PID no15",
		"Element de carte PID no16",
		"Element de carte PID no17",
		"Element de carte PID no18",
		"Element de carte PID no19",
		"Element de carte PID no20",
		"Element de carte PID no21",
		"Element de carte PID no22",
		"Element de carte PID no23",
		"Element de carte PID no24",
		"Element de carte PID no25",
		"Element de carte PID no26",
		"Element de carte PID no27",
		"Element de carte PID no28",
		"Element de carte PID no29",
		"Element de carte PID no30",
		"Element de carte PID no31",
		"Element de carte PID no32",
		"Element de carte PID no33",
		"Element de carte PID no34",
		"Element de carte PID no35",
		"Element de carte PID no36",
		"Element de carte PID no37",
		"Element de carte PID no38",
		"Element de carte PID no39",
		"Element de carte PID no40",
		"Element de carte PID no41",
		"Element de carte PID no42",

		"Passport Terrien",
		"Mode difficile",
	];

	public static var SHOP_ITEM_NAMES = [
		"Moteur v1",
		"Moteur v2",
		"Moteur v3",
		"Moteur v4",
		"Moteur v5",
		"Moteur v6",
		"Carte des missiles",
		"Lunettes de soleil",
		"Missile sup no1",
		"Missile sup no2",
		"Missile sup no3",
		"Capsule glace",
		"Capsule feu",
		"Capsule trou noir",
		"Capsule hydrogène solide",
		"Réacteurs latéraux",
		"Reffroidissement liquide",
		"Recharge munitions",
		"Envellope de secours",
		"Drone de soutient",
		"Drone > Outils de perforation",
		"Drone > Support réacteur",
		"Drone > Convertisseur",
		"Drone > Collecteur",
		"Radar de secours",
		"Capsule Foudre",
		"Moteur de synthèse perpetuel",
		"Antenne KI-WI",

		"Pod d'atterrisage",
		"extension de pod standard",
		"extension de pod speciale",
		"extension de pod ultime",
		"reacteur de surface turbo",
		"reacteur de surface turbo-X2",
		"reacteur de surface turbo-X3",

		"Mine supplémentaire no1",
		"Mine supplémentaire no2",
		"Mine supplémentaire no3",
	];

	public static var OPTION_NAMES = [
		"AIMANT",
		"BLINDAGE",
		"COLLE",
		"DIMINUTION",
		"EXTENSION",
		"FLAMME",
		"GLACE",
		"HALO",
		"INDIGESTION",
		"JAVELOT",
		"KAMIKAZE",
		"LASER",
		"MULTI-BALL",
		"NOUVELLE BALLE",
		"OUVERTURE",
		"PROVISION",
		"QUASAR",
		"REGENERATION",
		"SAUVETAGE",
		"TRANSFORMATION",
		"ULTRAVIOLET",
		"VOLT",
		"WHISKY",
		"XANAX",
		"YOYO",
		"ZELE",
		"MISSILE",
	];

	  //////////////
	 /// ENDING ///
	//////////////

	public static var OUTRO_0 = "Apres plusieurs mois d'errance dans l'univers, vous voici a nouveau sur terre.\n\nVotre retour a créé une vive émotion dans les médias forçant l'ESCorp a tenir ses engagements à votre égard.\n\nVous êtes désormais libre de vivre comme vous le voulez...\n\n\n\n Qu'allez vous donc faire ?";

	public static var OUTRO_1 = "Apres plusieurs mois d'errance dans l'univers, vous voici a nouveau sur terre.\n\nVos révélations fracassantes sur les agissements de l'ESCorp on provoqué un véritable scandale dans les médias.\n\nVous êtes désormais libre de vivre comme vous le voulez...\n\n\n\n Qu'allez vous donc faire ?";

	public static var OUTRO_2 = [
		[ 	"Mener une vie paisible",
			"L'ESCorp reprendra votre enveloppe et toutes vos améliorations.\nVotre progression actuelle sera perdue.",
			"Cette option permet de débloquer le <font color='#ff0000'>mode difficile</font> d'alphabounce."
		],
		[ 	"Repartir dans l'espace",
			"Vous serez immediatement transféré au point d'origine de votre enveloppe avec toutes vos améliorations actuelles.",
			"La portée radar et la puissance de votre moteur seront définitivement augmentés d'une unité."
		],
	];

	  //////////////
	 /// EDITOR ///
	//////////////

	public static var EDITOR_CLIC_SUPPR = "clic + supprime ; efface une brique.";

	public static var EDITOR_BUTS = [
		"RETOUR",
		"EFFACER BRIQUES",
		"SAUVEGARDER",
		"MODERATION",
		"RESET LEVEL",
		"ACCEPTER",
		"REFUSER TOUT"
	];

	  ////////////////
	 /// TRAVELER ///
	////////////////

	public static var TRAVELER_NAMES = [ "Walter", "Ben", "Jokarix", "Goshmael", "Mirmonide", "Korkan", "Gifu","Birman","Falgus","Moktin","Bifouak","Lacune","Gibarde","Blafaro","Kimper","Sochmo","Nicolu","Mangerin","Difidus","Stridan","Glochar","Mikou","Kilian","Daston","Possei","Spido","Corneli","Brifuk","Colcanis","Frederak","Coustini","Darnold","Fruncky","Jimic","Sachude","Bramhan","Nucrcela","Baguera","Ismael","Gorgonzi","Bashkod","Dangoren","Astefik","Mouroud","Babacar","Disnouie","Kisby","Bastiar","Amilou","Fromest","Ambrun","Caushmil","Poubreso","Flaurest","Moliur","Nasting","Boumbo","Kig","Sproutch","Zoobik","Morvoyeu","Shandwiz","Guilbard","Mocheron","Lakune","Stokoln","Tartantua","Saphyr","Gouperin","Chogrom","Kaskubi","Panzeman","Yuyu","Pirlui","Saxtan","Coulepron","Barzan","Jean-Cloud","Chourizou","Stupood","Drasteam","Weathy"];

	public static var TRAVELER_JOBS = [
		"plombier",
		"informaticien",
		"megacrobate",
		"tueur en série",
		"::user:: de ::stuff0::",
		"::user:: d'::stuff1::",
		"agent secret de l'ESCorp",
		"fan du chanteur ::singer::",

	];

	public static var TRAVELER_USER = [	"vendeur",
		"avaleur",
		"testeur",
		"lanceur",
		"gouteur",
		"chasseur",
	];

	public static var TRAVELER_STUFF_0 = [
		"chantilly",
		"sentiments",
		"petit-suisses",
		"sangliox",
		"capsule d'hydrogène",
		"conglomérats",
		"pierres préciseuses",
		"plasma energetique",
		"cable electriques",
		"chaussures liquides",
		"crème de viande",
		"carcasses d'enveloppes",
		"kebab",
		"lampe torche",
		"cartouche SNES",
		"sushi",
		"croissants",
	];

	public static var TRAVELER_STUFF_1 = [
		"écrevisses",
		"échelles",
		"asperges",
		"araignées géantes extra-terrestres",
		"ecran géant",
		"enveloppes experimentales",
		"enveloppes de collection",
		"oreilles usagées",
		"oranges",
		"images-à-collectionner",
	];

	public static var TRAVELER_MISS = [
		"confiance en moi",
		"monnaie",
		"matière grises",
		"temps pour mes loisirs",
		"copines",
		"moyen de me mettre en avant",
		"gens dans mon entourage",
	];


	public static var TRAVELER_SINGER = [
		"Mike Youpala",
		"Brant Burko",
		"Luke Mirno",
		"Costelox",
		"Kirt Siffer",
		"Jess Mystic",
	];

	public static var TRAVELER_INTRO = [
		"bonjour détenu terrien,\n",
		"bonjour,\n",
		"bonjour étranger,\n",
		"bienvenue étranger,\n",
		"J'attend votre venue depuis si longtemps...\n",
		"Enfin de la visite !\n",
		"Groumph!\n",
		"Hola ! Y'a quelqu'un ?\n",
		"Qui va là ?\n",
		"Salut !\n",
	];

	public static var TRAVELER_WHO = [
		"Mon nom est ::name:: je suis ::profession:: sur cette planète.",
		"Je suis ::name::, tu peux me vouvoyer si tu veux.",
		"Je suis un humble ::profession::.",
		"On m'apelle ::name:: le ::profession::.",
		"Mon nom est ::name::, veux tu être mon ami ?",
		"Mon nom est ::name::, je n'ai plus beaucoups de ::miss:: depuis que je suis ::profession::.",
		"Qui est tu ? Je suis ::name:: le ::profession::.",
	];

	public static var TRAVELER_LEAVE = [
		"Je cherche a quitter ::start:: depuis des années maintenant...",
		"Je ne me plais plus vraiment à ::start::,",
		"::start::, c'est vraiment pas un endroit sympa ou habiter,",
		"Pas moyen de faire un truc interessant sur ::start::,",
		"Crois tu que tu pourrais vivre sur ::start:: ? Parceque moi, c'est fini j'ai ma dose...",
		"Y'a pas grand monde ici... Si ça continue comme ça je vais perdre mon emploi.",
	];


	public static var TRAVELER_DEST = [
		"Je sais au fond de moi, qu'une vie meilleure m'attend a ::end::.",
		"Peut-être que je pourrai tout recommencer a zero sur ::end::.",
		"J'ai toujours revé d'aller sur ::end::",
		"Mon rêve est d'aller sur ::end::",
	];

	public static var TRAVELER_DEST_COORD = [
		"J'ai besoin de retrouver mon porte-clé... Je l'ai perdu lors de mon voyage autour de la position ::pos::.",
		"Mon projet est de monter une nouvelle colonie spatiale en ::pos::.",
		"J'aimerai ouvrir une nouvelle boutique spatiale en ::pos::.",
		"Si tu peux m'amener a la position ::pos::, je pourrai y retrouver mon oncle, il tient un satellite-burger dans le coin.",
		"J'ai entendu parlé d'une astro-boite-de-nuit terrible en ::pos::.",
		"Des caisses de ::stuff0:: ont été abandonnée en ::pos::, j'aimerai m'y rendre le plus rapidement possible !",
		"Je sais de source sure que ::singer:: fera un concert surprise en ::pos:: cette semaine.",
	];

	public static var TRAVELER_ASK_0 = [
		"Peux tu m'amener là-bas ?",
		"M'aideras-tu a faire le voyage jusque là ?",
		"Puis-je voyager avec toi jusque là bas ?",
		"Je peux partir avec toi ?",
	];

	public static var TRAVELER_ASK_1 = [
		"Il faudra que j'utilise une de tes enveloppes pour me déplacer avec toi.",
		"J'ai besoin d'une enveloppe de secours pour te suivre, je suis trop grand pour rentrer avec toi.",
	];

	public static var TRAVELER_REWARD_MIN_0 = [
		"Si tu m'amènes je peux te donner ::rmin:: minerais.",
		"Je peux payer la course ::rmin:: minerais.",
	];

	public static var TRAVELER_REWARD_MIN_1 = [
		"Ce sont toutes mes économies !",
		"Je n'ai rien d'autre.",
		"Tu n'es pas obligé de tout prendre...",
		"J'espere que c'est assez.",
	];

	public static var TRAVELER_REWARD_KEUD = [
		"",
		"Je n'ai pas d'argent pour te payer la course, mais je suis sur que tu as bon coeur...",
	];

	public static var TRAVELER_REWARD_CAPS = [
		"J'ai aussi de quoi t'aider un peu pour le carburant : ::rcap:: CHS !",
		"Pour le carburant j'ai également ::rcap:: CHS, ca devrait nous aider a faire un bout de chemin.",
	];

	public static var TRAVELER_NO_SLOT = "\nMais tu ne peux rien faire pour moi...\nMerci tout de même d'être venu me voir. Ca fait du bien de parler à quelqu'un.";

	public static var TRAVELER_LEAVE_PLANET = [
		[	// 0 - MOLTEAR
			"Les molécules spatiales nous rendent la vie impossible... Hier elles sont murée la porte de mon salon.",
			"Les molécules prolifèreent a grande vitesse par ici. Je crois qu'il est temps de plier bagages.",
			"C'est insupportable ! Les molécules ont encore détruit mes ::stuff0:: ce matin. Je n'ai plus aucune raison de rester ici.",
		],
		[	// 1 - SOUPALINE
			"L'air marin de Soupaline ne m'a jamais vraiment réussi, et puis je crois que le sel commence a me ronger la cervelle."

		],
		[	// 2 - LYCANS
			"::start:: est  vraiment trop instable pour moi, hier le livreur de ::stuff0:: a été envoyé sur orbite, suite a une explosion de surface !",
			"Tu penses que tu pourrais vivre sur ::start:: ? Ici il y'a 20 explosions par nuits",
			"J'ai perdu 13 Shmolgs depuis le début de l'année... Tout ça à causes des explosions de souffres de::start::.",
		],
		[""],	// 3 - SAMOSA
		[	// 4 - TIBOON
			"Du sable, du sable, du sable... Il n'y a rien d'autre ici...",
			"J'ai exploré toutes les dunes de ::start::, je crois qu'il est temps pour moi de passer a autre chose.",
		],
		[	// 5 - BALIXT
			"Les Balixteens sont opressants et vindicatifs, la situation ici est intenable !",
			"Hier Franxis a été touché de plein fouet par une de leur saleté de reductrine, et je ne l'ai pas retrouvé !",
			"Le nouveau gouverneur de Balixt impose aux étrangers des conditions de vie inacceptables.",
		],
		[""],	// 6 - KARBONIS
		[	// 7 - SPIGNYSOS
			"::start::, c'est un peu mort en hiver, si tu vois ce que je veux dire...",
			"T'as vu ce temps pourri ? Pas question que je reste sur ::start:: une minute de plus !",
			"La nuit dernière la temperature est tombé a -50°, j'ai perdu un orteil...",
			"Mes ::stuff0:: ont gelés la nuit dernière !",
		],
		[	// 8 - POFIAK
			"::start:: est bien trop humide pour moi, je crois que je vais finir par tomber malade si je reste ici.",
			"Les attaques d'insectes psioniques incessantes m'ont finalement décidées à quitter ::start::.",

		],
		[""],	// 9 - SENEGARDE
		[	// 10 - DOURIV
			"Il y a beaucoups trop de mineurs qui viennent ici, bientôt ::start:: sera recouvert de complexes miniers autonomes !",

		],
		[""],	// 11 - GRIMORN
		[	// 12 - DTRITUS
			"La qualité olfactive de la planète se dégrade et au final, manger des momes c'est plus trop mon truc..."
		],
		[ 	// 13 - ASTEROBELT
			"La vie d'hermite perdu sur un asteroïde ne m'interesse plus vraiment"
		],
		[	// 14 - NALIKORS
			"Chaque jour, il y a un peu plus de RAID de l'ESCorp, je pense que ma vie est en danger ici.",
			"Je suis venu ici pour rejoindre le F.U.R.I. mais l'attitude megalomane de Kefrid commence a me faire douter...",
		],
		[	// 15 - HOLOVAN
			"J'ai commencé mon stage de méditation transcendantale avec les Kemilien il y'a plus de 37 ans.",
			"Depuis que j'ai fini mes études, plus rien ne me retient sur Holovan.",
		],
		[	// 16 - Khorlan
			"Je veux voyager a travers l'univers , comme Salmeen !",
			"Les chutes de noisettes-orbitales ont totalement détruit mon village, seule ma maison est encore debout ! Je ne veux pas rester ici !",
		],
		[	// 17 - CILORILE
			"A cause des conglomerats gardiens, nous sommes obligés de rester immobiles tous les jours entre 9h et 9h20 et le soir entre 18h30 et 18h50, Ce n'est pas une vie, je veux quitter Cilorile !"
		],
		[""],	// 18 - TARCITURNE
		[""],	// 19 - CHAGARINA
	];

	public static var TRAVELER_DEST_PLANET = [
		[	// 0 - MOLTEAR
			"Les molecules spatiales ont l'air vraiment interessantes, je pense que je pourrai etudier leur comportement sur place."
		],
		[	// 1 - SOUPALINE
			"L'ocean a perte de vue, ça laisse rêveur..."
		],
		[	// 2 - LYCANS
			"Les grands espaces... Il n'y a que ça de vrai !"
		],
		[""],	// 3 - SAMOSA
		[	// 4 - TIBOON
			"Je serai bien plus tranquile qu'ici sur cette petite planère.",
		],
		[	// 5 - BALIXT
			"Les Balixteens ont besoin de mains d'oeuvre pour construire leur empire. Ils auront surement besoin d'un ::profession:: là-bas.",
			"Les installations de réductrine demandent une main d'oeuvre abondante. Je trouverai surement un emploi là-bas.",
		],
		[""],	// 6 - KARBONIS
		[	// 7 - SPIGNYSOS
			"Ici on etouffe, il me faut un peu d'air frais.",
			"Il parait que la surface est tellement lumineuse que l'on peut a peine ouvrir les yeux !"
		],
		[	// 8 - POFIAK
			"J'ai besoin d'un peu de verdure."

		],
		[""],	// 9 - SENEGARDE
		[	// 10 - DOURIV
			"Il parait que là bas, il suffit de se baisser pour ramasser des cristaux ! Ca ne t'excite pas ?",
			"Je pourrai faire fortune facilement là bas, il parait que la surface est truffée de cristaux !",
		],
		[""],	// 11 - GRIMORN
		[	// 12 - DTRITUS
			"Il parait que l'on peut y faire carrière juste en effrayant des enfants!"
		],
		[ 	// 13 - ASTEROBELT
			""
		],
		[	// 14 - NALIKORS
			"Rejoindre les membres du F.U.R.I. pour partir a l'aventure, ça c'est une experience !"
		],
		[	// 15 - HOLOVAN
			"Mon rêve est de rencontrer et vivre avec les Kemiliens."
		],
		[	// 16 - KHORLAN
			"J'ai besoin d'un peu de verdure."
		],
		[	// 17 - CILORILE
			"L'air marin : C'est bon pour ce que j'ai !"
		],
		[""],	// 18 - TARCITURNE
		[""],	// 19 - CHAGARINA
	];


	  //////////////////
	 /// ITEM GIVER ///
	//////////////////

	public static var ITEM_GIVER_SALMEEN_COUSIN = "Bonjour Salmeen!\nCa fait un bail qu'on ne s'est pas vu ! Tu as besoin de quelque chose ? Je vois que tu as amené un ami avec toi, je vais voir si je peux trouver ce que vous recherchez.\n*Gregune ouvre un grand coffre situé au fond de la pièce*\nVoilà, c'est une combinaison pour Suptirnéen, il y a donc une paire de manche a l'arrière qui ne te serviront pas à grand chose, mais normalement la combinaison est fonctionnelle. Elle est équipée d'un jetpack qui te permettra de te déplacer plus facilement. Bonne chance à vous deux et à bientôt !";

	public static var ITEM_GIVER_BADGE_FURI = "Bienvenue Compagnon !\nLe RCEH a besoin de tous les bras disponibles pour combattre l'expansion humaine. Nous n'avons pas de politique discriminatoire et votre origine humaine n'est pas un obstacle à votre adhesion à notre mouvement. Vous pourrez désormais participer aux operations de libérations de prisonniers et sabotage de materiel de l'ESCorp dans ce système.\nMerci pour votre aide!";

	public static var ITEM_GIVER_SAUMIR = "Noyaguld etranger ! Je suis Saumir.\nLes Kemiliens sont heureux de t'accueillir parmis eux. Notre peuple s'est retiré sur Holovan il y a plusieurs milliers d'années, nous ne souhaitons pas prendre part aux tatelbs de vos ethnies. Les jeunes civilisations comme les votres doivent parcourir une à une les marches de l'histoire pour comprendre le dessein du grand Koshmerate.\nQue Kluc soit avec toi etranger, prend ce jumeleur de balle, il te sera d'un grand secours.";

	public static var ITEM_GIVER_SACTUS = "Bonjour détenu.\nJe suis le docteur Sactus, mais tu peux m'appeler Doc. Ici c'est mon laboratoire je construis tous mes engins grâces aux matières ferreuses de Grimorn. Le Retrofuseur est ici, tu peux le prendre. Lorsque tu l'utiliseras, ne clique surtout pas avec ton majeur sur la souris, sinon tu seras téléporté au centre de la supernova de Zambreze ce qui aura certainement un effet desastreux sur ta structure moléculaire.\nJ'espere que tu as bien écouté mes instructoins! Ciao ! ";
	public static var ITEM_GIVER_SAFORI_0 = "Mon nom est Safori. Je me suis installé sur Nalikors apres l'explosion de ma planète natale Karbonis.\nMaintenant je suis bloqué sur cette planète. J'aimerai pouvoir exercer a nouveau mon activité principale : Je suis expert-archenieur. Je peux reproduire n'importe quelle machine ancienne si je possède les plans et les élements nécessaires...Malheureusement ici, il n'y a aucun projet sur lequel je puisse travailler.\nMerci de ta visite et à bientôt !";

	public static var ITEM_GIVER_SAFORI_1 = "Fantastique !!! Grâce a ces tablettes je vais enfin pouvoir me mettre au travail ! Voyons voir... mmmmh oui ça l'air interessant on dirait un système de guidage ancien. J'ai tout ce qui faut ici pour construire cela. Na bouges pas!\n............\n............\n............\n............\n............\n\nVoilà !\n C'est pour toi ! Grâce a ce nouveau système de guidage la portée radar de ton enveloppe a été améliorée.\nMerci pour les tablettes, je les garde avec moi !!!\nQue les portes de Shamu s'ouvre a toi mon ami !";

	public static var ITEM_GIVER_COMBINAISON = "Bonjour détenu, nous avons préparé votre combinaison. Veuillez remplir le formulaire DZ-578 et laissez vos empreintes dans les Zone A B et C de cet imprimé.\n...\nMerci\n...\nVoici votre combinaison.\nBonne chance.";

	public static var ITEM_GIVER_TABLET_KARBONIS_0 = "La mémoire de Karbonis ";
	public static var ITEM_GIVER_TABLET_KARBONIS_1 = [
		"coule dans nos veines",
		"est en chacun de nous",
		"ne doit pas disparaitre",
		"brille dans tes yeux",
		"est un trésor",
		"sera sauvegardée",
		"est le bien le plus precieux de Zonker",
		"est écrite dans le coeur de Shamu",
		"ne doit pas tomber entre de mauvaises mains",
		"est préservée dans ce lieu",
		"est enfouie dans chacun de ces asteroïdes",
		"voyage à travers l'espace et le temps.",
	];
	public static var ITEM_GIVER_TABLET_KARBONIS_2 = "...\nPrend cette tablette et protège là.";
	public static var ITEM_GIVER_TABLET_KARBONIS_3 = "Tu n'es pas le bienvenu ici.";

	public static var ITEM_GIVER_EMAP_0 = "Bienvenu terrien. Je pense que cette artefact ancien issu de ta civilisation pourrait t'aider a retrouver ta route. Je peux te l'échanger contre ::price:: minerais qu'en penses-tu ?  ";

	public static var BUTTON_PEOPLE = [
		"ACCEPTER",
		"REFUSER",
		"PARTIR",
		"DENONCER",
	];


	  ///////////////////
	 /// FURI MEMBER ///
	///////////////////

	public static var FURI_HELLO = [
		"Bonjour l'ami !\n",
		"Bonjour compagnon !\n",
		"Salut !\n",
		"Bienvenue chez moi !\n",
	];

	public static var FURI_ARGUE = [
		"Sais tu combien de planètes dans l'univers sont occupé ou exploité par les humains ? Plus de 35 Millions. 30% de ses planètes sont exploité par l'ESCorp qui sévit actuellement dans notre système.\n",
		"Depuis que l'ESCorp a commencé a envoyer ses détenus dans ce système, plusieurs planètes comme Tiboon ou Lycans ont été ravagées. Leur experiences dangeureuses ont même provoqué l'explosion de Karbonis, une planète autrefois florissante.\n",
		"Depuis leur arrivé leurs mepris des lois de la nature ont provoqué de véritables catastrophes naturelles. L'explosion de Karbonis, la baisse de natalité chez les Glurts de Moltear, la pollution des océans de Soupalines, toutes ces tragédies sont une abomination.\n",
		"L'ESCorp a commencé ses opérations de forage et d'exploitation carcerale dans ce système il y plus de 30 ans. Depuis leur arrivé leurs mepris des lois de la nature ont provoqué de véritables catastrophes naturelles. Le rechauffement des vents solaires, la baisse de natalité chez les Glurts de Moltear, toutes ces tragédies sont des conséquences de l'expansion humaine.\n"
	];

	public static var FURI_REWARD_MIN = "Je peux t'aider compagnon ! Prend ces :::rmin: minerais et fais en bonne usage.\nC'est tout ce qui me reste.";
	public static var FURI_REWARD_CAPS = "J'ai de quoi facililter ta quête mon ami! Prend ces ::rcaps:: CHS.\nGrâce a ton action la lutte continue !";

	public static var FURI_END_0 = "La Fondation pour l'Unification Rationelle de l'Infinie (F.U.R.I), ";
	public static var FURI_END_1 = [
				"propose des alternatives pour permettre a tous les peuples de l'univers d'exploiter ensemble les ressources de l'espace sans détruire la biodiversité stellaire de notre univers.",
				"s'oppose activement a une expansion humaine incontrolée en organisant des operations de sabotages destinées a affaiblir les grandes corporations humaine telle que l'ESCorp",
			];

	public static var FURI_BETRAY = [
		"Au secours !",
		"Vous avez fait un bien triste choix, mon ami.",
		"Pourquoi tant de haine ?",
		"Je suppose que l'ESCorp vous paie correctement pour ce travail...",
	];

	public static var FURI_LUCK = [
		"Bonne chance a toi!",
		"Accompli ta destinée, humain, sauve notre univers !",
		"Que les portes de Shamu s'ouvre a toi!",
	];

	//////////////
	/// GOSSIP ///
	//////////////

	public static var GOSSIP_CRYSTAL = "Lors d'un vol de routine en hyper-espace j'ai aperçu d'étranges lueurs roses en ::coord::, ce n'est pas vraiment courant a cette vitesse, il doit y avoir quelque chose d'interessant là-bas.";


	public static var GOSSIP_NOYAUX_0 = [
		"Une équipe entiere d'iron-cricket",
		"La capsule spatiale de mon oncle",
		"Une flotte entière de Balixtéens",
		"Une escadrille de 4 enveloppes de détenus ESCorp",
		"Une baleine stellaire de plus de 650 tonnes",
	];

	public static var GOSSIP_NOYAUX_1 = " a été mysterieusement aspirée par un point sombre dans l'espace. La brigade de secours de mon village a passé plus d'une semaine a ratisser le secteur ::coord::, mais ils n'ont rien trouvé.";

	public static var GOSSIP_TABLET = "J'ai survecu a l'explosion de Karbonis, mais ma famille entière a péri là-bas. Les restes de notre civilisation flottent desormais dans l'espace... *snif*. En explorant la ceinture d'asteroide j'ai trouvé une tablette Karbonite en ::coord::. Je n'ai pas pu la prendre avec moi car elle etait bien trop lourde !";

	public static var GOSSIP_ASPHALT = "Il parait que l'ESCorp travaille sur une balle de forage extrêmement puissante dans le Système de Stuklie situé loin au Sud-est de notre système.\nIls doivent envoyer le résultat de leur recherche d'ici peu.";

	public static var GOSSIP_DEFAULT = [
			"Plusieurs manifestations spatiales ont été organisées par Le FURI. L'année dernière, une délégation de plus de 350 représentants ont résussi a obtenir une audience avec le président de la confederation humaine sur terre.",
			"Je ne reverrai plus jamais mes amis de Karbonis. Laissez moi tranquile. Vous autres humains êtes incapables d'apprecier ce qui est réellement précieux.",
			"Les nébuleuses sont tellements lumineuses qu'elles gênent souvent la navigation des pilotes. Heureusement, nous autres pilotes, nous ne deplaçons jamais sans une paire de lunettes solaires.",
			"Je deteste la compote.",
			"Il ya dans l'univers des conglomerat halucinogènes tres puissants, qui peuvent totalement inverser vos sens.",
			"L'année dernière, mes vacances a Samosa était nulles, en une semaine, nous n'avons pas eu une seule journée de soleil !",
			"Les lapins-robots n'ont jamais réussi a rentrer dans notre système. Je pense que l'on devrait un peu moins se plaindre de la présence de l'ESCorp, depuis que les humains sont ici, il n'y a pas eu une seule guerre !",
			"Ma grand-mère a été enlevée a 28 ans par une patrouille de lapin-robots, nous ne l'avons jamais revu... C'est difficile a dire, mais je dois reconnaitre que la présence de l'ESCorp a contribué a sécuriser notre système.",
			];

	public static var GOSSIP_MISSILE_0 = "Alors que je me promenais aux alentours du secteur ::coord::, j'ai aperçu une carcasse de missile déchiqueté.\n";
	public static var GOSSIP_MISSILE_1 = [
		"L'espace est devenu une vraie poubelle.",
		"Les jeunes ne respectent vraiment plus rien...",
		"J'espere que les éboueurs de l'espace ont pu le récupérer.",
		"Je ne me suis pas approché de peur qu'il explose.",
		"Il était en piteux état.",
	];
}
