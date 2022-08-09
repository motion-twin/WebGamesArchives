import Text;

class TextFr {

	public static var EXTRA_LIFES = " vies supplémentaires";
	public static var EXTRA_LIFE  = " vie supplémentaire";
	public static var EXPLORING = "planète en cours d'exploration.";

	//
	public static function getText( i:Int ) : Tip {
		var text = [
		[ "Balle de forage RCD-20", "Elle peut détruire les conglomérats ferreux."								],
		[ "Balle OX-Soldat", "Elle peut détruire les molécules parasites."									],
		[ "Balle OX-Delta", "Sa puissance de forage est multipliée par deux."									],
		[ "Balle secrète :\nAsphalt-project", "Balle aux effets inconnus."									],

		[ "Missile standard", "Laisser appuyer sur la barre espace pour envoyer un missile destructeur."					],
		[ "Missile AR-57", "Sa puissance explosive lui permet de détruire jusqu'à 9 briques en un seul tir."					],
		[ "Missile MAS-Z", "Peut détruire n'importe quel conglomérat."										],
		[ "Missile AR-SRX", "Dégât de zone considérablement amélioré. Ce missile peut détruire jusqu'à 25 conglomérats."			],

		[ "Outils de perforation", 	"Vos drones désassemblent plus rapidement les sentinelles."			],
		[ "Support réacteur", 		"Vos drones se déplacent plus rapidement."					],
		[ "Convertisseur", 		"Vos drones convertissent les sentinelles en minerai."				],
		[ "Collecteur", 		"Vos drones peuvent collecter le minerai à votre place."			],

		[ "Carte des marchands", 	"Toutes les meilleures adresses pour améliorer votre enveloppe contre quelques minerais."	],
		[ "Carte des missiles", 	"Retrouver la trace de toutes les carcasses de missiles pour améliorer votre capacité de synthèse de missiles."],
		[ "Carte des trous noirs", 	"Les trous noirs vous permettront de voyager rapidement d'un bout à l'autre de la galaxie."],

		[ "Accréditation Alpha", 	"Un des trois pass vous autorisant a utiliser la balle de forage dans ce système."],
		[ "Accréditation Beta", 	"Un des trois pass vous autorisant a utiliser la balle de forage dans ce système."],
		[ "Accréditation Ceta", 	"Un des trois pass vous autorisant a utiliser la balle de forage dans ce système."],

		[ "Réacteurs latéraux", 		"Votre enveloppe peut pivoter plus rapidement pour lancer des missiles."],
		[ "Refroidissement liquide", 		"L'enveloppe peut tirer des missiles plus rapidement."],
		[ "Moteur de synthèse perpétuel", 	"L'enveloppe génère un missile a chaque nouveau secteur."],

		[ "Lunettes de soleil", 		"Annule les effets des molécules-flash et améliore la visibilité de certains amas stellaires trop lumineux." ],
		[ "Médaillon Zonkérien", 	"L'énergie incroyable qu'il dégage permet d'améliorer la stabilité et la rapidité des déplacement de l'enveloppe." ],
		[ "Antenne Ki-Wi", 		"Radar extra-terrestre à alimentation vitaminée (C et E). Amplifie tous les signaux radio environnants." ],
		[ "Antimatière", 		"Antimatière" ],
		[ "Ambro-X", 			"Augmente la portée de votre radar d'un point." ],
		[ "Accélérateur syntrogenique",	"Permet de créer une capsule d'hydrogène liquide par jour." ],
		[ "Rétrofuseur au lithium", 	"Il vous renvoie a votre position d'origine en un clin d'oeil." ],
		[ "Combinaison", 		"Vous pouvez sortir de votre enveloppe sur les planètes ou l'air n'est pas respirable." ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "Genemill", 			"Moteur a fission de quatrième generation, il a été transféré a l'ESCorp." ],
		[ "", 				"" ],
		[ "Jumeleur de Saumir", 	"Lors de la synthèse de votre premiere balle de forage, le jumeleur compose une seconde balle identique." ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "Médaillon incomplet", 	"C'est un petit médaillon Zonkerien, il semble incomplet." ],
		[ "", 				"" ],


		];
		return { title:text[i][0], desc:text[i][1] };
	}

	public static function getPlanet(i:Int) : String {
		var texts = [
		"Planète rocheuse a forte activité moléculaire parasite. Ancienne colonie des Zonkerien elle abrite une multitude de ruines essentiellement localisées dans l'hémisphère sud de la planète.",

		"Planète aux caractéristiques proches de la terre. Un processus de terra-formation standard a récemment été lancée sur Soupaline par l'ESCorp afin d'y établir dans un futur proche une colonie de forage.",

		"Planète volcanique géante, la forte concentration de conglomérats poutractif rend son exploration particulièrement dangereuse.",

		"Planète la plus volumineuse du système Zonkerien. Son incroyable densité et sa force de gravité exceptionnelle transforment toute opération de minage en course d'endurance sans fin.",

		"Planète désertique de petite taille. Peu de ressources minières exploitables.",

		"Planète mère d'une race extraterrestre technologiquement avancée. Relativement xénophobes, les balixtéens ont truffé le secteur de sentinelles et ne tolèrent aucune intrusions.",

		"L'explosion du réacteur principal d'une gigantesque exploitation minière a provoqué l'instabilité puis l'implosion du coeur de Karbonis. Une ceinture d'astéroïdes s'est formée autour du système Zonkérien, elle est appelée 'Ceinture de Karbonis'.",

		"La température à la surface de Spignysos ne dépasse jamais les -50°. Les vents glacés de surface altèrent la matrice de déplacement des enveloppes et empêchent les mineurs spatiaux d'agir librement. On appelle ce phénomène la stase spignysienne.",

		"La présence d'eau et le climat tempéré de Pofiak on permis le développement de jungles tropicales sur l'intégralité de sa surface. La présence d'insectes psioniques peut parasiter la matrice de déplacement de l'enveloppe.",

		"Planète gazeuse. La présence de frugi-azote saturé en fait un terrain incroyablement fertile pour les molécules parasites. Elles se développent ici plus vite que n'importe ou ailleurs.",

		"Planètes extrêmement riche en minerai, 75% de sa surface est cristallisée ou en cours de cristallisation. C'est naturellement la destination de prédilection de tous les mineurs spatiaux. Malheureusement des insectes psioniques infestent les régions les plus riches de Douriv.",

		"Planètes calcaire. C'est une planète morte comme on en trouve beaucoup dans tous les systèmes, son sol est pauvre et la présence de conglomérats métalliques empêche de toute manière une exploitation minière intensive.",

		"Planètes dépotoir où résident de redoutables monstres. Ils sont cependant organisés en société et vivent de l'exploitation d'une planète située dans une autre galaxie. La technologie leur permettant d'effectuer de si longs voyages reste a ce jour inconnue.",

		"Chaîne d'astéroïdes de Karbonis : L'ancienne planète a désormais laissé sa place a un vaste champs d'astéroïdes...",

		"Planète sèche à végétation éthérée. Cette planète sert de point de ralliement à tous les anarchistes de l'univers. Le FURI est le mouvement le plus représenté, il compte plus de 242 membres dans ce secteur.",

		"Planète rocheuse ancienne. C'est la terre de Kémilie : une civilisation vieille de plus de 120.000 ans. Dans un soucis de ne pas être dérangés les kemiliens ont truffé le ciel de sentinelles Kashuat.",

		"Planète herbeuse colineuse et sympathique. C'est un endroit ou il fait bon vivre, plusieurs colons ont décidé de fuir les problèmes politiques de leur galaxie pour rejoindre Khorlan. Seules les chutes de noisettes-orbitales perturbent leur vie paisible.",

		"Planète contenant de l'eau et une atmosphère respirable, Cilorile est pourtant évitée par la plupart des mineurs à cause de ses conglomérats gardiens. Leur contact provoque une explosion immédiate de l'enveloppe.",

		"Planète calcaire. Cette planète a été détruite il y a plusieurs années par une pluie de météorites.",

		"Planète calcaire morte depuis des millénaires. Son état de cristallisation avancé et sa position reculée dans le système Zonkerien en font une destination de choix pour les mineurs.",

		"Planète aux dimensions larges contenant assez d'eau pour abriter différentes formes de vies. Malgré un acces difficile, Volcer attire chaque année plusieurs milliers de touristes venant de tous les systèmes environnants.",

		"Planète épino-calcaire de type vocerone. La forte saturation en amidon de l'atmosphere a entrainé la prolifération de noisette-orbitales. Aujourd'hui seuls les pilotes les plus experimentés peuvent survoler Balmanch sans risquer un crash immédiat. ",

		"Planète gazeuse. L'implosion du coeur de Folket il y a plus de vingt-mille ans a entrainé une vaporisation perpetuelle des argiles chlorés de son sol. Une tres forte acidité des nappes de surfaces empeche les enveloppes non équipés d'un blindage suffisant d'atteindre son centre.  ",

		];
		return texts[i];
	}

	public static function getStar( i:Int ){
		return "Etoile "+["rouge","orange","jaune","verte","turquoise","bleue","violette"][i];
	}

	public static function getTip( k:TKind ){
		return switch (k){
			case TGenerator: {title:"Générateur de l'enveloppe", desc:"permet de parcourir $0 cases par capsule d'hydrogène."};
			case TDrone:  {title:"Drone de soutien", desc:"Il peut désamorcer les pièges présents dans certains conglomérats."};
			case TKarbonite: {title:"Tablette Karbonite", desc:"Effet inconnu"};
			case TAntimater: {title:"Noyaux d'antimatière", desc:"Une puissance de destruction colossale, vous en possédez $0/4"};
			case TCrystal:   {title:"Crystaux roses", desc:"L'interieur du crystal semble palpiter, vous en possédez $0/5"};
			case TLycans:	 {title:"Roche de Lycans", desc:"Sa température n'a pas diminué depuis que vous l'avez remonté dans l'enveloppe."};
			case TSpignysos: {title:"Roche de Spignysos", desc:"Une fine couche de givre apparait continuellement à sa surface."};
			case TAR57:	 {title:"Fusion" , desc:"La réaction chimique provoquée par la réunion des deux pierres permet la synthese des missiles AR57."};
			case TMine:	 {title:"Mine FORA 7R-Z" , desc:"Mine de forage a synthese automatique. Vous en possedez $0/4"};
			case TReactor:	 {title:"Réacteur de surface" , desc:"Il vous permet de survoler les planètes sa puissance est de $0 unité(s)."};
			case TPods:	 {title:"Pods d'atterrissage", desc:"Ces pods retractiles de $0 mètres de de long vous permettent d'atterrir sur un sol suffisament plat."};
			case TRadar:	 {title:"Radar", desc:"Le signal radar vous permet d'atteindre des positions inconnues situés a $0 cases de votre zone explorée."};
			case TEarthMap:	 {title:"Carte PID", desc:"C'est une carte d'origine terrienne. Une fois reconstituée elle vous donnera acces au coordonnées d'une planète. Il vous manque encore $0 partie(s)."};
			case TEarthMapComplete:	 {title:"Carte PID Complète", desc:"C'est une carte d'origine terrienne. La planète qui se dessine sous vos yeux vous semble familiaire. Au centre de la carte des coordonnées sont inscrites."};
		}
	}
}

















