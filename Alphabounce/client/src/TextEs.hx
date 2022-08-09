class TextEs implements mt.Protect {//}

	  /////////////////
	 /// INTERFACE ///
	////////////////

	public static var FUEL_TITLE = "¡TANQUE DE COMBUSTIBLE VACIO!";
	public static var FUEL_TEXT = "<p><b>¡No te quedan cápsulas de hidrógeno!</b></p><p>El ESCorp te dará tres nuevas cápsulas <font color='#00FF00'>gratis</font> a medianoche (zona horaria Madrid GMT +1h).</p><p>Sin embargo, todavía puedes seguir jugando si compras partidas en la Banca Interestelar.</p>";
	public static var FUEL_BANK = "BANCA INTERESTELAR";

	public static var PAUSE_TEXT = [ "SELECCIONA UNA CAPSULA O PULSA LA TECLA \"P\" PARA REGRESAR AL JUEGO","PULSA LA TECLA \"P\" PARA REGRESAR AL JUEGO"];

	public static var WARNING_ZONE = "¡CURSOR FUERA DE LA ZONA DE JUEGO!";
	public static var START_CLIC_GREEN = "HAZ CLICK EN LA ZONA VERDE PARA COMENZAR";

	public static var WARNING_FAR = "¡Esa posición no puede ser alcanzada en un solo viaje!\nDesplázate de casilla en casilla para alcanzar esa posición.";
	public static var WARNING_CARDS = "¡Ten cuidado! Estás a punto de dejar la zona autorizada.\nTu bola estándar no es lo suficientemente poderosa para ese área.\nDebes obtener la acreditación en primer lugar:";
	public static var ERROR_CRC = "Data reception error. This error can happen if two simultaneous sessions are open in different tabs or browsers.";

	public static var WARNING_CNX = "¡Se ha perdido la conexión con el servidor!\nEl estatus de la partida no se ha guardado.";

	public static var CONNECTION_SERVER = "CONECTANDO AL SERVIDOR...";

	public static var PREF_FLAGS = ["CONTROL DE TECLADO","MOVIMIENTOS VISIBLES","ZONA DE CONSEJOS","BOLA SUPER CONTRASTADA"];
	public static var PREF_TITLE = "PREFERENCIAS";
	public static var PREF_MOUSE = "SENSIBILIDAD DEL RATON";
	public static var PREF_QUALITY = "CALIDAD GRAFICA";

	public static var CAPS_NAME = ["NADA","HIELO","FUEGO","RAYO"];

	  ////////////
	 /// GAME ///
	////////////

	public static var ITEM_NAMES =		[
		"Primer Nivel",
		"Acreditación Alfa",
		"Acreditación Beta",
		"Acreditación Ceta",
		"Bola perforadora",
		"Llamada de socorro",
		"Douglas",
		"Escombros centrales",
		"Escombros punzantes",
		"Escombros extraños",
		"Escombros humeantes",
		"Escombros raros",
		"Pequeños escombros",
		"Escombros inofensivos",
		"Extensión de envoltorio",
		"Símbolos extraños",
		"Salmeen",
		"---",
		"Misil",

		"Mapa de Mercaderes",
		"Misil Azul",
		"Misil",
		"Piedras Licanas",
		"Piedra Spignysos",
		"Estrella Roja",
		"Estrella Naranja",
		"Estrella Amarilla",
		"Estrella Verde",
		"Estrella Turquesa",
		"Estrella Azul",
		"Estrella Morada",
		"Editor de Minas",
		"Medallón - parte redonda",
		"Medallón - parte creciente",
		"Medallón - parte hueca",
		"Medallón Zonkeriano",
		"Bola OX-Soldado",
		"Bola OX-Delta",
		"Bola de Asfalto",
		"Misil Rojo",
		"Ambro-X",
		"Radar ok",
		"Generador",

		"Núcleo antimateria",
		"Núcleo antimateria",
		"Núcleo antimateria",
		"Núcleo antimateria",

		"Proceso verbal de escape",
		"Escudo atmosférico",
		"Armadura externa",
		"Estabilizador hidráulico",
		"Restos de reactor",
		"Superficie de reactor",
		"Traje del espacio",
		"El primo de Salmeen",
		"Chapa del FURI",
		"Pase del Cinturón de Karbonis",

		"Extensión de envoltorio 2",
		"Cristal Rosa A",
		"Cristal Rosa B",
		"Cristal Rosa C",
		"Cristal Rosa D",
		"Cristal Rosa E",
		"Pergamino A",
		"Pergamino B",
		"Pergamino C",
		"Pergamino D",
		"Pergamino E",
		"Pergamino F",
		"Pergamino G",
		"Pergamino H",
		"Accesorio Sintrogénico",
		"Extensión de envoltorio 3",
		"Duplicador de Saumir",
		"Retrofusor de Sactus",

		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",
		"Tablilla de Karbonita",

		"Ingeniero de Karbonita",
		"Mina Fora 7R-Z",

		"PID map element 1",
		"PID map element 2",
		"PID map element 3",
		"PID map element 4",
		"PID map element 5",
		"PID map element 6",
		"PID map element 7",
		"PID map element 8",
		"PID map element 9",
		"PID map element 10",
		"PID map element 11",
		"PID map element 12",
		"PID map element 13",
		"PID map element 14",
		"PID map element 15",
		"PID map element 16",
		"PID map element 17",
		"PID map element 18",
		"PID map element 19",
		"PID map element 20",
		"PID map element 21",
		"PID map element 22",
		"PID map element 23",
		"PID map element 24",
		"PID map element 25",
		"PID map element 26",
		"PID map element 27",
		"PID map element 28",
		"PID map element 29",
		"PID map element 30",
		"PID map element 31",
		"PID map element 32",
		"PID map element 33",
		"PID map element 34",
		"PID map element 35",
		"PID map element 36",
		"PID map element 37",
		"PID map element 38",
		"PID map element 39",
		"PID map element 40",
		"PID map element 41",
		"PID map element 42",

		"Earthling passport",
		"Difficult mode",
	];

	public static var SHOP_ITEM_NAMES = [
		"Motor v1",
		"Motor v2",
		"Motor v3",
		"Motor v4",
		"Motor v5",
		"Motor v6",
		"Mapa de Misiles",
		"Gafas de sol",
		"Misil extra nº 1",
		"Misil extra nº 2",
		"Misil extra nº 3",
		"Cápsula de Hielo",
		"Cápsula de Fuego",
		"Cápsula de Agujero Negro",
		"Cápsula Sólida de Hidrógeno",
		"Reactores laterales",
		"Refrigerante líquido",
		"Recarga de munición",
		"Envoltorio de seguridad",
		"Robot de apoyo",
		"Robot > Herramientas de Perforación",
		"Robot > Soporte para el motor",
		"Robot > Convertidor",
		"Robot > Colector",
		"Radar de emergencia",
		"Cápsula de rayo",
		"Motor de síntesis perpetua",
		"Antena KI-WI",

		"Pata de aterrizaje",
		"Extensión estándar de pata",
		"Extensión especial de pata",
		"Extensión definitiva de pata",
		"Motor turbo de superficie",
		"Motor turbo-X2 de superficie",
		"Motor turbo-X3 de superficie",

		"Mina extra nº1",
		"Mina extra nº2",
		"Mina extra nº3",
	];

	public static var OPTION_NAMES = [
		"ATRACCION",
		"POTENCIA",
		"CONTROL",
		"DISMINUCION",
		"EXTENSION",
		"LLAMA",
		"GLACIAL",
		"HALO",
		"INDIGESTION",
		"JABALINA",
		"KAMIKAZE",
		"LASER",
		"MULTIBOLA",
		"NUEVA BOLA",
		"INTRO",
		"PROVISION",
		"QASAR",
		"REGENERACION",
		"SEGURIDAD",
		"TRANSFORMACION",
		"ULTRAVIOLETA",
		"VOLTIO",
		"WHISKY",
		"XANAX",
		"YO-YO",
		"ZEAL",
		"MISILE",
	];

	  //////////////
	 /// ENDING ///
	//////////////

	public static var OUTRO_0 = "After a few months of travelling through the universe, you are back on Earth.\n\nYour return has pushed the media to force the ESCorp to fulfill its promess towards you.\n\nYou are now free to live as you wish...\n\n\n\n What are you going to do?";

	public static var OUTRO_1 = "After a few months of travelling through the universe, you are back on Earth.\n\nYour revelations about the ESCorp's way of doing things have provoked a scandal throughout the media.\n\nYou are now free to live as you wish...\n\n\n\n What are you going to do?";

	public static var OUTRO_2 = [
		[ 	"Have a peaceful life",
			"The ESCorp will take back your envelope and all your upgrades.\nYour current progression will be lost.",
			"This option allows you to unlock AlphaBounce's <font color='#ff0000'>difficult mode</font>."
		],
		[ 	"Go back in outer space",
			"You will be immediately transferred to your envelope's origin point with all your current upgrades.",
			"Your radar and engine strength will be permanently upgraded by one unit."
		],
	];

	  //////////////
	 /// EDITOR ///
	//////////////

	public static var EDITOR_CLIC_SUPPR = "clic + supprime ; efface une brique.";

	public static var EDITOR_BUTS = [
		"VOLVER",
		"LIMPIAR BLOQUES",
		"GUARDAR",
		"MODERACION",
		"RESETEAR NIVEL",
		"ACEPTAR",
		"NEGAR TODO"
	];

	  ////////////////
	 /// TRAVELER ///
	////////////////

	public static var TRAVELER_NAMES = [ "Walter", "Ben", "Jokarix", "Goshmael", "Mirmonide", "Korkan", "Gifu","Birman","Falgus","Moktin","Bifouak","Lacune","Gibarde","Blafaro","Kimper","Sochmo","Nicolu","Mangerin","Difidus","Stridan","Glochar","Mikou","Kilian","Daston","Possei","Spido","Corneli","Brifuk","Colcanis","Frederak","Coustini","Darnold","Fruncky","Jimic","Sachude","Bramhan","Nucrcela"];

	public static var TRAVELER_JOBS = [
		"fontanero",
		"técnico IT",
		"megacróbata",
		"asesino en serie",
		"::user:: de ::stuff0::",
		"::user:: de ::stuff1::",
		"Agente secreto del ESCorp",
		"Fan de ::singer::",

	];

	public static var TRAVELER_USER = [	"seller",
		"tragador",
		"probador",
		"lanzador",
		"catador",
		"cazador",
	];

	public static var TRAVELER_STUFF_0 = [
		"nata batida",
		"sentimientos",
		"yogur",
		"jabalox",
		"cápsula de hidrógeno",
		"conglomerados",
		"gemas",
		"plasma energético",
		"cables eléctricos",
		"zapatos líquidos",
		"crema de carne",
		"restos de envoltorio",
		"kebab",
		"luz cegadora",
		"cartucho de SNES",
		"sushi",
		"croissants",
	];

	public static var TRAVELER_STUFF_1 = [
		"langosta",
		"escalera",
		"espárragos",
		"arañas gigantes extraterrestres",
		"pantalla gigante",
		"envoltorio experimental",
		"envoltorio coleccionable",
		"orejas usadas",
		"naranjas",
		"imágenes coleccionables",
	];

	public static var TRAVELER_MISS = [
		"confianza en sí mismo",
		"monedas",
		"materia gris",
		"tiempo para el ocio",
		"novias",
		"una forma de hacerme destacar",
		"gente que conozco",
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
		"Hola prisionero humano,\n",
		"Hola,\n",
		"Querido desconocido,\n",
		"Bienvenido extraño,\n",
		"He estado esperando tu visita desde hace tiempo...\n",
		"Por fin, ¡un visitante!\n",
		"¡Umph!\n",
		"¡Hola! ¿Hay alguien por ahí?\n",
		"¿Quién anda ahí?\n",
		"¡Hola!\n",
	];

	public static var TRAVELER_WHO = [
		"Mi nombre es ::name::, soy ::profession:: en este planeta.",
		"Mi nombre es ::name::, podemos ser amigos si así lo deseas.",
		"Soy un humilde ::profession::.",
		"Me llaman ::name:: el ::profession::.",
		"Mi nombre es ::name::, ¿quieres ser mi amigo?",
		"Mi nombre es ::name::, no tengo muchos ::miss:: desde que soy un ::profession::.",
		"¿Quién eres? Soy ::name:: el ::profession::.",
	];

	public static var TRAVELER_LEAVE = [
		"Desde siempre he querido abandonar ::start::.",
		"::start:: no me gusta tanto como antes,",
		"::start:: no es un buen lugar para vivir,",
		"No hay nada que hacer en ::start::,",
		"¿Crees que podrías vivir en ::start::? Porque yo personalmente ya he tenido suficiente...",
		"No hay mucha gente por aquí... si esto sigue así perderé mi trabajo."
	];


	public static var TRAVELER_DEST = [
		"Sé, desde lo más profundo de mí, que una vida mejor me espera en ::end::.",
		"Quizás podría empezar desde cero en ::end::.",
		"Siempre he soñado con ir a ::end::",
		"Mi sueño es ir a ::end::",
	];

	public static var TRAVELER_DEST_COORD = [
		"Necesito encontrar mi keychain... Lo perdí mientras viajaba por ::pos::.",
		"Mi proyecto es construir una nueva colonia en ::pos::.",
		"Me gustaría abrir una nueva tienda espacial en ::pos::.",
		"Si pudieras llevarme a ::pos::, podría encontrarme con mi tío, quien lleva una hamburguesería-satélite por la zona.",
		"He oído hablar de una discoteca astral muy chula en ::pos::.",
		"Las cajas de ::stuff0:: han sido abandonadas en ::pos::, ¡me gustaría ir para allá lo más rápido posible!",
		"Alguien me dijo que ::singer:: va a dar un concierto sorpresa en ::pos:: esta semana.",
	];

	public static var TRAVELER_ASK_0 = [
		"¿Me podrías llevar allí?",
		"¿Me ayudarías a viajar hasta allí?",
		"¿Podía acompañarte hasta allí?",
		"¿Podría ir contigo?",
	];

	public static var TRAVELER_ASK_1 = [
		"Tendré que usar uno de tus envoltorios para poder viajar contigo.",
		"Necesito uno de tus envoltorios de emergencia para seguirte, soy demasiado grande para estar en un solo envoltorio contigo.",
	];

	public static var TRAVELER_REWARD_MIN_0 = [
		"Si me llevas te puedo dar ::rmin:: minerales.",
		"Puedo pagarte con ::rmin:: minerales.",
	];

	public static var TRAVELER_REWARD_MIN_1 = [
		"¡Son todos mis ahorros!",
		"No me queda nada más.",
		"No tienes por qué cogerlo todo...",
		"Espero que sea suficiente.",
	];

	public static var TRAVELER_REWARD_KEUD = [
		"",
		"No tengo dinero para pagarte el viaje, pero estoy seguro que me ayudarás con todo tu corazón...",
	];

	public static var TRAVELER_REWARD_CAPS = [
		"También tengo algo para echarte una mano con el combustible: ¡::rcap:: CSH!",
		"Para el combustible también tengo ::rcap:: CSH, las cuales deben ayudarte para viajar un poco.",
	];

	public static var TRAVELER_NO_SLOT = "\nPero no puedes hacer nada para mí...\nGracias por tu visita de todos modos. Sienta bien charlar con alguien de vez en cuando.";

	public static var TRAVELER_LEAVE_PLANET = [
		[	// 0 - MOLTEAR
			"Las moléculas espaciales hacen nuestra vida imposible... Ayer bloquearon la puerta de mi salón.",
			"Las moléculas se están multiplicando muy rápidamente por esta zona, creo que es momento de partir.",
			"¡Es muy molesto! Las moléculas destruyeron mi ::stuff0:: otra vez esta mañana. Ya no me quedan más razones para vivir aquí.",
		],
		[	// 1 - SOUPALINE
			"El aire marino de Supaline nunca me hizo nada bueno. Creo que la sal empezó a erosionar mi cerebro.",

		],
		[	// 2 - LYCANS
			"::start:: es demasiado inestable para mí, ¡ayer el repartidor de ::stuff0:: fue propulsado hasta la órbita tras una explosión en la superficie!",
			"¿Crees que podrías vivir en ::start::? ¡Pff, allí hay al menos 20 explosiones cada noche!",
			"He perdido 13 Shmolgs desde que empezara la guerra... Y todo esto a causa de las explosiones de sulfuro en ::start::.",
		],
		[""],	// 3 - SAMOSA
		[	// 4 - TIBOON
			"Arena, arena y más arena. No hay nada más aquí...",
			"He explorado todas la dunas de ::start::. Creo que es hora de hacer otra cosa.",
		],
		[	// 5 - BALIXT
			"Los balixteanos son gente opresora y rencorosa. ¡La situación aquí es horrible!",
			"Ayer Franxis fue golpeado por uno de esos asquerosas seres, ¡y desde entonces no he podido encontrarlo!",
			"El nuevo gobernador de Balixt hace que la vida de los extraños sea muy difícil.",
		],
		[""],	// 6 - KARBONIS
		[	// 7 - SPIGNYSOS
			"::start::, digamos que está un poco muerto en la época de invierno, sabes lo que quiero decir...",
			"¿Has visto el tiempo tan malo que hace? De ninguna manera, ¡no pienso quedarme más en ::start::!",
			"Anoche la temperatura descendió hasta -50Â°C, he perdido un dedo del pie...",
			"¡Mi ::stuff0:: se congeló anoche!",
		],
		[	// 8 - POFIAK
			"::start:: es demasiado húmedo para mí, seguro que acabaré enfermando si me quedo aquí.",
			"Los ataques de los insectos psionicos me han convencido para abandonar ::start::.",

		],
		[""],	// 9 - SENEGARDE
		[	// 10 - DOURIV
			"Están viniendo muchos mineros, ¡pronto ::start:: estará cubierto de complejos mineros autónomos!",

		],
		[""],	// 11 - GRIMORN
		[	// 12 - DTRITUS
			"La calidad del aire del planeta se ha deteriorado y finalmente comer niños no es lo mío...",
		],
		[ 	// 13 - ASTEROBELT
			"La vida de un ermitaño perdido en un asteroide se está volviendo muy aburrida.",
		],
		[	// 14 - NALIKORS
			"Cada día hay más RAIDs del ESCorp, creo que mi vida corre peligro aquí.",
			"Vine para unirme a los FURI pero la actitud un tanto maníaca de Kefrid me hace dudar...",
		],
		[	// 15 - HOLOVAN
			"Comencé mi meditación trascendental interna con los kemilianos hace unos 37 años.",
			"Desde que terminara mis estudios, ya nada me ata a Holovan.",
		],
		[	// 16 - Khorlan
			"Quiero viajar a través del universo, ¡igual que Salmeen!",
			"Las nueces que estaban en la órbita han caído sobre mi pueblo y lo han destrozado, ¡solo queda en pie mi casa! ¡No quiero quedarme aquí solo!",
		],
		[	// 17 - CILORILE
			"A causa de los atascos no podemos movernos entre las 9h y 9h20 por la mañana y las 18h y las 18:50 por la tarde. Esto no es vida, ¡quiero marcharme de este planeta!"
		],
		[""],	// 18 - TARCITURNE
		[""],	// 19 - CHAGARINA
	];

	public static var TRAVELER_DEST_PLANET = [
		[	// 0 - MOLTEAR
			"Las moléculas espaciales parecen muy interesantes, creo que podré estudiarlas cuando llegue allí."
		],
		[	// 1 - SOUPALINE
			"Tener el océano a la vista me hace soñar despierto..."
		],
		[	// 2 - LYCANS
			"Espacios abiertos... ¡no hay nada mejor!"
		],
		[""],	// 3 - SAMOSA
		[	// 4 - TIBOON
			"En cualquier sitio estaré más tranquilo que en este pequeño y ruidoso planeta."
		],
		[	// 5 - BALIXT
			"Los balixteanos necesitan mano de obra para construir su imperio. Seguramente necesitarán algunos ::profession:: por aquí.",
			"Las instalaciones de Reducine necesitan mucha mano de obra. Seguro que encuentras un trabajo aquí."
		],
		[""],	// 6 - KARBONIS
		[	// 7 - SPIGNYSOS
			"Estamos sofocados aquí, ¡necesito aire fresco!",
			"¡Dicen que la superficie es tan brillante que apenas se pueden abrir los ojos!"
		],
		[	// 8 - POFIAK
			"Necesito algo de vegetación."

		],
		[""],	// 9 - SENEGARDE
		[	// 10 - DOURIV
			"¡Dicen que por allí todo lo que tienes que hacer es agacharte para coger los cristales! ¿No te parece increíble?",
			"Podría ser rico allí, parece que la superficie está cubierta de cristales."
		],
		[""],	// 11 - GRIMORN
		[	// 12 - DTRITUS
			"¡He oído que allí se puede empezar una carrera profesional de asustador de niños!"
		],
		[ 	// 13 - ASTEROBELT
			""
		],
		[	// 14 - NALIKORS
			"¡Unirse a los FURI para buscar aventura debe ser toda una experiencia!"
		],
		[	// 15 - HOLOVAN
			"Mi sueño es encontrar los kemilianos y vivir con ellos."
		],
		[	// 16 - KHORLAN
			"Me gustaría un poco de vegetación."
		],
		[	// 17 - CILORILE
			"Marine de aire: ¡bien está para lo que tengo!"
		],
		[""],	// 18 - TARCITURNE
		[""],	// 19 - CHAGARINA
	];


	  //////////////////
	 /// ITEM GIVER ///
	//////////////////

	public static var ITEM_GIVER_SALMEEN_COUSIN = "¡Hola Salmeen!\nHacía tiempo que no nos veíamos! ¿Necesitas algo? Mmm.... vienes con un amigo: veré si puedo encontrar lo que estás buscando.\n*Gregune abre un gran cofre en la parte trasera de la habitación*\nAquí tienes un traje espacial suptirneano, lo que quiere decir que tiene un par de mangas en la parte trasera que no te serán muy útiles, pero bueno, de algo te servirá. Está equipado con un jetpack que te permitirá moverte con facilidad. Suerte para los dos, ¡hasta pronto!";

	public static var ITEM_GIVER_BADGE_FURI = "¡Bienvenido compañero!\nEl RCEH necesita cualquier alma disponible para luchar contra la expansión de la humanidad. No tenemos políticas discriminatorias y tu orígenes humanos no son un obstáculo para unirse a nuestra causa. Puedes participar en las operaciones de sabotaje del ESCorp para el rescate de prisioneros en este sistema.\n¡Gracias por tu ayuda!";

	public static var ITEM_GIVER_SAUMIR = "¡Extraño noyaguldo! Soy Saumir.\nLos kemilianos están felices de poder darte la bienvenida. Nuestra gente vino a Holovan hace miles de años, no deseamos participar en los conflictos étnicos de tu joven civilización. Todavía tenéis que progresar en la historia para poder llegar a comprender el gran destino de Koshmerate.\nQue el Gran Kluc esté contigo extraño. Llévate esta bola duplicadora, te servirá de gran ayuda.";

	public static var ITEM_GIVER_SACTUS = "Hola prisionero.\nSoy el doctor Sactus, pero puedes llamarme Doc. Éste es mi laboratorio, donde construyo todo con los recursos metálicos de Grimorn. El Retrofusor está aquí listo, puedes llevártelo. Cuando lo uses, asegúrate de no pulsar el botón del ratón con el dedo anular, o acabarás teleportado al centro de la supernova de Zambreze, donde tu masa molecular sería terriblemente influida.\n¡Espero que hayas prestado atención a mis instrucciones! ¡Nos vemos!";
	public static var ITEM_GIVER_SAFORI_0 = "Mi nombre es Safori. Vine a Nalikors cuando mi planeta de origen, Karbonis, explotó.\nAhora estoy atascado en este planeta. Me gustaría trabajar otra vez: Soy un experto arquiniero. Puedo reconstruir cualquier máquina vieja si tengo los planos y el material necesario... Desafortunadamente, no hay ningún proyecto disponible por aquí.\nGracias por tu visita, ¡ya nos veremos!";

	public static var ITEM_GIVER_SAFORI_1 = "¡¡Estupendo!!! ¡Gracias a estas tablillas podré finalmente trabajar! Veamos... hmmmm parece interesante, es como un sistema antiguo de navegación. Tengo todo lo necesario para construirlo. Espera un momento, por favor. \n............\n............\n............\n............\n............\n\n¡Ahí tienes!\n¡Para ti! Gracias a este nuevo sistema de navegación, el rango del radar de tu envoltorio espacial ha sido mejorado.\nGracias por las tablillas, ¡las guardaré!!\nQue las puertas de Shamu estén abiertas para ti, amigo mío.";

	public static var ITEM_GIVER_COMBINAISON = "Hola prisionero, hermo preparado tu traje espacial. Por favor rellena el formulario DZ-578 y deja tus huellas dactilares en las zonas A, B y C de estos papeles.\n...\nGracias\n...\nAquí tienes tu traje espacial.\nBuena suerte.";

	public static var ITEM_GIVER_TABLET_KARBONIS_0 = "La Memoria de Karbonis ";
	public static var ITEM_GIVER_TABLET_KARBONIS_1 = [
		"corre en tus venas",
		"está en cada uno de nosotros",
		"no puede desaparecer",
		"brilla en tus ojos",
		"es un tesoro",
		"será salvada",
		"es el más preciado de los tesoros de Zonker",
		"está escrita en el corazón de Shamu",
		"no debe caer en las manos equivocadas",
		"está preservada en este lugar",
		"está escondida en cada uno de estos asteroides",
		"viaja a través del tiempo y del espacio",
	];
	public static var ITEM_GIVER_TABLET_KARBONIS_2 = "...\nCoge esta tablilla y protégela.";
	public static var ITEM_GIVER_TABLET_KARBONIS_3 = "Aquí no eres bienvenido.";

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
		"¡Hola amigo!\n",
		"¡Hola compañero!\n",
		"¡Hola!\n",
		"Bienvenido a mi hogar\n",
	];

	public static var FURI_ARGUE = [
		"¿Sabes cuántos planetas están ocupados o minados por los humanos en el universo? Unos 35 millones. El 30% de estos planetas están operados por el ESCorp, el cual se acerca cada vez más a nuestro sistema.\n",
		"Desde que el ESCorp empezara a enviar prisioneros a nuestro sistema, algunos planetas como Tiboon o Licanos han sido devastados. Sus peligrosos experimentos han incluso provocado la explosión de Karbonis, un planeta en plena expansión.\n",
		"Desde su llegada, la desatención a las leyes naturales ha provocado enormes catástrofes: la explosión de Karbonis, el descenso de la natalidad de los Glurt de Moltear, la contaminación del océano de Supaline, etc. Una auténtica tragedia.\n",
		"El ESCorp empezó sus operaciones mineras y carcelarias en este sistema hace 30 años. Desde su llegada, su indiferencia hacia la naturaleza provocó enormes catástrofes. Los vientos solares son cada vez más cálidos, los Glurt de Moltear sufren un descenso de la natalidad... todas estas tragedias se deben a la expansión del ser humano.\n"
	];

	public static var FURI_REWARD_MIN = "¡Puedo ayudarte, compañero! Llévate estos :::rmin: minerales y úsalos con sabiduría.\nEs todo lo que me queda.";
	public static var FURI_REWARD_CAPS = "Tengo algo que puede ayudarte en tu aventura, ¡amigo mío! Llévate estas ::rcaps:: CSH.\nGracias, ¡nuestro vuelo va a partir!";

	public static var FURI_END_0 = "La Fundación de Unidad Racionalista de la Infinidad (FURI), ";
	public static var FURI_END_1 = [
				"sugiere alternativas para permitir a las gentes del universo usar los recursos sin dañar la biodiversidad de nuestro universo estelar.",
				"actúa en contra de la expansión incontrolada organizando sabotajes con el objetivo de reducir las grandes corporaciones humanas como el ESCorp",
			];

	public static var FURI_BETRAY = [
		"¡Ayuda!",
		"Has tomado una decisión muy triste, amigo.",
		"¿Por qué tanto odio?",
		"Supongo que el ESCorp te paga bien por este trabajo...",
	];

	public static var FURI_LUCK = [
		"¡Buena suerte!",
		"Cumple tu destino, humano. ¡Salva nuestro universo!",
		"¡Que las puertas de Shamu estén abiertas para ti!",
	];

	//////////////
	/// GOSSIP ///
	//////////////

	public static var GOSSIP_CRYSTAL = "En un vuelo rutinario de hiperespacio vi unos extraños resplandores rosas en ::coord::. Es muy raro encontrar eso a tal velocidad. Debe de haber algo interesante por allí.";


	public static var GOSSIP_NOYAUX_0 = [
		"Un equipo entero de hierro-criquet",
		"La cápsula del espacio de mi tío",
		"Una flota balixteana completa",
		"Un escuadrón de 4 envoltorios de prisioneros del ESCorp",
		"Una ballena estelar de unas 650 toneladas de peso",
	];

	public static var GOSSIP_NOYAUX_1 = " ha sido misteriosamente tragado por un punto negro en el espacio. El equipo de rescate de mi pueblo se pasó más de una semana en el área ::coord::, pero no encontró nada.";

	public static var GOSSIP_TABLET = "Sobreviví a la explosión de Karboni, pero toda mi familia pereció. Los restos de nuestra civilizacón flota en el espacio... *snif*. Mientras exploraba el cinturón de asteroides encontré una tablilla de karbonita en ::coord::. No pude llevarla conmigo porque era demasiado pesada pra mí.";

	public static var GOSSIP_ASPHALT = "Se dice que el ESCorp está trabajando en una superpotente bola perforadora en el sistema Stuklie, al sudeste de nuesta posición.\nTienen que mandarnos los resultados muy pronto.";

	public static var GOSSIP_DEFAULT = [
		"El FURI ha organizado varias revueltas. El año pasado una delegación de unos 350 representantes consiguieron obtener una reunión con el presidente de la confederación humana en la Tierra.",
		"Nunca volveré a ver a mis amigos de Karbonis. Déjame en paz. Vosotros los humanos no sabéis apreciar lo que de verdad tiene valor.",
		"Nebulae brilla tanto que a menudo molesta a los pilotos. Por ello nuestros pilotos nunca salen sin sus gafas de sol.",
		"Odio la compota.",
		"En el universo hay algunos conglomerados tan potentes que pueden invertir tus sentidos.",
		"El año pasado mis vacaciones en Samosa fueron horribles. ¡No tuvimos buen tiempo en toda una semana!",
		"Los conejo-robots nunca pudieron entrar en nuestro sistema. Creo que la gente debe quejarse menos del ESCorp. ¡Desde que los humanos llegaron aquí no ha habido ni una sola guerra más!",
		"Una patrulla de conejo-robots se llevó a mi abuela hace 28 años y nunca más la hemos vuelto a ver... Es muy difícil de decir, pero debo admitir que la presencia del ESCorp ha contribuido a la seguridad de nuestro sistema.",
	];

	public static var GOSSIP_MISSILE_0 = "Mientras estaba dando una vuelta en el área ::coord:: vi una carcasa de un misil viejo.\n";
	public static var GOSSIP_MISSILE_1 = [
		"El espacio se ha vuelto un lugar muy sucio.",
		"Los jóvenes no tienen respeto por nada...",
		"Espero que los coleccionistas de restos pudieran cogerlo.",
		"No me dejé llevar por el miedo a una explosión.",
		"Estaba en muy mal estado.",
	];

}
