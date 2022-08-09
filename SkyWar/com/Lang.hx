import Datas;

#if flash
import mt.bumdum.Lib;
#end

class Lang {//}

	static public var TOOLTIP_PRIORITIES = "Cliquez ici pour que votre flotte attaque prioritaire les bâtiments de type : ";

	static public var TABS = [
		"Événements",
		"Construction d'unités",
		"Chantiers en cours",
	];
	static public var IGH_TABS = [
		"Tenez vous au courant des dernières activité de cette île.",
		"Choisissez une ou plusieurs unités à construire.",
		"Liste de vos constructions en attente sur cette île.",
	];
	static public var ISLAND_CARACS = [
		"Population",
		"Nourriture",
		"Attaque",
		"Défense",
	];
	static public var IGH_ISLAND_CARACS = [
		"Plus vous possédez d'habitants, plus vos bâtiments et vos unités se construisent rapidement.",
		"Augmentez votre stock de nourriture pour faire croître votre population.",
		"Dégâts infligés par chacun de vos habitants aux unités ennemies en cas d'attaque.",
		"Un point de défense ajoute 10pts de vie à chaque habitant",
	];
	static public var PARAM_SECTION = [
		"Général",
		"Île",
		"Carte",
		"Diplomatie",
		"Bonus",
	];
	static public var PARAMS = [
		"Activer l'aide automatique",

		"Activer les liens rapides vers les îles proches",
		"Afficher uniquement les liens rapides vers les îles alliées",
		"Masquer les bâtiments/unités liés aux technologies inconnues",
		"Activer le stockage des unités dans le chantier",
		"Afficher le temps total du chantier",

		"Afficher les informations des îles en mode carte",
		"Afficher les points de vie des unités en mode carte",

		"Afficher l'heure des messages",
		"Afficher le pseudo des messages",
		"Afficher la portée des messages",

		"Animation du menu",
		"Activer la blobification des îles",
	];

	static public var MODULES = [
		"carte",
		"île",
		"inventions",
		"diplomatie",
	];
	static public var IGH_MODULES = [
		"Visionner toutes les îles de l'archipel, lancer des déplacements et des attaques.",
		"Retourner sur votre île principale, construire de nouveaux bâtiments ou unités.",
		"Arranger l'ordre de développement de vos technologies.",
		"Faire connaissance ou négocier des pactes secrets avec vos adversaires.",
	];
	static public var BUILDING_TYPE = [
		"ressource",
		"nourriture",
		"construction",
		"technologie",
		"défense",
		"population",
		"commandement",
		"spécial",
	];
	static public var BUILDING_TYPE_DESC = [
		"les bâtiments produisant les matériaux et l'éther.",
		"les bâtiments produisant la nourriture.",
		"les bâtiments servant à construire les unités.",
		"les bâtiments servant à améliorer les temps de recherche.",
		"les bâtiments offensifs ainsi que les bâtiments ajoutant des bonus de défense ou d'attaque à l'île.",
		"la population de l'île.",
		"le siège du commandant de l'armée adversaire.",
		"les bâtiments de réparation, les bâtiments apportant des bonus spécifiques.",
	];
	//static public var DESC_MATERIAL = 		"<b>Materiaux</b><br/><i>augmentation a chaque cycle</i>";
	static public var DESC_MATERIAL = 		"<b>Matériaux</b>";
	static public var DESC_ETHER  = 		"<b>Éther</b>";

	static public var END_CONSTRUCT = 		"Temps total : ";

	static public var TITLE_YARD = 			"Chantier";
	static public var TITLE_CONSTRUCT_SHIP = 	"Engins volants";
	static public var TITLE_CONSTRUCT_BUILDING = 	"Construction";
	static public var TITLE_FLEET = 		"Flotte";
	static public var TITLE_RESEARCH = 		"Recherches";
	static public var TITLE_WAR = 			"Attaques";

	static public var LACK = 	"Pas assez ";
	static public var LACK_ETHER = 	"Nécessite un geyser";
	static public var LACK_GEYSER = "Impossible à construire sur un geyser";
	static public var QT_MATERIAL = "de matériaux";
	static public var QT_CLOTH = 	"de tissu";
	static public var QT_ETHER = 	"d'éther";
	static public var QT_POP = 	"de population";
	static public var QT_VOLUME = 	"de place";

	static public var NECESSARY = 		"nécessaire";
	static public var YOU_NEED_RESSOURCES = "Il vous manque ";
	static public var ALREADY_BUILT = 	"Vous avez déjà construit ce bâtiment.";
	static public var POP_LIMIT = 		"Vous avez atteint la limite d'unités maximum.";
	static public var MUST_BE_BUILD_BEFORE = "est nécessaire avant";
	static public var MUST_BE_BUILD_BEFORE2 = "sont nécessaires avant";

	static public var MODE_BASIC =		"mode simple";
	static public var MODE_ADVANCE =	"mode avancé";

	static public var CONSTRUCT_SHIPS = 	" construction$s en cours...";
	static public var CONSTRUCT_OK = 	"construction en cours";
	static public var CONSTRUCT_NOT_OK = 	"construction impossible";
	static public var CONSTRUCT_PAUSE = 	"jeu en pause";

	static public var CHOOSE_ISLAND = 	"Choisissez une ile de depart.";
	static public var WAITING_PLAYERS = 	"Attente de nouveaux joueurs : jeu en pause.";
	static public var GAME_END = 		"Fin de la partie";

	static public var NEVERENDING_LOOP = 	"attaque continue";

	static public var TOO_MANY_SAVE_TECHNO =  "Trop de stratégies enregistrées. Effacez des stratégies pour pouvoir enregistrer à nouveau.";
	static public var SAVE_TECHNO =  "Sauvegarder l'ordre des technologies";
	static public var LOAD_TECHNO =  "Charger l'ordre des technologies";

	static public var ERROR = "Erreur";
	static public var YES = "Oui";
	static public var NO = "Non";
	static public var DROP_FLEET_CONFIRM = "Confirmation d'atterrissage";
	static public var SEND_FLEET_CONFIRM = "Envoi de la flotte";
	static public var CANCEL = "annulation";
	static public var CANCEL_FLEET_CONFIRM = "Annulation du mouvement";
	static public var DELETE_FLEET_CONFIRM = "Destruction d'unité(s)";
	static public var ARE_YOU_SURE = "En êtes-vous certain ?";
	static public var ARE_YOU_SURE_BACK_UNAVAILABLE = "Attention, il n'est pas possible d'annuler un trajet dont l'île de départ n'est pas à vous !\nConfirmer le trajet ?";

	static public var DESTROY = "detruire";
	static public var ENTER_TEXT = "entrez votre texte ici";
	static public var SHIP_CAR = [ "structure", "attaque", "armure", "vitesse", "portée" ];

	static public var REMAINING_TIME = "Temps restant";
	static public var CYCLE_REMAINING_TIME = "Temps restant avant le prochain cycle";
	static public var NEXT_POP = "prochain habitant :";

	static public var DELETE_YARD_SLOT = "Annuler";
	static public var GET_BACK_RESSOURCES = "regagner 100% des ressources dépensées.";
	static public var SHIFT_DELETE_ALL = "shift+click pour annuler tout le groupe.";

	static public var SEE_PREV_FLEET = "Voir la flotte précédente";
	static public var SEE_NEXT_FLEET = "Voir la flotte suivante";
	static public var FLEET_ONE_WAY = 	"Aller simple";
	static public var FLEET_ONE_WAY_DESC = 	"Votre flotte se rend à l'île indiquée et revient si l'île est occupée.";
	static public var FLEET_ROUND = 	"Aller retour";
	static public var FLEET_ROUND_DESC = 	"Votre flotte se déplace sans cesse vers l'île indiquée tant que celle-ci est occupée";
	static public var FLEET_AUTO_DROP = 	"Atterrissage automatique";
	static public var FLEET_AUTO_DROP_DESC = "Une des unités de la flotte possédant <i>colonisation</i> atterrira automatiquement sur une l'île de destination, si celle ci est inoccupée";
	static public var FLEET_STRIKE = "Frapper prioritairement";

	static public var FLEET_ACTIONS = [
		"Envoyer les unités sélectionnées vers une île à portée de vol.",
		"Les unités sélectionnées possédant <i>colonisation</i> atterrissent sur l'île.",
		"Abandon du trajet : retour vers l'île de départ ($0).",
	];


	static public var IGH_BUILDING = [
		"Bâtiment principal de votre civilisation, il assure 5 unités de nourriture, et 7 matériaux par cycle.",
		"Produit 4 matériaux à chaque cycle.",
		"Assurent 2 unités de nourriture.",
		"Permet la construction des Drakkars (1/2), Ballons, Bombardiers, Mires et Atlas (1/2).",
		"Permet la construction des Apicopters, Drakkars (1/2) et Harpies (1/2)",
		"Produit 1 éther à chaque cycle.",
		"Augmente l'attaque de votre île de 1 points, augmente la limite d'unités de 2 points. permet de construire les Harpies (1/2) et les Condors (1/2)",
		"Améliore de 30% la vitesse de déplacement des troupes alliées rejoignant cette île",
		"Diminue les temps de recherche de 25%. (non-cumulable)",
		"Diminue les temps de recherche de 40%. (non-cumulable)",
		"Diminue les temps de recherche de 10%. (cumulable)",
		"Assure 3 unités de nourriture.",
		"Chaque champ produit 2 unités de nourriture supplémentaire.",
		"Inflige 15 dégâts lors des attaques aériennes.",
		"Répare 1 point de structure à chacun de vos bâtiments à chaque cycle.",
		"Permet de construire les Condor (1/2), Atlas (1/2) et Fantômes. Réduit de 10% le temps de construction des unités.",
		"Inflige 35 dégâts lors des attaques aériennes.",
		"Inflige 30 dégâts par cycle sur l'île ennemie la plus proche (l'Archimortier a une portée de 300).",
		"Produit 2 matériaux à chaque cycle.",
		"Augmente la défense de votre île de 3 points.",
		"Diminue de 30% le temps de construction des bâtiments. Diminue de 20% le temps de construction des vaisseaux",
		"Augmente de 4 points la défense de votre île et inflige 60 dégâts lors des attaques aériennes.",

		"Bâtiment principal de votre civilisation, il assure 5 unités de nourriture et produit 5 matériaux et 2 éthers par cycle.",
		"Produit 2 éthers par cycle.",
		"Assure 1 unité de nourriture.",
		"Permet d'invoquer des unités du plan éthéré.",
		"+1 unité maximum, +1 en défense.",
		"Permet de sculpter des unités, le temps de création des golems est réduit de 50%.",
		"Assure 2 unités de nourriture.",
		"Diminue le temps des recherches de 15%. (cumulable)",
		"Augmente de 3 points l'attaque de l'île et permet de contrôler 5 unités supplémentaires.",
		"Inflige 10 dégâts lors des attaques aériennes.",
		"Produit un matériau par cycle.",
		"Les golems de l'île rapportent 1 matériau par cycle.",
		"Les golems infligent 15 dégâts supplémentaires à chaque attaque aérienne.",
		"Répare 3 points de structure par cycle d'une unité sculptée. Répare 5 points de structures par cycle d'un bâtiment.",
		"Réduit de 15% les temps d'invocation.",
		"Lors d'une attaque aérienne, une unité vous attaquant gagne la capacité parasite.",
		"Toutes vos fontaines et sources sacrées apportent un point d'éther supplémentaire par cycle.",
		"Permet d'invoquer des unités légendaires du plan éthéré.",
		"Les troupes attaquant l'île perdent la capacité Furtivité et voient leur ciblage divisé par deux.",
		"Produit 4 éthers par cycle.",
		"Répare 1 point de structure par cycle d'une unité invoquée.",
		"Les Hoplites et Goliath en partance de cette île gagnent 200 points de portée et 100 points de vitesse (trajet aller uniquement)."
	];

	static public var FLAVOUR_BUILDING = [
		"Le gouverneur vit dans un somptueux palais. C'est depuis celui-ci qu'il dirige l'île. C'est le bâtiment le plus précieux des Skatchs, si il est détruit, plus aucun ordre ne pourra être donné.",
		"Les Skatchs se servent des minerais présents dans le sol des îles pour construire leurs maisons et leurs appareils. Dans ce domaine, creuser un trou plus gros que les autres s'est rapidement imposé comme la solution la plus efficace.",
		"Les Skatchs cultivent en grande quantité le gründ, la seule céréale allergique à l'eau. Leurs champs sont donc astucieusement imperméabilisés grâce à de gigantesques arceaux.",
		"La toile est un matériau traditionnel de la civilisation Skatch. Les tisserands extraient les fibres des sols de l'île et les tressent jusqu'à obtenir une toile dense et résistante imperméable à l'éther.",
		"L'atelier est le lieu de toutes les expérimentations. C'est ici que sont fabriqués les premiers appareils volant des Skatchs. Ils sont généralement peu coûteux et peu fiables.",
		"Les pompes sont utilisées pour gonfler les appareils volant de type ballon. Elles ne peuvent être construites qu'au dessus d'un geyser naturel d'éther.",
		"Les casernes entraînent votre population à résister à une invasion. En cas d'attaque les alarmes des casernes donnent l'alerte.",
		"Les scouts sont trop souvent soumis à la météo ou l'humeur des voisins, le mieux, c'est encore d'observer... de loin.",
		"L'école forme un grand nombre de jeunes Skatchs qui deviendront des savants plus tard. Autant de savants cela peut paraître inutile, mais un savant ça meurt vite, très vite...",
		"Les universités furent presque toutes détruites en mai 2068 par le Grand Skatch. Après sa mort, certains ont vite compris que plus un savant a fait d'années d'études, moins il a de risques de mort prématurée.",
		"Une explosion de laboratoire annonce souvent l'arrivée d'une nouvelle technologie destructrice pour nos armées.",
		"Les troupeaux d'ovidron refusent de manger le gründ à l'état naturel. L'essentiel du travail des fermiers consiste à inventer des recettes toujours plus innovantes pour convaincre leur cheptel.",
		"Le gründ une fois moulu est extrêmement volatile. Il doit immédiatement être stocké dans des sacs de toile ou transportés vers le palais via une gründoline.",
		"Les artificiers Skatch sont triés sur le volet, ils peuvent dégommer une cormouette à plus de 100m.",
		"Au début les pompiers servaient uniquement à sortir les tochons coincés dans les puits à éther. Les récentes guerres ont montré qu'ils ont d'autres utilités...",
		"La manufacture dispose d'une fonderie lui permettant de mouler de larges pièces de métal. À l'intérieur du bloc de travail la température dépasse fréquemment les 50°.",
		"En projetant des jets concentrés d'éther à une pression suffisamment élevée, il est possible de déclencher à l'impact une explosion puissante.",
		"L'archimortier est le fruit d'années d'expériences en terme de mauvais voisinage. Bien qu'un peu bruyant, il vous permettra d'instaurer rapidement une paix définitive et durable dans l'archipel.",
		"Surchauffe l'éther à plus de 500°",
		"La courbe de Stueling (célèbre stratège Skatch, auteur de 'L'échec sans douleur') indique qu'en période de raid les chances de survies sont inversement proportionnelles à la hauteur des habitations.",
		"Étonnamment, faire un croquis de la future construction évite les retards causés par un parquet posé à la place d'un plafond.",
		"Un vrai moustachu sait qu'on est toujours mieux au frais et derrière un mètre d'acier et quelques canons.",

		"Le temple abrite un fragment de la pierre d'âme de Ismaar. Elle est régulièrement consultée par l'oracle afin de montrer la voie au peuple Dangren ",
		"Les fontaines sont le coeur de la civilisation Dangren, l'éther s'y écoule paisiblement en ondes laiteuses.",
		"Les Dangrens ne partagent pas leur nourriture, les champs de maoïs sont à usage personnel et ne nécessitent aucun entretien particulier.",
		"Le grand Menhir aussi appelé porte médiane est le lien principal entre le plan éthéré et le monde de Sky. Les Dangrens s'y relaient nuit et jour pour chanter la louange des créatures étranges peuplant ce monde afin de les attirer dans leur village.",
		"Les Dangrens vivent dans de petites maisons individuelles qu'ils repeignent à chaque cycle stellaire.",
		"Le sculpteur est le second personnage le plus important après l'oracle. Il est l'héritier de la culture shamanique Dangren et lui seul peut insuffler l'éther-vie dans les sculptures du peuple.",
		"Chez les Dangrens la culture des plantes est une science liée à l'architecture, on étudie ainsi la façon la plus agréable mais également la plus utile de disposer les arbres et les fleurs parmi les bâtiments.",
		"Les cristaux primordiaux contiennent le savoir de plus de 200 générations Dangren. Au contact d'une source d'éther ils s'épaississent rapidement rendant ainsi leur contenu lisible à tous.",
		"Une minorité de Dangrens refuse d'être servie par les créatures du plan éthéré et les golems. Ils revendiquent un retour à l'éducation physique et psychique afin de retrouver la souplesse et les pouvoirs psioniques de leurs ancêtres.",
		"Les golems sont les serviteurs les plus fidèles des Dangrens. Ils effectuent toutes les tâches pénibles et protègent la cité contre les envahisseurs.",
		"La forêt apporte aux Dangrens une source renouvelable de matériaux pour leurs constructions. Elle est un complément appréciable aux ressources du temple qui ne suffisent généralement pas à contenter les besoins du peuple.",
		"Les Dangrens n'ont ni la force ni la volonté nécessaires pour effectuer des travaux aussi complexes qu'ils délèguent bien volontiers à leurs fidèles golems.",
		"Les golems pulvérisent les attaques ennemies grâce à des rayons concentrés d'éther. Le chaudron leur permet de surchauffer celui-ci afin d'améliorer ses propriétés explosives à l'impact.",
		"La remise en état d'une unité sculptée relève autant de la mécanique que de l'animisme. Le sculpteur ne peut assumer une telle tâche sans l'appui du matériel adéquat.",
		"La chorale permet aux Dangrens d'accéder aux 3 cordes vocales sacrées. Il peuvent ensuite entonner les polyphonies yottatonique qui attirent les créatures du plan éthéré majeur et repoussent les envahisseurs dotés d'un système auditif fonctionnel.",
		"Les fleurs de Solimène libèrent un pollen épais qui grippe les machineries Skatch, gratouille les sculptures Dangrens, encombrent les bronches des troupes invoquées diminuant considérablement leur capacité pulmonaire... bref c'est une belle tochonerie pour tout le monde.",
		"La purification de l'éther permet d'en retirer toutes les impuretés minérales. On obtient ainsi une fluidité similaire à celle d'un lait d'ovidron demi-écrémé.",
		"L'orbe est la 'grande porte' vers le plan éthéré. La sculpture de l'orbe est un travail colossal puisqu'un diamètre d'au moins 8 mètres est nécessaire pour appeler les unités légendaires les plus petites.",
		"Le spray d'éther est un moyen efficace pour lutter contre les raids invisibles qui affaiblissent les cités. L'éther est pulvérisé en une poudre si fine qu'elle reste pendant des heures en suspension, trahissant ainsi le moindre mouvement aérien.",
		"La source est la fontaine sacrée, en creusant jusqu'au coeur de l'île, les Dangrens puisent un éther d'une densité telle que son éclat illumine la cité pendant la nuit.",
		"Les fruits sucrés du poirier scintillant sont les seuls aliments physiques que les créatures du plan éthéré peuvent absorber.",
		"Face aux difficultés et aux dangers liés à l'enseignement de la lévitation aux golems, le syndicat des sculpteurs fit accepter aux prêtres la mise en place exceptionnelle d'une aide mécanique.",
		//		"Avant son invention les Dangrens faisaient atterrir un Gorgre géant sur un gigantesque Tape-cul qui projetait le Golem à une vitesse prodigieuse... cela manquait de précision et l'équipement prenait deux fois plus de place.",
	];


	static public var RESSOURCES = [ "matériaux", "tissu", "éther", "habitant(s)" ];

	static public var BUILDING = [
		// SKATCH
		"Palais", "Carrière", "Champs", "Tisserand", "Atelier", "Pompe", "Caserne", "Tour de guet", "École", "Université", "Laboratoire", "Ferme", "Moulin", "Canon", "Pompier", "Manufacture",	"Hurleur", "Archimortier", "Fonderie", "Bunker", "Architecte", "Fort",
		// DANGREN
		"Temple", "Fontaine", "Champs", "Menhir", "Maison", "Sculpteur", "Jardinier", "Crystal", "Dojo", "Golem", "Forêt", "Mine", "Chaudron", "Forge", "Chorale", "Fleurs de Solimène", "Réservoir de purification", "Orbe", "Pulvérisateur", "Source sacrée", "Arbre magique", "Canon à Golem"

	];

	static public var SHIP = [
		// SKATCH
		"Apicopter", "Drakkar", "Ballon", "Bombardier", "Harpie", "Mire", "Condor", "Atlas", "Fantôme", "Gaia",
		// DANGREN
		"Gorgre errant","Piranha","Hoplite","Hydron","Venefict","Gorgre géant","Polpide sacré","Dragon","Goliath","Arpenteur célèste"
	];

	static public var RESEARCH = [
		// SKATCH
		"Parachute", "Tissu fortifié", "Boucliers latéraux", "Service militaire", "Double hélice", "Poudre à canon", "Pistons flexibles", "Aciéther", "Napalmiel", "Restauration", "Vrille", "Lentille", "Machine à coudre", "Engrais éthéré", "Tracteur", "Bombardement tactique", "Communication", "Loi martiale", "Voile extensible", "Géologie", "Astronomie", "Propulsion éthérée", "Éthéroduc", "Fusion cubique", "Cheminée impériale", "Vernis alvéolé", "Treuil","Pillage","Missile clairvoyant", "Invasion",
		// DANGREN
		"Héritage Dangren", "Sculpture avancée", "Papier translucide", "Nageoires-rasoir", "Pilon", "Éthéropoing", "Pierre de Zoreth", "Peau de granit", "Recyclage", "Souffle de feu", "Subvention du conclave", "Graine fossile d'Arcadie", "Élevage", "Pieux urticants", "Cimetière", "Marbres poreux", "Avoine anabolisant", "Art Martial", "Lance télescopique", "Potion épicée", "Griffes empoisonnées", "Corne d'abondance", "Lévitation","Truelles libellules","Douche purifiante","Dryades","Etheruption","Golémissaire","Lucioles laser","Portillon éthéré",
		// SKATCH UP1
		"Harpon divin",
		// DANGREN UP2
		"Cuirasse souple",
		// SKATCH UP3
		"Epouvantail lance-missile",
		// DANGREN UP4
		"Flamme d'Arcadie",
		// SKATCH UP5
		"Escorte"
	];

	static public var ATTACK_BUILDING = 	"Les bâtiments ont perdu $0pts de structure.<br>";
	static public var ATTACK_DAMAGE = 	"$0 inflige $1pts de dégâts.<br>";
	static public var ATTACK_CASUALTY = 	"$0 a perdu $1.<br>";
	static public var ATTACK_CASUALTY_POP = "$0 a perdu $1 habitant$2<br>";
	static public var ATTACK_CASUALTY_POP2 = "$0 a perdu $1 habitant$2 ($3 dégâts)<br>";
	static public var ATTACK_TOWER = "La défense inflige $0pts de dégâts.<br>";
	static public var NOTHING_HAPPEN = "Rien ne se passe";
	static public var INVASION_OK = 	"$0 a envahit $1 !";
	static public var INVASION_NOT_OK =	"l'invasion de $0 est repoussée !";
	static public var DEFEAT = 		"$0 a perdu le contrôle de l'île !<br>";
	static public var COLONIZE = 		"$0 prend le contrôle de l'île !<br>";

	static public var IGH_RESEARCH = [
		// SKATCH
		"Vos Apicopters gagnent la capacité Colonisation.",
		"L'armure des Ballons, Bombardiers, Mires et Atlas est augmentée de 1 point.",
		"Vos Drakkars gagnent 30 points de structure et 1 point d'armure.",
		"+1 att / +1 def sur toutes vos îles.",
		"La vitesse de vos appareils est augmentée de 20 points et de 100 points pour les Apicopters.",
		"Permet de construire le Fort, le Canon, le Bombardier et l'Archimortier.",
		"Augmente de 100 point la vitesse des Condors, Harpies et Gaïas.",
		"Augmente l'armure des Condors, Fantômes et Gaïas de 3 points.",
		"Ajoute la capacité Bombardier(50) à vos Atlas.",
		"Vos ateliers réparent 5 points de structure d'appareil par cycle.",
		"Le temps de construction des carrières est diminué de 50%.",
		"Augmente de 20 points les dégâts des Mires et leur donne la capacité Répartition.",
		"Les temps de constructions des Ballons, Bombardiers, Mires et Atlas sont réduits de 30%.",
		"Vos champs produisent 2 pts de nourriture de plus.",
		"Vos champs produisent 4 pts de nourriture de plus.",
		"Ajoute une cible à 60% dans vos objectifs d'attaque.",
		"+30 unités maximum.",
		"+2 att sur toutes les unités mais +25% temps de construction des bâtiments.",
		"La vitesse des Drakkars est augmentée de 100 points.",
		"Les carrières apportent 1 point de matériau supplémentaire par cycle.",
		"Augmente la portée de tous les Apicopters, Drakkars, Ballons, Bombardiers, Harpies de 100 points.",
		"Permet de construire les Fantômes à la manufacture.",
		"Les pompes apportent 1 point d'éther supplémentaire par cycle.",
		"Augmente de 100 point la vitesse des Atlas et des Mires. Permet de construire les Gaïas.",
		"Votre palais dépense 1 éther à chaque cycle pour produire 3 matériaux.",
		"Tous vos vaisseaux gagnent 10 pts de structure, vos vaisseaux sont immunisés aux effets des parasites.",
		"La portée et la vitesse de vos ballons et bombardier est égale à la portée et la vitesse de l'unité la plus performante de la flotte.",
		"Lorsque vous rasez un bâtiment, vous gagnez un nombre de ressources équivalent à 25% de son prix.",
		"Les Condors et Fantômes gagnent 5 points d'attaque.",
		"À chaque fois que vous détruisez un palais ou temple ennemi avec une flotte, vous prenez immédiatement possession de l'île avec un fort et un habitant.",

		// DANGREN
		"Vous obtenez 200 matériaux.",
		"Permet de construire les Dragons et les Goliaths.",
		"Les Piranhas gagnent la capacité Furtivité.",
		"Les Piranhas gagnent +3 en attaque.",
		"Les Hoplites gagnent la capacité bombardement(20).",
		"Les Golems, Hoplites et Goliaths gagnent +10 dégâts.",
		"Vos temps de recherche sont diminués de 25%.",
		"Les Golems, Hoplites et Goliaths gagnent +3 points d'armure.",
		"Lorsque vous détruisez un de vos bâtiments vous récupérez 100% de ses ressources.",
		"Les dragons gagnent la capacité répartition.",
		"Lorsqu'une recherche est achevée vous gagnez 40 matériaux et 40 éther.",
		"Le temps de construction des forêts est divisé par 2.",
		"Vos îles gagnent toutes un bonus de 3 points en nourriture.",
		"Vos îles infligent 5 points de dégât à tous les vaisseaux ennemis en fin de combat.",
		"Lorsqu'une de vos unités est détruite dans un combat, vous gagnez 20% de son coût en éther.",
		"Les Hoplites et Goliaths gagnent 100 pts de vitesse et perdent 15 points de structure.",
		"Les troupes invoquées gagnent 20 points de structure.",
		"Vos dojos gagnent 3 pts d'attaque, les Hydrons et Arpenteurs gagnent 3 pts d'attaque.",
		"Les Hydrons gagnent la capacité initiative.",
		"Les Hydrons, Vénéficts, Gorgres errants et Gorgres géants gagnent 100 points de vitesse.",
		"Les Gorgres errants gagnent 5pts d'attaque et la capacité corrosif.",
		"Votre temple génère 8 matériaux et 8 éther à chaque cycle.",
		"Permet de créer l'unité Arpenteur céleste au dojo.",
		"Le temps de construction des bâtiments est réduit de 30%.",
		"À chaque cycle, chaque fontaine retire un statut négatif sur une unité survolant l'île.",
		"Vos forêts apportent 1 éther supplémentaire à chaque cycle.",
		"Vos sources sacrées apportent 4 éthers supplémentaires à chaque cycle.",
		"Si vous attaquez avec un seul Hoplite ou Goliath, les dégâts qu'il infligera seront doublés.",
		"Le temps de création des unités sculptées est réduit de 50%.",
		"Tous vos bâtiments gagnent 1 point d'armure.",

		// Update SKATCH DIVINE_HARPOON,
		"Vos Apicopters et Drakkars gagnent 3 points d'attaque.",
		// Update DANGREN FLEXIBLE_CUIRASS
		"Vos Vénéficts, Hydrons et Polpides gagnent 2 points d'armure.",
		// Update SKATCH MISSILE_STRAWMAN
		"Vos champs infligent 2x10 points de dégât à chaque attaque.",
		// Update DANGREN ARCADIE_FLAME
		"Toutes vos unités gagnent 1 point d'attaque.",
		// Update SKATCH ESCORT
		"Pour chaque unité non Apicopter que vous produisez, une unité Apicopter apparaît (consomme 1 population).",
	];
	static public var FLAVOUR_RESEARCH = [
		// SKATCH
		"La plupart des appareils skatch sont incapables d'atterrir correctement sur les îlots. La priorité fut donc rapidement portée sur la survie des pilotes plutôt que sur celle du matériel.",
		"Les renforts métalliques bien qu'ils alourdissent quelque peu les ballons, sont un excellent moyen de franchir les nuages de pik-pik migrateurs sans encombres.",
		"Les flanc-boucliers sont historiquement la première amélioration militaire des appareils Skatch. Ils apparurent lors des grandes guerre civiles il y a plus de 200 ans.",
		"Chaque citoyen Skatch doit être capable de protéger le gouverneur jusqu'à sa mort !",
		"La double-hélice c'est une invention formidable qui nous a permis à long terme d'atteindre des archipels jamais explorés. À court terme, ça a coûté un paquet de doigts.",
		"Après la moustache et l'acier, la poudre à canon est le sujet le plus populaire dans la poésie Skatch. On ne compte plus les louanges à la « poussière d'ouragan » dans les contes et les chansons populaires.",
		"Les pistons flexibles sont virtuellement incassables. En réduisant le nombre de pannes en vol qui sont les plus longues à réparer, mais également les plus dangereuses, les Skatchs ont ainsi considérablement diminué leur temps moyens de vol (et leur temps de chute par la même occasion).",
		"En mêlant les métaux lourds qu'ils affectionnent tant, à des micro-bulles d'éther, les Skatchs ont inventé un acier ultra-léger et résistant permettant d'améliorer grandement le blindage de leurs appareils.",
		"Les flamabeilles produisent un miel en ébullition naturelle et permanente. Ce miel est si inflammable que l'explosion de ruche est aujourd'hui la cause principale de mortalité chez les jeunes fermiers Skatch.",
		"Les appareils volant subissent de terrible dégâts durant les batailles. Ceux qui arrivent à atterrir peuvent subir une thalasso-mécanique à l'atelier, les autres sont condamnés à chuter infiniment dans les limbes de Sky.",
		"C'est en effectuant des concours de looping en apicopter que les Skatchs s'aperçurent de l'incroyable puissance de forage de ceux-ci. Des apicopters modifiés furent alors utilisés pour le forage des carrières, puis la vrille fût inventée.",
		"En concentrant les rayons lumineux du soleil les mires sont capables de générer un faisceau lumineux de température très élevée pouvant transpercer n'importe quel type de blindage.",
		"La mise en place des machines à coudre a permis aux usines Skatch de multiplier le rendement des tisserands.",
		"En réinjectant de l'éther liquéfié dans les sols, il est possible d'augmenter grandement le rendement des terres. Il est alors possible de doubler les récoltes trimestrielles de gründ.",
		"Le tracteur sert principalement, grâce à son poids, à augmenter la densité des sols dans lesquels le gründ est semé. Pour cela il suffit simplement de rouler dans les champs pendant des heures.",
		"Pendant les batailles c'est le bazar : ça cours, ça tire, ça crie, et au final on ne sait plus vraiment très bien sur qui ou sur quoi on tape. Le bombardement stratégique consiste à se mettre tous d'accord au début de la bataille sur la cible à abattre.",
		"Le système radio-téléphonique des engins Skatch permet aux généraux d'organiser leurs troupes sans avoir besoin de crier trop fort, ou de leur apprendre à reconnaître les pigeons qu'ils ne doivent pas manger.",
		"La loi martiale c'est : Les Femmes et les enfants d'abord... sur la ligne de front !",
		"Grâce à un astucieux système de pliage en 4, les drakkars peuvent désormais s'équiper de voiles quatre fois plus grandes et ainsi profiter au mieux de la brise skienne",
		"En effectuant un minimum de recherche, il est désormais possible d'obtenir plus de matériaux en creusant moins de galeries. C'est pratique et ça limite les risques d'affaissement des bâtiments voisins.",
		"En se positionnant par rapport aux étoiles, les Skatchs peuvent atteindre des îlots qui ne sont pas directement visible depuis leur point de départ.",
		"En injectant une grande quantité d'éther dans un espace confiné, il est possible d'envoyer certains appareils beaucoup plus vite et beaucoup plus loin que leur pilote ne le souhaiterait.",
		"En centralisant le système de pompage de l'éther, les pertes lors de l'exploitation sont réduites à zéro.",
		"En créant un cube parfait de métal il est possible de lancer un phénomène de dégradation automatique de la structure des atomes composant ce cube. Une somme extraordinaire d'énergie est alors libérée permettant de déplacer d'énormes appareils.",
		"La cheminée doit absolument être construite à l'intérieur même du palais. Le gouverneur ne saurait tolérer qu'un édifice s'élève au dessus de sa propre demeure.",
		"Le miel des flamabeilles peut être utilisé pour créer un vernis très collant qui augmente la solidité des coques des appareils Skatch.",
		"Les ballons ont tendance à avancer là ou le vent les porte, ce qui n'est pas très efficace d'un point de vue strictement militaire. Grâce au treuil, les Skatchs ont pu organiser leurs flottes de façon bien plus efficace.",
		"À force de ramener des souvenirs des batailles, les soldats Skatch finirent par mettre en place un véritable circuit économique parallèle alimentant les chantiers en ressources diverses et variées.",
		"Les missiles clairvoyants Skatch ont la réputation de savoir où tu vas tourner avant même que tu n'aies enclenché ton clignotant.",
		"Dès leur plus jeune âge les Skatchs apprennent à construire de petits fortins et s'entraînent à la guerre. Certains fortins sont plus gros que d'autres et les mieux défendus rapportent des prix à leurs constructeurs.",

		// DANGREN
		"L'oracle et ses prêtres après un examen approfondi de la pierre d'Ismaar dévoileront au peuple le secret de la génération spontanée.",
		"Les sculpteurs les plus habiles peuvent donner vie à d'effroyables automates.",
		"Le papiéther composant les piranhas peut être rendu semi-transparent par l'application d'un vernis à base de poudre d'ortimoré, une plante très timide qui ne pousse que si on ne la regarde pas.",
		"Les piranhas se faufilent rapidement et habilement autour des défenses. En affûtant correctement leur nageoires, ils peuvent laisser au passage de profonds sillons au coeur des bâtiments et des appareils ennemis.",
		"Arrivés au bout de leur chemin, après de longues heures de vol ininterrompu, les hoplites sont généralement ravis de faire ce qu'ils savent faire le mieux : ne pas voler.",
		"« Lorsque les golems s'abattirent sur notre cité, ce fut un gigantesque chaos de poings volants qui éventrèrent nos maisons, tels des météorites fou furieux, fumant et hurlant, détruisant sans relâche.»",
		"La pierre de Zoreth ne contient pas d'information cruciale sur les technologies Dangren. En revanche c'est un véritable dictionnaire des différents patois de la langue ce qui facilite grandement la lecture des autres pierres.",
		"En surchauffant les golems juste après y avoir insufflé l'éther-vie les sculpteurs parvinrent à augmenter leur solidité face aux chocs les plus violents.",
		"Les Dangrens n'aiment pas trop jeter. Sans doute car ils ont conscience d'être isolés sur un îlot flottant aux ressources non-renouvables.",
		"Les gerbes enflammées ne font pas de détail. Si les appareils ennemis sont un peu trop regroupés, c'est le carnage immédiat.",
		"Face à l'abandon progressif de l'usage des cristaux par les plus jeunes, les sages du conclave instaurèrent une subvention pour chaque nouvelle étude de cristaux menée à son terme.",
		"Cette graine vient de la légendaire terre d'Arcadie dont les Dangrens sont originaires. Cette terre est réputée pour recouvrir le ciel tout entier, de sorte que nul ne puisse en chuter.",
		"Les recommandations du prophète Ismaar interdisent aux Dangrens de manger tout type de viande à l'exception du tochon. Le tochon est considéré comme pur, surtout la tête qui est un des trois aliments sacrés.",
		"Les pieux urticants sont installés de manière à repousser les ennemis grâce aux nuages de micro-puces qui y logent.",
		"En enterrant correctement les sculptures et les créatures du plan éthéré inanimées, il est possible de recueillir, quelques jours plus tard, un échantillon d'éther de leur dépouille à la surface de leur sépulture.",
		"En laissant librement circuler l'air à l'intérieur des golems, on fragilise leur structure mais on diminue du même coup leur prise au vent. La plupart des golems jugent l'opération agréable, mais peu d'entre eux sont au courant des risques associés.",
		"Le maoïs à des vertus structurantes irréfutables, mais les créatures du plan éthéré ne peuvent l'ingérer directement. Les prêtres ont donc inventé une mixture à base d'alcool de poires scintillantes pour tromper leur vigilance.",
		"Les Dangrens doivent apprendre à se défendre par eux-mêmes. Pour cela, chacun se rend au Dojo tous les dimanche midi, et s'arrête de prier pendant deux longues et ennuyeuses heures d'entraînement.",
		"Les pilotes d'hydron sont les plus aptes à manier la lance télescopique. Une fois déployée elle peut mesurer jusqu'à 6 mètres ce qui garanti une sacré allonge à son porteur.",
		"C'est un mélange de substances particulièrement indigeste pour les créatures du plan éthéré qui ont l'estomac fragile. Une seule goutte, et l'animal est contraint de rejoindre rapidement l'île la plus proche pour se soulager.",
		"Les griffes des gorgres poussent de plus de 20 centimètres en une nuit. À l'âge adulte, elles sécrètent naturellement du poison. Si on les taille correctement elles peuvent donc s'avérer être des armes redoutables.",
		"La corne d'abondance est un objet mythique des terres d'Arcadie. Elle assure à n'importe quel oracle la victoire, mais les procédures administratives et les délais de livraisons dissuade la plupart d'entre eux d'envoyer un formulaire au conclave.",
		"Les Dangrens méditent et prient si souvent que leur corps, et en particulier leur tête, s'alourdi naturellement de connaissances et de sagesse. En cessant toute activité cérébrale, la plupart arrivent à retrouver un poids convenable, voir négatif.",
		"Les truelles libellules sont des créatures éthérées mineures qui rendent cependant de précieux services dans le domaine de la construction, là où les golems ne sont que d'un piètre secours.",
		"Rien de tel qu'une bonne douche éthérée après la bataille pour se débarrasser des parasites et du sang de ses ennemis.",
		"Les dryades sont de minuscules êtres qui vivent à l'intérieur de la forêt. En passant suffisamment de temps auprès de chaque arbre il est possible de s'attirer leur bienveillance et ainsi jouir de l'énergie sylvaine dont elles sont les gardiennes.",
		"La plupart des puits ont une activité cyclique de basses et hautes pressions éthérées. Exceptionnellement lorsque les prêtres ont effectué des prières régulières et sincères autour d'une source sacrée, une éruption sans précédent peut alors se produire.",
		"Les golems sont naturellement très introvertis et manquent énormément de confiance en eux. Heureusement après un mois de stage au temple, parmi les prêtres stimulateurs d'Akmorpan, ils peuvent laisser exploser leur ego pour devenir de véritables golem-héros",
		"Ces créatures éthérées mineures sont d'une aide précieuse pour les sculpteurs. Leur abdomen génère un laser minuscule permettant de sculpter avec précision les parties les plus fines des automates Dangrens.",
		"Pas aussi efficace qu'une serviette de combat mais tout de même fichtrement déroutant pour les missiles ennemis.",

		// UPDATE SKATCHS 1
		"Les scientifiques Skatchs on découvert en éventrant des Polpides morts des arrêtes extrêmement solides mais, la nature éthérée faisant mal son boulot, pointés vers les organes internes des monstres Dangrens. Comble du délice, ces arêtes sont très jolies ce qui leur a valu leur doux petit nom.",
		// UPDATE DANGREN 2
		"Idée géniale que celle d'utiliser le peau naturellement résistante des stupides Mouchtons comme cuirasse supplémentaire bien chaude et très tendance.",
		// UPDATE SKATCH 3
		"Les corbecs ayant déjà été exterminés il y a fort longtemps, il a bien fallu trouver un nouveau boulot pour les nombreux épouvantails mécaniques Skatchs.",
		// UPDATE DANGREN 4
		"La puissante flamme spirituelle brûle aussi bien les corps que les esprits et décuple les compétences guerrières de tous les Dangrens.",
		// UPDATE SKATCH 5
		"Utilisant les chutes et économisant sur la production les ingénieurs Skatchs arrivent parfois à construire un petit Apicopter en plus du projet principal.",
	];


	static public var ISLANDS = [
		"Ile du Sucre",
		"Ile de la Félicité",
		"Ile Bleue",
		"Ile de Monsegor",
		"Ile du Billot",
		"Ile Oubliée",
		"Ile de Sole",
		"Ile aux Mangues",
		"Ile du Buselier",
		"Ile Sanctive",
		"Ile Alizée",
		"Ile de Grive",
		"Ile de Poque",
		"Ile de Caushmesh",
		"Ile du Comte d'If",
		"Ile Morte",
		"Ile du Muguet",
		"Ile Doctevine",
		"Ile de Forcether",
		"Ile d'Archibald",
		"Îlot des Damnés",
		"Ile Francis",
		"Ile de Crèche",
		"Ile Yogurtine",
	];


	static public var SEND_FLEET = 		"envoyer";
	static public var DROP_FLEET = 		"atterrir";
	static public var COLONIZE_FLEET = 	"coloniser";
	static public var CANCEL_FLEET = 	"retour";

	static public var SHIP_CAPACITY = [
		"Initiative",
		"Assaut",
		"Bombardier",
		"Multi",
		"Colonisation",
		"Furtivité",
		"Sentinelle",
		"Éclaireur",
		"Régénération",
		"Corrosif",
		"Répartition",
		"Meute",
		"Toutes les unités de la flotte gagnent ",
		"Ciblage"
	];

	static public var SHIP_STATUS = [
		"acide",
		"parasite",
	];
	static public var SHIP_STATUS_DESC = [
		"Votre appareil perd un point de structure a chaque tour.",
		"Votre appareil perd 50% de sa vitesse.",
	];

	static public function getShipCapacity(cap : ShipCapacity){
		var str = SHIP_CAPACITY[Type.enumIndex(cap)];
		var num = null;
		var name = null;
		switch(cap){
			case Raid(n):		num = n;
			case Bomb(n):		num = n;
			case Multi(n):		num = n;
			case Aura(cap):		str = str+getShipCapacity(cap);
			case FleetTarget(n):	num = n;
			default:
		}
		if( num!= null ) str +="("+num+")";
		return str;
	}

	static public function getBuildingInfo( k:_Bld ){
		var id = Type.enumIndex(k);
		return {
			name:BUILDING[id],
			info:IGH_BUILDING[id],
			back:FLAVOUR_BUILDING[id]
		};
	}

	static public function getShipInfo( k:_Shp ){
		var id = Type.enumIndex(k);
		return {
			name:SHIP[id],
		};
	}

	static public function getTechInfo( k:_Tec ){
		var id = Type.enumIndex(k);
		return {
			kind:k,
			name:RESEARCH[id],
			info:IGH_RESEARCH[id],
			back:FLAVOUR_RESEARCH[id],
            time:GamePlay.getTechnoSearchTime(k),
			img:"/gfx/technos/"+Std.string(k).toLowerCase()+".jpg"
		};
	}

	static public function getErrorMsg(e:_ErrorKind){

		return switch (e){
			case ALREADY_SETTLED:"Vous avez déjà choisit votre îlot de départ";
			case ISLE_NOT_FOUND:"Ilôt introuvable";
			case ISLE_HAS_OWNER(iid,uid):"Cet îlot est déjà habité";
			case UNIT_NOT_FOUND(id):"Unité introuvable";
			case UNIT_IS_TRAVELING(id):"Unité en déplacement";
			case UNIT_NOT_THERE(uid, iid):"Cette unité n'est plus présente";
			case NO_UNIT_SELECTED:"Aucune flotte sélectionnée";
			case NOT_YOUR_ISLE(id):"Cet îlot ne vous appartient pas";
			case NO_BUILDING_THERE(iid,x,y):"Cette case ne contient pas de bâtiment";
			case SLOT_NOT_EMPTY(iid,x,y):"Cette case est déjà occupée"; // tentative de construction sur une case occupée par un yard ou un building
			case SLOT_NOT_ETHER(iid,x,y):"Cette case n'est pas une source d'éther";
			case TRAVEL_NOT_FOUND:"Flotte en déplacement introuvable";
			case TRAVEL_CANCEL_ERROR_RETURN:"impossible d'annuler le déplacement d'une flotte déjà en phase de retour";
			case TRAVEL_CANCEL_ERROR_ORIGIN:"impossible d'annuler le déplacement d'une flotte si perte de contrôle de l'îlot d'origine";
			case FIGHT_NOT_FOUND:"Bataille introuvable";
			case MAX_STARTED_PROD_LIMIT_REACHED:"Limite de chantier en cours atteinte";
			case RACE_ERROR:"Erreur d'incohérence de race";
			case FLEET_RANGE_TOO_SHORT(a,b):"Votre flotte ne peut atteindre l'île";
			case BAD_SEARCH_ORDER:"Ordre de recherche incohérent";
			case CANNOT_DESTROY_TOWNHALL:"Impossible de supprimer votre bâtiment principal : vous perdriez la partie !";
			case END_OF_SUBSCRIPTION:"Votre abonnement est terminé, rendez-vous dans la SkyBank pour le renouveler et terminer votre partie !";
			case TECHNO_NOT_FOUND:"Technologie non trouvée.";
				// default:				return "Erreur mystérieuse...";
		}
	}

	static public function getTitleDesc( title, desc , align="center", italic=false ){
		if(italic)desc = "<i>"+desc+"</i>";
		//return "<p align='"+align+"'><b>"+title+"</b><br/>"+desc+"</p>";
		return "<p align='"+align+"'><font size='12'><b>"+title+"</b></font><br/><font size='10'>"+desc+"</font></p>";
		//return "<p size='11' align='"+align+"'><b>"+title+"</b></p><p size='10'>"+desc+"</p>";
	}

#if flash
	static public function rep(str,v0:Dynamic,?v1:Dynamic,?v2:Dynamic,?v3:Dynamic,?v4:Dynamic){
		var a = [v0,v1,v2,v3];
		var id = 0;
		for( rep in a ){
			if( rep == null )return str;

			str = Str.searchAndReplace(str,"$"+id,rep);
			id++;
		}
		return str;
	}

	static public function pluriel(str,fl){
		var rep = fl?"s":"";
		return str = Str.searchAndReplace(str,"$s",rep);
	}

	static public function tuc(str){
		str = Str.searchAndReplace(str,"é","e");
		str = Str.searchAndReplace(str,"è","e");
		str = Str.searchAndReplace(str,"ê","e");
		str = Str.searchAndReplace(str,"à","a");
		str = Str.searchAndReplace(str,"ï","i");
		str = Str.searchAndReplace(str,"î","i");
		return str.toUpperCase();
	}

	static public function getShipDesc(type : _Shp,owner,status,fa:List<_FleetAttribute>,pa:List<_PlanetAttribute>){
		var sid = Type.enumIndex(type);
		var str = Cs.getTitleTxt( Lang.SHIP[sid] )+"<br>";
		var player = Game.me.getPlayer(owner);
		var car = Tools.getShipCaracs(type,player._tec,fa,pa) ;
		var a = [car.life,car.power,car.armor,car.speed,car.range];

		// CARACS
		var id = 0;
		for( n in a ){
			var val = n;
			if( id==3 && (status & Std.int(Math.pow(2, 1))) > 0 ) val = Std.int(val*0.5);
			str += Lang.SHIP_CAR[id]+" : <b>"+val+"</b><br>";
			id++;
		}

		// CAPACITE + STATUS
		var flFirst = true;
		for( c in car.capacities ){
			if( !flFirst )	str+=", ";
			else 		flFirst = false;
			str += Cs.getCapacityTxt(c);
		}
		var as = [];
		for( i in 0...6 )if(  (status & Std.int(Math.pow(2, i))) > 0 )as.push(i);
		str+="<font color='#FF0000'>";
		for( n in as ){
			if( !flFirst )	str+=", ";
			else 		flFirst = false;
			str += SHIP_STATUS[n];
		}
		str+="</font>";


		return str;
	}
#end

//{
}



// Wiseman 	--> 2
// Shanti 	--> 1
// whizer +2 ?	deja a 2.
// micmac59 +1  --> 4
// cromzog	--> 1
// skyion +1	--> 1











