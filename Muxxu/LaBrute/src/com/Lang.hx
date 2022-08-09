import Data;

class Lang{//}

	public static var CARACS : Array<String>;
	public static var SUPERS : Array<String>;
	public static var PERMANENTS : Array<String>;
	public static var WEAPONS : Array<String>;
	public static var FOLLOWERS : Array<String>;
	public static var TALENTS : Array<String>;
	public static var MISC : Array<String>;
	public static var DESCRIPTIONS : Array<String>;
	public static var DESCADVANCED : Array<String>;
	public static var PCOUNT = Type.getEnumConstructs(_Permanent).length;
	public static var SCOUNT = Type.getEnumConstructs(_Super).length;

	public static function setLang( lang ){
		var l = Reflect.field(Lang, lang);
		if( l == null )
			throw "no lang #" + lang;
		for( n in [__unprotect__("CARACS"), __unprotect__("SUPERS"), __unprotect__("PERMANENTS"), __unprotect__("WEAPONS"), __unprotect__("TALENTS"), __unprotect__("FOLLOWERS"), __unprotect__("MISC"), __unprotect__("DESCRIPTIONS"), #if neko __unprotect__("DESCADVANCED") #end] ) {
			var v = Reflect.field(l, n);
			if( v == null )
				throw "missing " + lang + "." + n;
			Reflect.setField(Lang, n, v);
		}
	}

	static function __init__(){
		Reflect.setField(Lang,"fr",{
			CARACS: ["Force","Agilité","Rapidité","Endurance"],
			SUPERS: ["Voleur","Brute féroce","Potion tragique","Filet","Bombe","Marteau-pilon","Cri-qui-poutre","Hypnose","Déluge","Trappeur"],
			PERMANENTS: [
				"Force herculéenne","Agilité du félin","Frappe éclair","Vitalité","Immortel","Maître d'armes","Arts martiaux","6ème sens","Pugnace",
				"Tornade de coups","Bouclier","Armure","Peau renforcée","Intouchable","Vandalisme","Choc","Gros-bras","Implacable","Survie",
				"Squelette plomb","Ballerines","Persévérant","Sang-chaud","Increvable","Méditation","Contre","Tête-de-fer"
			],
			WEAPONS: [
				"mains","couteau","glaive","lance","bâton","trident","hache","cimeterre","marteau","épée","éventail","shuriken","crocs","massue","étoile du matin",
				"os de mammouth","fléau","fouet","sai","poireau","mug","poêle","piou piou","hallebarde","trombone","clavier","bol de noodle","raquette",
			],
			FOLLOWERS: ["chien A","chien B","chien C","panthère","ours",],
			TALENTS:["Régénération","Cuisinier","Espion","Saboteur","Renforts"],
			MISC: [
				"TAPE ICI","Changer l'apparence","Changer les couleurs","Une erreur est survenue, veuillez réessayer.","Choisi un nom pour\ngénérer une Brute","Vie","Supers","Spécialités",
				" gagne le match !","Copie ici les 4 caractères\naffichés en dessous","Les caractères sont incorrects. Essaye à nouveau !","Veuillez patienter..."
			],
			DESCRIPTIONS: [
				"Avec ta force, tu es capable de déplacer des montagnes ! Mais pour l'instant, t'as un adversaire à cogner.",
				"Tu n'as pas de pelote de laine pour t'amuser, mais tu peux toujours embêter la brute en face.",
				"Tu distribues des coups plus vite que ton ombre et plus vite que les dents de ton adversaire.",
				"Ton espérance de vie a augmenté ! Désormais tu tiendras debout plus longtemps dans l'arène.",
				"Ta santé a atteint un niveau inimaginable ! Il est devenu très difficle de te terrasser lors d'un combat.",
				"Grâce à ta maîtrise, tu causes plus de dégâts à ton adversaire avec les armes tranchantes.",
				"Les cours de Chuck Norris ont porté leurs fruits ! Maintenant tu mets les pieds où tu veux... et c'est souvent dans la tronche.",
				"Ta vigilance aiguisée te permet d'anticiper les fourberies de ton adversaire et de frapper avant lui !",
				"Dans l'arène tu n'es vraiment pas ingrat... Quand on te donne un coup, tu le rends aussitôt, et gratuitement !",
				"... et tu tapes tapes tapes, c'est ta façon d'aimer, ce rythme qui t'entraîne jusqu'au bout de la nuit, éveille en toi le tourbillon d'un vent de foliiiiiie !",
				"Un bouclier. Pour parer les coups... des fois.",
				"Ca, c'est une armure. Un truc qu'on met par dessus son t-shirt pour pas le salir. En même temps, ça permet de mieux résister aux attaques.",
				"A force de se faire taper, on finit par évoluer. Ta brute possède maintenant une peau plus résistante.",
				"Tu évites les coups plus facilement. C'est très énervant, surtout pour ton adversaire.",
				"Certaines brutes font du vandalisme dans la rue, mais toi tu préfères vandaliser ton adversaire. Chaque coup te permet de détruire une de ses armes.",
				"Tes coups sont tellement surprenants que ton adversaire en laisse tomber son arme... Profites-en pour lui en montrer d'autres !",
				"Grâce à tes gros bras, tu manipules les armes lourdes aussi facilement qu'un micro. Tu es le Philippe Risoli de la massue.",
				"Lorsque tu colles des baffes, elles arrivent toujours à destination. Personne ne peut les arrêter. En tout cas pas ton adversaire.",
				"Les années de lutte t'ont rendu increvable. Les coups mortels te laissent 1 point de vie au lieu de t'abattre.",
				"Pas toujours pratique pour se déplacer, le plombage intégral de la cage thoracique permet néanmoins de réduire considerablement les dégâts des armes contondantes.",
				"La danse des cygnes n'a aucun secret pour toi, impossible que ton adversaire t'atteigne, enfin, tant qu'il pige pas le truc.",
				"Rien ne te décourage, chaque échec te rend plus fort. Lorsqu'un coup ne porte pas, tu en lances un autre.",
				"Tes adversaires entrent dans l'arène, mais toi tu préferes rentrer dans tes adversaires, tu es toujours le premier à frapper.",
				"Pour te mettre au tapis, il faut s'y prendre à plusieurs fois... C'est cinq beignes minimum, sinon rien.",
				"Pour analyser les failles de ton adversaire, tu es prêt à prendre ton temps, mais lorsque tu démarres rien ne t'arrete.",
				"La meilleur attaque ? C'est la défense bien entendu ! Pour chaque coup paré, tu ripostes automatiquement.",
				"Lorsque tu prends un coup, c'est ton adversaire qui doit résister à l'impact !",

				"Cette compétence te permet d'emprunter discrétement l'arme de ton adversaire et de l'essayer sur lui.",
				"Maintenant, t'es une vraie brute. Encore plus qu'avant. Tu peux effectuer une charge puissante pendant un combat.",
				"Boooooire un p'tit coup c'est agréaaableuuu ! Oui, mais pas pour tout le monde.... Ce jus de pêche restaure une partie de ton énergie au cours du combat.",
				"Un filet classique. Pas aussi cool que la toile de Spiderman, mais faudra faire avec... Ton adversaire sera immobilisé jusqu'à ce que tu lui portes un coup.",
				"Un peu comme une bombe à eau, mais en plus méchant.",
				"Une technique de catch qui consiste à sauter avec l'adversaire, et retomber dessus.",
				"Des bêtes féroces, ça ? Pfffff... Il suffit de crier un peu pour les faire fuir...",
				"Lorsqu'il s'agit de faire du charme aux animaux domestiques, personne ne t'égale. Ils te suivent au doigt et à l'oeil.",
				"Puisque se ballader avec 100 kilos d'armes t'es devenu insupportable, tu as trouvé un astucieux stratagème pour voyager léger. ",
				"Rien ne se perd, tout se transforme. Tu consommes toutes les viandes mortes de l'arène.",

				"Grâce à ta capacité de cicatrisation hors-normes, tu ne rates jamais un combat !",
				"Toutes les brutes le savent, le gros du combat se joue avant l'arène. Le plus souvent, du coté de la cantine...",
				"Un coup d'oeil et quelques renseignements permettent souvent d'éviter les longs séjours à l'hopital.", // :-/
				"Du marteau en mousse à l'épee en plastique, tu es le roi de l'imitation, tes adversaires n'y voient que du feu.",
				"Parceque l'amitié c'est le partage, tu as appris à partager tes baffes pour que les adversaires de tes collègues profitent aussi un peu.",

			],
			#if neko
			DESCADVANCED: [
				"Force +3 Force +50%",
				"Agilité +3 Agilité +50%",
				"Rapidité +3 Rapidité +50%",
				"Endurance +3 Endurance +50%",
				"Endurandce +250% Force -25% Agilite -25% Rapidite -25%",
				"Dégâts des armes tranchantes : +50%",
				"Dégâts à mains nues : +100%",
				"Chances de contre : +10%",
				"Chances de riposte : +30%",
				"Chances de combo : +20%",
				"Chances de parade : +45%",
				"Armure +5 Rapidité -10%",
				"Armure +2",
				"Chances d'esquive +30%",
				"Détruit une arme à chaque coup qui blesse",
				"Chance de désarmer +50%",
				"Interval -25% entre les coups d'armes lourdes",
				"Chance de toucher +30%",
				"Le premier coup t'amenant à 0 pv ou moins te laisse à 1 pv.",
				"Les armes lourdes t'infligent 30% de dégâts en moins.",
				"Le premier coup de chaque combat est automatiquement esquivé.",
				"Tant que le coup ne blesse pas, 70% de chance d'attaquer à nouveau.",
				"Initiative +200.",
				"Chaque coup reçu ne peut pas te faire perdre plus de 20% de ta barre.",
				"Initiative -200 Rapidité +5 Rapidité +150%.",
				"Chances de parade +10%. Chaque coups paré entraine une riposte automatique.",
				"Pour chaque coup te ciblant, ton adversaire a 30% de chance de perdre son arme.",

				"Action (x2) Ta brute prend l'arme de son adversaire.",
				"Action (x1) Ta brute double les dégats du prochain assaut.",
				"Action (x1) Ta brute récupère entre 25% et 50% des pv perdus.",
				"Action (x1) Le filet empêche la cible de bouger/esquiver/parer jusqu'au prochain coup reçu.",
				"Action (x2) Entre 15 et 25 dégats sur tous les adversaires.",
				"Action (x1) Ta brute inflige de lourds dégats dépendant de sa force à son adversaire.",
				"Action (x2) Cri repoussant les animaux ( 50% de réussite ).",
				"Action (x1) Ta brute contrôle les animaux de son adversaire.",
				"Action (x1) Ta brute lance instantanément la moitié de ses armes sur son adversaire.",
				"Action (x4) Ta brute récupère entre 20 et 50% de son energie selon la qualité de la viande.",

				"Tu peux subir une blessure de plus par jour.",
				"(24h) Tes futurs adversaires subissent 2% de dégats à la fin de chacune de leurs actions.",
				"(24h) Tu peux accéder aux détails des fiches de tes adversaires.",
				"(24h) Sabote une arme pour chacun de tes futurs adversaire ( init -100 lorsqu'elle est utilisée ).",
				"(24h) Ta brute peut intervenir dans les combats de ses collègues de niveau superieur.",
			]
			#end
		});
		
		Reflect.setField(Lang,"es",{
			CARACS: ["Fuerza","Agilidad","Velocidad","Resistencia"],
			SUPERS: ["Ladrón","Bruto Feroz","Poción trágica","Red","Bomba","Martillo","Grito maldito","Hipnosis","Diluvio","Cazador",],
			PERMANENTS: [
				"Fuerza de Hércules","Agilidad felina","Golpe del rayo","Vitalidad","Inmortal","Maestro de Armas","Artes Marciales","6º sentido","Belicoso",
				"Tornado de golpes", "Escudo", "Armadura", "Piel reforzada", "Intocable", "Vandalismo", "Choque", "Brazo fuerte", "Implacable", "Supervivencia",
				"Esqueleto de plomo","Bailarín","Perseverante","Sangre caliente","Inagotable","Meditación","Contra","Cabeza de acero"
			],
			WEAPONS: [
				"manos","cuchillo","espadón","lanza","bastón","tridente","hacha","cimitarra","martillo","espada","abanico","shuriken","colmillos","maza","mamporro",
				"hueso de mamut","mangual","látigo","sai","puerro","taza","sartén","piopio","alabarda","trombón","teclado","bol de ramen","raqueta",
			],
			FOLLOWERS: ["perro A","perro B","perro C","pantera","oso",],
			MISC: [
				"Teclea aqui","Cambiar la apariencia","Cambiar los colores","Ha ocurrido un error. Vuelve a intentarlo, por favor.","Elige un nombre\npara generar un Bruto","Vida","Super",
				"Especialidades"," gana el combate","Escribe aqui los caracteres\nque ves aqui.","Los caracteres que has escrito no coinciden. Vuelve a intentarlo.","Espera por favor..."
			],
			DESCRIPTIONS: [
				"¡Lo sabemos, eres capaz de levantar un tanque de guerra! Pero de momento nada de eso... ¡tienes un adversario que destrozar!",
				"Si estás aburrido, siempre puedes ir a masacrar al Bruto de enfrente.",
				"Eres más rápido que tu propia sombra. ¡Si yo fuera tu adversario, empezaría a rezar!",
				"¡Tu esperanza de vida ha aumentado! Ahora podrás resistir más tiempo en pie frente a tu adversario.",
				"Tu salud ha alcanzado un nivel inimaginable. Te has convertido en la peor pesadilla para tus enemigos.",
				"Tu dominio de las armas blancas ha hecho de ti un tipo muy, pero muy peligroso.",
				"¡Las clases de Chuck Norris han dado sus frutos! Puedes ser feo y tonto... pero nadie se reirá de ti.",
				"¡Tu vista de águila te permite anticipar las intenciones de tu adversario y golpeas antes que él!",
				"Después de todo eres un tipo generoso... ¡Cuando te tocan devuelves el golpe enseguida y hasta sin razón!",
				"... la cucaracha, la cucaracha, ya no puede caminar, porque tu Bruto, porque tu Bruto, tararararará.",
				"Un escudo te protegerá de los golpes... bueno, a veces.",
				"Una armadura: mucho mejor que una camiseta limpia. También sirve para frenar los golpes.",
				"La evolución se hace a base de golpes. Tu Bruto posee ahora una piel más resistente.",
				"Evitas los golpes fácilmente. Eso puede enojar mucho a tu enemigo.",
				"Algunos Brutos hacen vandalismo en la calle, pero tú  lo haces sobre tu adversario. Cada golpe te permite destruir una de sus armas.",
				"Tus golpes son tan espectaculares que tu adversario deja caer su propia arma... ¡Es muy útil para ganar nuevos fans!",
				"Manipulas las armas pesadas como si nada gracias a tus músculos de acero. Eres el Schwarzenegger de la maza.",
				"Cuando repartes tortas, siempre llegan a su destino y nadie puede pararlas. ¡Tu enemigo puede empezar a sobarse!",
				"Los años de lucha te han vuelto casi invencible. Los golpes mortales te dejan con 1 punto de vida en lugar de dejarte fuera de combate.",
				"No es muy fácil de llevar, pero un refuerzo metálico de tu caja toráxica reducirá el impacto de los golpes.",
				"Joaquín Cortés es un calcetín viejo al lado tuyo, te mueves tan bien que tus adversarios no logran ni tocarte.",
				"Nada te desanima, cada derrota te hace más fuerte. Incluso cuando golpeas al aire, le sigues golpeando.",
				"Eres el más rápido del oeste: Ni bien tus adversarios han entrado en la arena y tu ya les diste un golpe.",
				"Dejarte en la lona, no es nada fácil... Se requiere por lo menos cinco buenas bofetadas.",
				"Te tomas tu tiempo para analizar los puntos débiles de tu adversario, ¡pobre de él si se cruza en tu camino!",
				"¿Intentaron golpearte? ¡Eso no se puede quedar así! Por cada golpe evitado, respondes al instante.",
				"Cuando tu adversario piensa en lanzar un golpe, debe prepararse a recibir uno.",
				
				"Esta competencia te permite tomar discretamente el arma de tu adversario y usarla sobre él.",
				"¡Ahora eres más bruto que antes! Tus descargas son aún más violentas durante el combate.",
				"Beeber un poooquito no haaace daaaño, ¡hip!  Este traguito restaura una parte de tu energía durante el combate.",
				"Una red clásica. No es tan chula como la de Spiderman, pero al menos podrás inmovilizar a tu adversario hasta que le des un golpe.",
				"Es como lanzar un globito de agua, pero mucho más divertido.",
				"Una técnica de catch que consiste en saltar con el adversario y caer encima de él. Puede provocar heridas graves.",
				"¿Bestias feroces? ¡Ja!... Pégales un grito y verás como saldrán corriendo.",
				"Hueles como un animal, por eso los dominas como si fueran dóciles caniches.",
				"Pasearse por la calle con 100 kilos de armas es pesado. Pero has encontrado un modo eficaz de aligerar tu carga. ",

				"Nada se desperdicia. Te comes todo lo que cae en la arena.",

				"Gracias a tu extraordinaria capacidad de cicatrización no te pierdes ningún combate",
				"Todos los Brutos lo saben, el combate empieza antes de entrar a la arena. Y terminan... en la cantina.",
				"Unos guiños de ojo y una buena fuente de información pueden evitarte una larga estadía en el hospital.", // :-/
				"Desde pequeño ya les sacabas la lengua a tus amigos, hoy eres un verdadero carnicero.",
				"Porque los amigos de tus amigos también son tus amigos, repartes bofetadas en los combates de tus compañeros.",
				
			],
			TALENTS:["Regeneración", "Jefe", "Espía", "Saboteador", "Refuerzos"],
			#if neko
			DESCADVANCED: [
				"Fuerza +3 Fuerza +50%",
				"Agilidad +3 Agilidad +50%",
				"Velocidad +3 Velocidad +50%",
				"Resistencia +3 Resistencia +50%",
				"Resistencia +250% Fuerza -25% Agilidad -25% Velocidad -25%",
				"Daños con arma blanca: +50%",
				"Daños con puño limpio: +100%",
				"+10% posibilidad de bloqueo",
				"+30% posibilidad de contraataque",
				"+20% posibilidad de combo",
				"+45% posibilidad de rechazo",
				"Blindaje +5 Velocidad -10%",
				"Blindaje +2",
				"+30% posibilidad de evasión",
				"Destruye un arma cada vez que lanzas un golpe certero",
				"+50% posibilidades de desarme",
				"Intervalo de -25% entre ataques pesados",
				"+30% de posibilidades de herir a tu oponente",
				"El primer golpe que recibes en una pelea te dejará con 0 o 1 PV.",
				"Las armas pesadas causan al menos 30% de daños.",
				"El primer golpe de cada pelea sera automáticamente esquivado.",
				"Si tu golpe no hiere a tu oponente, hay un 70% de posibilidades que tu Bruto lance otro ataque.",
				"+200 de iniciativa.",
				"Los golpes de tu oponente sólo pueden reducir tu vida en 20%.",
				"Iniciativa -200 Velocidad +5 Velocidad +150%.",
				"+10% de posibilidades de evasión. Tu Bruto contraatacará después de cada golpe bloqueado exitosamente.",
				"Por cada ataque dirigido a ti, tu oponente tendrá 30% de posibilidades de perder su arma.",

				"Acción (x2) Tu Bruto coge el arma de su oponente.",
				"Acción (x1) Los golpes de tu Bruto causan doble daño durante el próximo ataque.",
				"Acción (x1) Tu Bruto recupera entre 25% y 50% PV.",
				"Acción (x1) La red impide que tu víctima se mueva hasta el próximo golpe.",
				"Acción (x2) Entre 15 y 25 daños a todos tus oponentes.",
				"Acción (x1) Tu Bruto causa daños graves según la fuerza de su adversario.",
				"Acción (x2) Grito auyentador de animales (50% de posibilidades de éxito).",
				"Acción (x1) Tu Bruto controla los animales de su adversario.",
				"Acción (x1) Tu Bruto ataca con la mitad de todas sus armas.",
				"Acción (x4) Tu Bruto recupera entre 20 y 50% de su energía según la calidad de la carne.",

				"Puedes soportar una herida más por día.",
				"(24h) Tus futuros oponentes sufren 2% de daños al final de cada una de sus acciones.",
				"(24h) Puedes acceder a los perfiles de tus oponentes.",
				"(24h) Destruye el arma de cada uno de tus futuros oponentes (iniciativa -100 cuando es utilizado).",
				"(24h) Tu Bruto puede intervenir en los combates de sus colegas de nivel superior.",
			]
			#end
		});
		
		Reflect.setField(Lang,"en",{
			CARACS: ["Strength","Agility","Speed","Endurance"],
			SUPERS: ["Thief","Fierce Brute","Tragic Potion","Net","Bomb","Hammer","Cry of the Damned","Hypnosis","Flash Flood","Tamer"],
			PERMANENTS: [
				"Herculean Strength","Feline Agility","Lightning Bolt","Vitality","Immortality","Weapons Master","Martial Arts","6th Sense",
				"Hostility","Fists of Fury","Shield","Armor","Toughened Skin","Untouchable","Sabotage","Shock","Bodybuilder","Relentless","Survival",
				"Lead Skeleton","Ballet Shoes","Determination","First Strike","Resistant","Reconnaissance","Counter-Attack","Iron Head"
			],
			WEAPONS: [
				"hands","knife","broadsword","lance","baton","trident","hatchet","scimitar","axe","sword","fan","shuriken","fangs","bumps","morning star",
				"mammoth bone","flail","whip","sai","leek","mug","frying pan","piopio","halbard","trombone","keyboard","noodle bowl","racquet",
			],
			FOLLOWERS: ["dog A", "dog B", "dog C", "panther", "bear", ],
			TALENTS:["Regeneration", "Chef", "Spy", "Saboteur", "Backup"],
			MISC: [
				"TYPE HERE","Change appearance","Change colours","An error has occured, please try again.","Choose a name to\ngenerate a Brute","Life","Super","Specialities",
				" wins the fight!","Type in the characters\nyou see below here","The characters don't match. Please try again.","Please wait..."
			],
			DESCRIPTIONS: [
				"You're strong enough to move mountains, but first you must defeat your opponent.",
				"You don't even have a ball of string to play with, but you can always thump an opponent.",
				"You strike faster than your shadow and bite harder than your opponents.",
				"Your life expectancy has increased! You'll now be able to fight for longer in the arena.",
				"Your health has increased dramatically! Now it'll be much harder for your opponents to knock you out.",
				"After having mastered all edged weapons, you're a much bigger threat to your opponents.",
				"The Chuck Norris course you took has really paid off! Now you can walk wherever you want... and more often than not it'll be all over your opponent's ugly face!",
				"Your eagle-eyed vigilance allows you to anticipate when your opponents are sneaking up on you. Now when you attack they won't know what hit them!",
				"You're very polite when you're fighting in the arena. Whenever one of your opponents attacks you, you return the favour......for free!",
				"... and you scratch, claw, bite, that's just your little way of showing love! You're a mad torrent of misdirected love!",
				"A shield. To stop the blows...well, some of them at least.",
				"What's this? It's a coat of armour. The idea is that you put it on over your t-shirt so that it doesn't get dirty. It also helps to protect you from your opponent's blows.",
				"All the knocks you've taken up until now have actually helped you to develop. Your Brute is now much tougher and has a much thicker skin.",
				"You can now avoid attacks much more easily. This is really annoying............but only for your opponents!",
				"Some Brutes choose to vandalise the streets, but you prefer to vandalise your opponents! Each blow will destroy one of your opponent's weapons.",
				"Your attack takes your opponent by surprise and he drops his weapon. Now you can show it off to your friends!",
				"Thanks to your huge biceps you can now use heavy weapons. Bravo Mr Muscle!",
				"When you attack, you're always on target. Nobody can stop you. Most certainly not your opponent!",
				"Years of fighting have made you invincible. Mortal blows have gained you 1 life point instead of knocking you out.",
				"Although it's extremely heavy, a lead skeleton is essential as it considerably reduces blunt weapon damage.",
				"You've mastered the swan dance, making it impossible for your opponent to reach you, as long as he hasn't mastered it too!",
				"Nothing can stop you! Each defeat makes you stronger, if one of your blows fails to land, you immediately strike again!",
				"Your opponents enter the arena slowly, but you prefer to get stuck in straight away! You're always the first to attack!",
				"It takes your opponents endless blows to knock you out. It takes at least 5 blows before you feel anything.",
				"You're prepared to take your time in order to analyse your opponent's weaknesses, but once you start fighting, nothing will stop you.",
				"What's the best form of attack? Defense of course! You'll immediately strike back after blocking your opponent's blow.",
				"Your opponent will be damaged by his own blows!",

				"This skill allows you to discreetly steal your opponent's weapon and then use it against him.",
				"Now you're a real Brute. You're more powerful and violent than ever during fights.",
				"Have a little sip of this. It could make you a bit drunk. Hic... hic... This peach juice restores some of your energy lost during the fight",
				"A classic net. Not as cool as Spiderman's, but it's good enough for your opponent... Your enemy will be immobilised until you hit him again.",
				"A bit like a water bomb, but far more deadly!",
				"A catching technique which consists of jumping into the air with your opponent, and then falling on top of him.",
				"Fierce beasts? Pfffff... You only need to scream and they'll run for their lives!",
				"When it comes to training domestic animals, no one comes close to you. They follow your every beck and call.",
				"Walking around carrying 100 kilos of weapons is very tiring but you have found a clever way of travelling light.",
				"Recycle! Make it part of your everyday cycle! You gobble up all the dead bodies in the arena.",

				"Due to your extraordinary ability to heal yourself, you never lose a fight!",
				"All brutes know that the biggest fight is in the canteen, not the arena!",
				"By carrying our some reconnaissance missions before your fight, you’ll avoid long hospital visits.",
				"From foam hammers to plastic swords, you’re fake weapon king! Your opponents won’t notice until it’s too late.",
				"Friendship is all about sharing. Luckily for you, you’ve learnt to share your blows with your opponents so that they can have some too!",

			],
			#if neko
			DESCADVANCED: [
				"Strength +3 Strength +50%",
				"Agility +3 Agility +50%",
				"Speed +3 Speed +50%",
				"Endurance +3 Endurance +50%",
				"Endurance +250% Strength -25% Agility -25% Speed -25%",
				"Sharp weapon damage: +50%",
				"Bare-handed damage: +100%",
				"+10% chance of block",
				"+30% chance of counter-attack",
				"+20% chance of combo",
				"+45% chance of parry",
				"Armor +5 Speed -10%",
				"Armor +2",
				"+30% chance of evasion",
				"Destroy a weapon each time you land a blow",
				"+50% chance of disarmament",
				"-25% interval between heavy weapon attacks",
				"+30% chance of injuring your opponent",
				"The first blow you receive during a fight will lose you 0 or possibly 1 HP.",
				"Heavy weapons inflict at least 30% damage.",
				"The first blow of each fight will be automatically avoided.",
				"If your blow does not hurt your opponent, there is a 70% chance of your Brute launching another attack.",
				"Initiative +200.",
				"Opponent's blows can only decrease your health bar by 20%.",
				"Initiative -200 Speed +5 Speed +150%.",
				"+10% chance of evasion. Your Brute will counter-attack after each blow successfully blocked.",
				"For each attack targeted at you, your opponent will have a 30% chance of losing their weapon.",

				"Action (x2) Your Brute picks up his opponent's weapon.",
				"Action (x1) Your Brute's blows will cause double damage during the next attack.",
				"Action (x1) Your Brute regains between 25% and 50% HP.",
				"Action (x1) The net stops the target from evading your next attack.",
				"Action (x2) Between 15 and 25 damage inflicted on all your opponents.",
				"Action (x1) Your Brute inflicts heavy damage depending on the strength of your opponent.",
				"Action (x2) Animal repelling scream ( 50% chance of success).",
				"Action (x1) Your Brute takes control of your opponent's animals.",
				"Action (x1) Your Brute instantly attacks his opponent with half their weaponry.",
				"Action (x4) Your brute regains between 20 and 50% of his health depending on the quality of the meat.",

				"You can withstand one extra death each day.",
				"(24h) Your future opponents will suffer 2% damage at the end of each of their actions.",
				"(24h) Access your opponents profiles.",
				"(24h) Destroy one of your future opponents( initiative -100 until it’s used).",
				"(24h) Your Brute can help superior team-members during fights.",
			]
			#end
		});
		
		Reflect.setField(Lang,"de",{
			CARACS: ["Kraft","Flinkheit","Geschwindigkeit","Ausdauer"],
			SUPERS: ["Dieb","Wilde Bestie","Tragischer Trank","Netz","Bombe","Dampfhammer","Höllenschrei","Hypnose","Sintflut","Dompteur"],
			PERMANENTS: [
				"Herkulische Kräfte","Katzenflinkheit","Blitzschlag","Vitalität","Unsterblichkeit","Waffenmeister","Kampfkunst","Sechster Sinn",
				"Kämpfernatur","Schlaggewitter","Schild","Rüstung","Elefantenhaut","Unberührbarkeit","Sabotage","Schock", "Mächtiger Arm","Gnadenlos","Überleben",
				"Bleiskelett","Ballettschuhe","Entschlossenheit","Erstschlag","Resistenz","Kampfsinn","Konterangriff","Eisenschädel"
			],
			WEAPONS: [
				"Hände","Messer","Breitschwert","Lanze","Stock","Dreizack","Beil","Krummsäbel","Hammer","Schwert","Fächer","Shuriken","Stoßzahn","Keule","Morgenstern",
				"Mammutknochen","Dreschflegel","Peitsche","Sai","Porree","Tasse","Pfanne","Piou Piou","Hallebarde","Posaune","Klavier","Nudelschale","Schläger",
			],
			FOLLOWERS: ["Hund A", "Hund B", "Hund C", "Panther", "Bär", ],
			TALENTS:["Regeneration", "Chef", "Spion", "Saboteur", "Backup"],
			MISC: [
				"HIER EINGEBEN","Aussehen ändern","Farben ändern","Es ist ein Fehler aufgetreten, versuche es bitte noch einmal.","Wähle bitte einen Namen\n für deinen Brutalo.","Leben","Super","Spezialfähigkeiten",
				" hat gewonnen!","Trage hier die unten\nangezeigten Zeichen ein.","Deine Eingabe war nicht korrekt. Versuche es bitte noch einmal!","Habe bitte etwas Geduld..."
			],
			DESCRIPTIONS: [
				"Du bist so stark, du kannst sogar Berge verschieben! Im Moment hast du aber noch einen Gegner vor dir.",
				"Du hast gerade keinen Wollknäuel zum Spielen, aber vielleicht willst du ja den Brutalo vor dir ärgern.",
				"Deine Schläge landen schneller bei deinem Gegner als dieser überhaupt blinzeln kann.",
				"Deine Lebenserwartung ist soeben gestiegen! Du wirst ab sofort länger in der Arena durchhalten.",
				"Du bist so gesund wie noch nie zuvor! Wer soll DICH jetzt im Kampf noch schlagen?!",
				"Du hast deine Waffenkunst perfektioniert. Ab sofort fügst du deinem Gegner mit deinen Hieb- und Stichwaffen noch mehr Schaden zu.",
				"Chuck Norris' Nachhilfestunden zahlen sich so langsam aus! Deine Schläge landen dort, wo du sie haben willst - im Gesicht deines Gegners!",
				"Dank deines geschärften Kampfsinns bist du in der Lage, die miesen Tricks deines Gegners zu erahnen und ihm zuvorzukommen.",
				"Du bist in der Arena nicht gerade zimperlich... Sobald du einsteckst, teilst du sofort wieder aus - und das nicht zu knapp!",
				"... du drischst, drischst, drischst und drischst auf deinen Gegner ein und vergisst alles um dich herum. Hurrikan Katrina ist ein Witz gegen dich!",
				"Mit einem Schild kannst du Schläge abwehren. Na, wer's braucht...",
				"Das ist eine Rüstung, Kleiner. So'n Ding ziehst du dir übers T-Shirt, damit es nicht schmutzig wird. Außerdem hilft es dir, Angriffe abzuwehren.",
				"Durch das ganze Prügeln wirst du zwangsläufig irgendwann mal stärker. Dein Brutalo hat sich eine lederne dicke Haut angekämpft!",
				"Es fällt dir immer einfacher, den Schlägen deines Gegners auszuweichen. Das geht dem mächtig auf den Senkel.",
				"Manche Brutalos lieben es, Straßenzüge zu verwüsten, doch du verwüstet lieber die Waffen deines Gegners. He he!",
				"Deine Schläge kommen derart überraschend, dass dein Gegner vor lauter Schreck seine Waffe fallen lässt... Nutze diese Gelegenheit!",
				"Deine kräftigen Oberarme schwingen deine Waffen so kinderleicht wie ein Mikro. Du bist der Thomas Gottschalk der Keulenschwinger!",
				"Keine Ahnung wie du das machst, aber deine Ohrfeigen finden immer ihr Ziel. Niemand kann sich ihnen entziehen. Dein Gegner schon mal gar nicht.",
				"Zahlreiche Jahre harter Kämpfe haben dich fast unverwundbar gemacht. Selbst nach normalerweise tödlichen Schlägen bleibt dir noch ein Lebenspunkt übrig.",
				"Auch wenn es extrem viel wiegt, ein Bleiskelett ist nötig, es schwächt Schaden durch stumpfe Waffen erheblich ab.",
				"Du hast den Tanz des Schwans erlernt. Solange dein Gegner ihn nicht ebenfalls beherrscht, kann er nicht nahe an dich rankommen.",
				"Nichts kann dich aufhalten! Jede Niederlage macht dich nur stärker. Geht einer deiner Schläge mal daneben, haust du sofort erneut zu.",
				"Deine Gegner betreten gemächlich die Arena. Aber du kommst lieber direkt zur Sache! Der erste Angriff gehört immer dir!",
				"Dein Gegner muss endlos auf dich einschlagen, um dich k.o. zu hauen. Du musst mindestens 5 Schläge einstecken, ehe du überhaupt etwas spürst.",
				"Du nimmst dir von nun an die Zeit, die Schwachstellen deines Gegners herauszufinden. Wenn du dann loslegst, wird dich nichts aufhalten können.",
				"Die beste Art anzugreifen? Durch Verteidigung natürlich! Du schlägst sofort zurück, sobald du einen Schlag deines Gegners abgeblockt hast.",
				"Dein Gegner wird durch seine eigenen Schläge verletzt!",

				"Mit dieser Fähigkeit kannst du dir die Waffe deines Gegners ausleihen und sie an ihm ausprobieren.",
				"Du bist jetzt ein richtiger Brutalo! Noch viel brutaler und grausamer als vorher. In deinen Kämpfen lässt du richtig dicke Schlagladungen von dir.",
				"Komm her, ich schenk dir ein! Austeilen macht dir so richtig Spaß! Jupp, das weckt Lebenskräfte.",
				"Ein Kampfnetz - ist zwar nicht ganz so cool wie das von Spiderman, aber es hilft: Dein Gegner verheddert sich und kann dann von dir vermöbelt werden.",
				"Das Ding hier ist 'ne Art Wasserbombe - nur noch fieser.",
				"Der Dampfhammer! Wer kennt ihn nicht? Eine klassische Catchtechnik. Spring mit deinem Gegner in die Luft und fall mit ihm danach auf den Boden!",
				"Wilde Bestien?! Das da? Pffff... Du musst nur ein wenig schreien, dann ergreifen sie schon die Flucht! Dass ich nicht lache!",
				"Im Haustiere zähmen macht dir keiner so schnell was vor. Die Viecher gehorchen dir aufs Wort.",
				"100 Kilo Waffen mit sich herumzuschleppen ist auf die Dauer etwa mühsam... aber du hast dir etwas Geniales einfallen lassen.",
				"Recycling! Mach es zum Teil deines Lebens! Du sammelst alle Leichen in der Arena ein.",

				"Dank deiner außergewöhnlichen Selbstheilungskräfte verlierst du nie einen Kampf!",
				"Jeder Brutalo weiß - die größten Kämpfe werden nicht in der Arena ausgetragen, sondern in der Kantine.",
				"Durch Schärfen deiner Sinne vor dem Kampf vermeidest du lange Krankenhausaufenthalte.",
				"Von Schwamm-Hämmern bis zu Plastik-Schwertern, du bist der König der Waffen-Attrappen! Bis deine Gegner das merken, ist es schon zu spät für sie.",
				"Bei Freundschaft geht es um's Teilen. Gut dass du gelernt hast, Schläge auszuteilen. So haben deine Gegner auch was davon.",

			],
			#if neko
			DESCADVANCED: [
				"Kraft +3 Kraft +50%",
				"Flinkheit +3 Flinkheit +50%",
				"Geschwindigkeit +3 Geschwindigkeit +50%",
				"Ausdauer +3 Ausdauer +50%",
				"Ausdauer +250% Kraft -25% Flinkheit -25% Geschwindigkeit -25%",
				"Schaden mit Stichwaffen: +50%",
				"Schaden mit bloßen Händen: +100%",
				"+10% Chance zu blocken",
				"+30% Chance auf Konterangriff",
				"+20% Chance auf Combo",
				"+45% Chance zu parieren",
				"Rüstung +5 Geschwindigkeit -10%",
				"Rüstung +2",
				"+30% Chance auszuweichen",
				"Zerstört eine Waffe bei jedem deiner Treffer",
				"+50% Chance auf Entwaffnung",
				"-25% Pause zwischen Angriffen mit schweren Waffen",
				"+30% Chance, Gegner zu verletzen",
				"Der erste Treffer, den du einsteckst, kostet dich nur 0-1 LP.",
				"Schwere Waffen fügen min. 30% Schaden zu.",
				"Der erste Treffer im Kampf wird automatisch verhindert.",
				"Falls dein Schlag deinen Gegner nicht verletzt, erhältst du zu 70% einen weiteren Angriff.",
				"Initiative +200.",
				"Gegnerische Treffer kosten dich max. 20% deiner Lebensleiste.",
				"Initiative -200 Geschwindigkeit +5 Geschwindigkeit +150%.",
				"+10% Chance auszuweichen. Dein Brutalo erhält bei jedem erfolgreichen Block einen Konterangriff.",
				"Bei jedem Angriff gegen dich verliert dein Gegner zu 30% seine Waffe.",

				"Aktion (x2) Dein Brutalo nimmt die Waffe deines Gegners.",
				"Aktion (x1) Dein Brutalo verursacht mit dem nächsten Angriff doppelten Schaden.",
				"Aktion (x1) Dein Brutalo erhält zwischen 25% und 50% LP zurück.",
				"Aktion (x1) Das Netz verhindert, dass dein Ziel deinem nächsten Angriff ausweicht.",
				"Aktion (x2) Alle deine Gegner erleiden zwischen 15 und 25 Schaden.",
				"Aktion (x1) Dein Brutalo verursacht je nach der Kraft deines Gegners schweren Schaden.",
				"Aktion (x2) Dein Brutalo stößt einen Schrei aus, der Tiere vertreibt (50% Erfolgschance).",
				"Aktion (x1) Dein Brutalo übernimmt die Kontrolle über die Tiere deines Gegners.",
				"Aktion (x1) Dein Brutalo greift den Gegner mit der Hälfte seiner Waffen an.",
				"Aktion (x4) Dein Brutalo erhält zwischen 20 und 50% seiner LP zurück, je nach Güte des Fleisches.",

				"Du widerstehst jeden Tag einem weiteren Tod.",
				"(24h) Deine künftigen Gegner erleiden 2% Schaden am Ende jeder ihrer Aktionen.",
				"(24h) Zugriff auf die Profile deiner Gegner.",
				"(24h) Zerstört einen deiner zukünftigen Gegner (Initiative -100 bis zur Benuztung).",
				"(24h) Dein Brutalo kann stärkeren Team-Mitgliedern in Kämpfen helfen.",
			]
			#end
		});
		setLang("fr");
	}

	public static function getBonus(b){
		switch(b){
		case Permanent(p): 	return PERMANENTS[Type.enumIndex(p)];
		case Weapons(w): 	return WEAPONS[Type.enumIndex(w)];
		case Super(s): 		return SUPERS[Type.enumIndex(s)];
		case Followers(f): 	return FOLLOWERS[Type.enumIndex(f)];
		case Talent(f): 	return TALENTS[Type.enumIndex(f)];
		}
	}
	

//{
}
