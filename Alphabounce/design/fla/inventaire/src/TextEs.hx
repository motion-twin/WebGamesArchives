import Text;

class TextEs {

	public static var EXTRA_LIFES = " vidas extra";
	public static var EXTRA_LIFE  = " vida extra";
	public static var EXPLORING = "Planeta en exploración.";

	//
	public static function getText( i:Int ) : Tip {
		var text = [
		[ "Bola perforadora RCD-20", "Puede destruir conglomerados férreos." ],
		[ "Bola OX-Soldado", "Destruye moléculas parásitas." ],
		[ "Bola OX-Delta", "Tiene doble poder perforador."],
		[ "Bola secreta :\nProyecto-Asfalto", "Bola de efectos desconocidos."],

		[ "Misil estándar", "Mantén la barra de espacio pulsada para enviar un misil destructor."],
		[ "Misil AR-57", "Su poder explosivo permite destruir hasta 9 bloques de un solo tiro."],
		[ "Misil MAS-Z", "Puede destruir cualquier tipo de conglomerado."],
		[ "Misil AR-SRX", "Zona de daño altamente mejorada. Este misil puede destruir hasta 25 conglomerados."],

		[ "Perforation tools", 	"Tus robots desmantelan más rápidamente los centinelas."],
		[ "Reactor Support", 	"Tus robots se mueven más rápidamente."],
		[ "Converter", 		    "Tus robots convierten los centinelas en minerales."],
		[ "Collector",			"Tus robots pueden coleccionar minerales."],

		[ "Mapa de los Mercaderes", "Los mejores lugares donde puedes actualizar tu envoltorio por unos pocos minerales."],
		[ "Mapa de Misiles", "Encuentra cualquier rastro de misiles abandonados para aumentar la capacidad de síntesis de tus misiles."],
		[ "Mapa de agujeros negros", 	"Los agujeros negros te permitirán viajar rápidamente de un lado de la galaxia a otro."],

		[ "Licencia Alpha", "Uno de los tres pases que contiene la autorización para usar bolas perforadoras en este sistema."],
		[ "Licencia Beta", "Uno de los tres pases que contiene la autorización para usar bolas perforadoras en este sistema."],
		[ "Licencia Ceta", "Uno de los tres pases que contiene la autorización para usar bolas perforadoras en este sistema."],

		[ "Reactores laterales", "Tu envoltorio espacial se gira más rápido para el lanzamiento de misiles."],
		[ "Refrigerante líquido", 		"El envoltorio espacial puede lanzar misiles más rápido."],
		[ "Motor de síntesis perpetua", 	"El envoltorio genera un misil en cada nuevo sector alcanzado."],

		[ "Gafas de sol", "Evita el calor de las moléculas flash y mejora la visibilidad de las estrellas luminosas de los clústeres."],
		[ "Medallón zonkeriano", "La increíble energía que emite mejora la estabilidad del envoltorio y la velocidad de sus movimientos."],
		[ "Antena Ki-Wi", "Radar extraterreste con vitamina C y E. Mejora las señales de radio." ],
		[ "Antimateria", "Antimateria" ],
		[ "Ambro-X", "Mejora en 1 punto el rango de tu radar." ],
		[ "Acelerador syntrogénico", "Crea una cápsula de hidrógeno líquido al día." ],
		[ "Retrofusor de Litio", "Te envía de vuelta a tu posición de origen de forma rápida e indolora." ],
		[ "Traje del espacio", "Puedes salir de tu envoltorio espacial incluso en planetas cuya atmósfera sea irrespirable." ],
		[ "","" ],
		[ "","" ],
		[ "Genemill", 			"Un reactor de fisión de cuarta generación. Ha sido transferido al ESCorp." ],
		[ "", 				"" ],
		[ "Gemelador de Saumir", 	"Durante la síntesis de tu primera bola de perforación, el gemelador ha sido activado y crea una segunda bala idéntica." ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "", 				"" ],
		[ "Medallón incompleto", "Es un medallón zonkeriano pequeño. Está incompleto." ],
		];
		return { title:text[i][0], desc:text[i][1] };
	}

	public static function getPlanet(i:Int) : String {
		var texts = [
		// Moltear
		"Planeta rocoso con una gran actividad parásita molecular. Es una antigua colonia zonkeriana que posee una gran cantidad de ruinas en el hemisferio sur.",

		// Supaline
		"Planeta que posee características similares a las de la Tierra. Un proceso estándar de terraformación ha sido recientemente iniciado por el ESCorp para establecer una colonia perforadora en un futuro cercano.",

		// Licanos
		"Gran planeta volcánico cuya gran concentración de conglomerado de polvoactivo hace de su exploración una tarea peligrosa.",

		// Samosa
		"El planeta más grande del sistema zonkeriano. Posee una increíble densidad y excepcional fuerza de gravedad que dificultan cualquier operación minera.",

		// Tiboon
		"Planeta desierto de pequeño tamaño. Sus moderados recursos son explotables.",

		// Balixt
		"Planeta de origen de una raza extraterreste tecnológicamente avanzada. Los balixteanos, bastante xenófobos, han dejado centinelas a lo largo y ancho de su territorio y no toleran ninguna intrusión.",

		// Karbonis
		"La explosión del principal reactor de una industria minera gigantesca causó la inestibilidad del centro del planeta de Karbonis, el cual acabó finalmente destruido por implosión. Por ello, se generó en el sistema zonkeriano un cinturón de asteroides que posteriormente se llamaría \"Cinturón de Karbonis\".",

		// Spignysos
		"La temperatura de la superficie de Spignysos nunca aumenta de los -50 grados Celsius. Los vientos helados de la superficie alteran la matrix del envoltorio y endurecen el espacio minero. Este fenómeno es llamado \"stasis spignysiana\".",

		// Pofiak
		"La presencia de agua y el clima templado de Pofiak permite el crecimiento de junglas tropicales en toda su superficie. Los insectos psiónicos pueden parasitar el movimiento de la matrix de tu envoltorio.",

		// Senegarde
		"Planeta gaseoso. La presencia de frugi-azote hace que sea un terreno muy fértil para las moléculas parasitarias. Aquí se desarrollan más rápido que en ningún otro lugar.",

		// Douriv
		"Este planeta es extremadamente rico en minerales. El 75% de su superficie está cristalizado o en proceso de cristalización. Es el destino favorito de los mineros espaciales. Desafortunadamente, los insectos psiónicos infectan las regiones más ricas de Douriv.",

		// Grimorn
		"Es un planeta muerto cuyo suelo es muy pobre por la presencia de conglomerados metálicos, los cuales impiden cualquier actividad minera intensa.",

		// D-Tritus
		"Planeta depósito donde habitan unos terribles monstruos. Están organizados en sociedad y viven gracias a la explotación de los recursos de otro planeta situado en una lejana galaxia. La tecnología que les permite viajar tan lejos sigue siendo desconocida.",

		// Asteroide
		"Cadena de asteroides de Karbonis: el viejo planeta explotó y creó un vasto campo de asteroides...",

		// Nalikors
		"Un planeta seco con vegetación etérea. Este planeta fue el punto de partida de todos los anarquistas del universo. FURI es el nombre del movimiento, el cual posee más de 242 miembros en este sector.",

		// Holovan
		"Un antiguo planeta rocoso. Es el hogar de los kemilianos, una civilización de más de 120.000 años. Con el objetivo de no ser molestados, los kemilianos siembran el cielo con centinelas kashuat.",

		// Khorlan
		"Un grasiento y confortable planeta. Es un lugar agradable para vivir. Muchos colonos huyeron de los problemas políticos de su galaxia y se unieron a Khorlan. De vez en cuando la caída de nueces de la órbita molesta sus pacíficas vidas.",

		// Cilorile
		"Un planeta con agua y atmósfera respirable. Cilorile es evitado por la mayoría de los mineros a causa de sus guardianes de conglomerados. El contacto con ellos causa una inmediata explosión del envoltorio.",

		// Tarciturno
		"Este planeta fue devastado hace muchos años por una lluvia de meteoritos.",

		// Chagarina
		"Un planeta calcáreo muerto hace algunos milenios. Su avanzado estado de cristalización y su lejana localización en el sistema zonkeriano lo hacen un destino privilegiado para los mineros.",

		// Volcer
		"Planeta de largas dimensiones que contiene el agua suficiente como para mantener diferentes formas de vida. A pesar de su difícil acceso, Volcer atrae cada año varios miles de turistas proveniente de todos los sistemas que lo rodean.",

		// Balmanch
		"Planeta epino-calcáreo de tipo vocerone. La fuerte saturación de almidón en la atmósfera ha supuesto la proliferación de nueces orbitales. Hoy en día sólo los pilotos más experimentados pueden sobrevolar Balmanch sin riesgo.",

		// Folket
		"Planeta gaseoso. La implosión del centro del planeta hace más de veinte mil años llevó a su suelo a una vaporización perpetua de arcilla clorada. Las capas de la superficie pasaron a ser muy ácidas y dificulta su trabajo a los envoltorios espaciales. Un blindaje particular es requerido.",
		];
		return texts[i];
	}

	public static function getStar( i:Int ){
		return ["Roja","Naranja","Amarilla","Verde","Turquesa","Azul","Morada"][i]+" Estrella";
	}

	public static function getTip( k:TKind ){
		return switch (k){
			case TGenerator: {title:"Generador del envoltorio espacial", desc:"Te permite viajar $0 bloques por cápsulas de hidrógeno."};
			case TDrone:  {title:"Robot de soporte", desc:"Puede desactivar trampas en algunos conglomerados."};
			case TKarbonite: {title:"Tablilla de karbonita", desc:"Efecto desconocido."};
			case TAntimater: {title:"Nucleo antimateria", desc:"Poderosos poderes de destrucción. Posees $0 de 4."};
			case TCrystal:   {title:"Cristales rosas", desc:"El centro del cristal parece que palpita, tienes $0/5."};
			case TLycans:	 {title:"Roca de lycanos", desc:"Su temperatura no ha bajado desde que la trajiste a tu envoltorio."};
			case TSpignysos: {title:"Roca de spignysos", desc:"Un fina capa de hielo cubre la roca."};
			case TAR57:	 {title:"Fusión" , desc:"La reacción química que se produce cuando acercas las dos piedras te permite sintetizar misiles AR-57."};
			case TMine:	 {title:"FORA 7R-Z mine" , desc:"Mina de taladro de síntesis automática. Tienes $0/4."};
			case TReactor:	 {title:"Reactor de superficie" , desc:"Te permite volar sobre los planetas. Su potencia es de $0 unidad(es)."};
			case TPods:	 {title:"Patas de aterrizaje", desc:"Estas patas retráctiles de $0 metros de largo te permiten aterrizar sobre un suelo que esté lo suficientemente plano."};
			case TRadar:	 {title:"Radar", desc:"Tu radar te permite alcanzar áreas desconocidas localizadas a $0 espacios desde la zona que has explorado."};
			case TEarthMap:	 {title:"Mapa PID", desc:"Es un mapa de origen terrestre. Una vez reconstituido, revelará las coordenadas de un nuevo planeta. Te quedan $0 partes."};
			case TEarthMapComplete:	 {title:"Mapa completo PID", desc:"Es un mapa de origen terrestre. El planeta descrito te parece familiar. En el centro del mapa puedes observar las coordenadas."};
		}
	}
}








