import Protocole;

class LangEs implements haxe.Public
{//}
	static var PIX = "<font color='#92d930'>.</font>";
	static var PIX2 = "<font color='#52b31e'>.</font>";
	static var DARK_PINK = "#FF8888";
	static var PINK = "#FFAAAA";
	static var WHITE = "#FFFFFF";

	static var MOJO_LEFT = "Karma restante";
	static var MOJO_FULL = "Karma excedente";
	static var CARD_LEFT = "Cartas insuficientes: ";
	static var CARD_FULL = "Demasiadas cartas: ";
	static var START_GAME = "Iniciar la partida";
	
	static var SELECT_CARDS = "Utiliza todos tus puntos de karma para lanzar una partida.";
	static var TOO_MUCH_CARDS = "Retira algunas cartas de tu baraja para iniciar la partida.";
	
	static var EACH_USE = "Con cada uso: ";
	static var I_SUBSCRIBE = "¡Juega ya!";

	static var UP_LEVEL = "niv." ;
	
	static var BROWSER_PARAMS = [ "Ordenar por costo", "Esconder las cartas demasiado caras", "Esconder las cartas en regeneración" ];
	static var BROWSER_TUTO = "Elige tus cartas por un total de 6 puntos de karma.";
	static var BROWSER_NO_CARD = "No alcanzas a tener 6 puntos"+PIX2+" de karma con tus cartas activas"+PIX2+".\n¡Todas tus cartas serán\n reactivadas a medianoche!\n\nPuedes comprar igualmente"+PIX2+" cartas suplementarias en la tienda:";
	static var BROWSER_HAND_LIMIT = "No puedes jugar más de %0 cartas";
	static var BROWSER_MULTI_LIMIT = "Sólo puedes jugar un ejemplar de esta carta.";
	static var BROWSER_MIDNIGHT = "Esta carta será utilizable de nuevo a medianoche.";
	static var BUY_CARD = "comprar una carta";
	static var BUY = "comprar";
	
	static var SUCCESS = "Cumplida";
	static var FRUIT_UNKNOWN = "fruta desconocida";

	static var FRUIT_TAGS = ["dulce", "roja", "hoja", "mini", "nuez", "flor", "cítrico", "verde", "liana", "alien", "baya", "larga", "calabaza", "pera", "azul","manzana","caca","naranja", "amarillo", "rosa" ];
	
	static var CONTROL = "Controles";
	static var CHOOSE_CONTROL = "Elige tu modo de desplazamiento:";
	static var CONTROL_NAMES = ["Ratón","Teclado A","Teclado B"];
	static var DESC_CONTROL = [
			"La serpiente sigue al puntero del "+white("ratón")+". Utiliza el "+white("clic izquierdo")+" para acelerar.",
			"Flecha "+white("arriba, abajo, izquierda")+" y "+white("derecha")+" para dirigir a la serpiente.\n"+white("Barra espaciadora")+" para acelerar.",
			"Flechas "+white("izquierda")+" y "+white("derecha")+" para hacer girar la serpiente.\nFlecha "+white("arriba")+" para acelerar.",
			white("Concéntrate")+" en un punto de la arena para que la serpiente se dirija hacia él.\nPara acelerar, concéntrate"+white("más fuerte")+".",
	];
	static var PAUSE_TITLE = 	"Juego en pausa";
	static var PAUSE_OFF = 		"Retomar";
	static var GORE = 			"Sangre";
	static var YES = 			"Sí";
	static var NO = 			"No";
	static var QUIT = 			"Salir";
	static var OPTIONS = 		"Opciones";
	
	static var STATS = ["Tiempo de juego", "Frutas recogidas", "Frutibarra max.", "Largo max."];
	static var SECTION_FRIENDS = "Mis amigos";
	static var SECTION_ARCHIVE = "Mis archivos";
	static var SECTION_TOP = "Panteón";
	static var SECTION_DRAFT = "Mi torneo";

	static var SECTION_RAINBOW = "Top Arco iris";
	static var DRAFT_CHOOSE = "Elige una carta" ;
	static var CNX_IMPOSSIBLE = "Conexión imposible";
	static var CNX_TRY = "Prueba";

	// NEW
	static var LOADING = "Cargando...";
	static var ENCYLOPEFRUIT_PROGRESSION = "Progreso en la Enciclofruta";
	static var BONUS = "Bonus";
	static var PLAY_AGAIN = "Volver a jugar";
	static var LENGTH_UNIT = "cm";
	static var TRAINING_GAME = "Partida de prueba";
	static var TRAINING_INSTRUCTION = "Aprende a dominar a la serpiente con esta partida.\nPuedes cambiar los controles al final de cada partida.";
	
	static var CAL_UNIT = "calorias";
	static var WEIGHT_UNIT = "mg";
	static var FRUIT_PROPS = ["puntos", "vitaminas", "nutricion", "conservacion"];
	static var TIME_UNIT = "seg.";
	
	static var CARD_PRICE = "Precio de una carta: ";
	static var DRAW = "Sorteo en curso...";
	static var CARD_ADDED = "Carta agregada a tu colección";
	static var NOT_ENOUGH_TOKEN = "¡No tienes suficientes fichas!";
	
	static var TIME_INTERVAL = ["Esta semana", "Este mes", "Este año"];
	
	// COLLECTIONS
	static var PAGE = "página";
	static var CARDS = "cartas";
	static var COMPLETION = "fin";
	static var COLLECTION_SECTIONS = ["Colección","Tienda","Tómbola","Bazar"];
	static var LOTTERY_DESC = "Cada medianoche, la carta del día es sorteada entre todos los participantes en la lotería. ";
	static var YESTERDAY_WINNER = "Ganador de ayer: ";
	static var COLLECTION_TITLE_SHOP = 		"LA TIENDA DE SERPENTIN";
	static var COLLECTION_TITLE_LOTTERY = 	"LA TOMBOLA DE LOTERINA";
	static var COLLECTION_TITLE_BAZAR = 	"EL BAZAR DE MEFISTOF";
	static var SHOP_ITEMS = ["Carta suplementaria", "Baraja de 10x cartas", "Billete de lotería"];
	static var SHOP_DESC = [
		"La carta es echada al azar:\n- carta común: 60%\n- carta normal: 30%\n- carta rara: 10%",
		"Baraja de 10 cartas echadas al azar :\n -6x cartas comunes\n- 3x cartas normales\n- 1x carta rara",
		"¡Un billete de lotería por la carta del día!\nEl sorteo es esta medianoche...",
	];
	static var DAILY_CARD = "CARTA DEL DIA:";
	static var LOTTERY_STATS = ["Compraste:", "Billetes vendidos:", "Probabil. de ganar:"];
	
	static var PLAY = "Jugar";
	static var GAME_WILL_START = "La partida comenzará en";
	static var SECONDES = "segundos";
	static var START = "¡Comenzar!";
	
	static var BAZAR_OFFER = [
		"Me interesa tu carta %1... Te doy %2 fichas. ¿Qué te parece?",
		"Realmente necesito tu carta %1, es una carta %3, ¡Te ofrezco %2 fichas!",
		"Te doy %2 fichas por tu carta %1. ¿Qué dices, aceptas?",
		"Te puedo dar %2 fichas a cambio de tu carta %1. ¿Vale?",
		"Para completar un super combo con %4 y %5 me falta sólo %1, ¿Me la cambias por %2 fichas?",
		"¡¡Oyeeee tienes %1!! Si quieres te doy %2 fichas a cambio. ¡Di que sí!",
		"Pffff... Mira, a parte de %1, no veo nada que me interese... ¿Me la vendes por %2 fichas?",
	];
	static var BAZAR_RAISE = [
		"¡Gggrr! Bueno, %2 fichas, ¡pero es mi última palabra!",
		"¡Pero qué tacaño! De acuerdo, ¡%2 fichas!",
		"¿Quééé? ¿Pero es sólo una carta %3! Tsss.. Bueno, ok, por %2 fichas...",
	];
	static var BAZAR_STAY = [
		"¡No, de ninguna manera! Son %2 fichas, ¡lo tomas o lo dejas!",
		"%2 fichas por esta carta, no encontrarás nada mejor. Ni pienses que cambiaré mi oferta.",
		"¡No, no y no!, te hago un favor liberándote de %1 entonces es %2 o nada!",
		"Llegaré a encontrar una carta %1 por %2 fichas en otro lado, ¿sabes?... ",
		"Nunca daré más de %2 fichas por una %3",
		"Bah, me gustaría pero no tengo más que %2 fichas conmigo...",
	];
	static var BAZAR_NEXT = [
		"¿Quieres tomarme el pelo? ¿Por esta carta? Olvídalo...",
		"Bueno, creo que no llegaremos a un acuerdo por esta carta...",
		"No pagaré más por %1, ¡pasemos a otra cosa!",
		"Bueno, creo que voy a guardar mi dinerillo para otra carta...",
		"Qué lástima, veamos qué pasa después...",
	];
	static var BAZAR_GIVE_UP = [
		"¡No pasa nada!",
		"Lástima.",
		"Bueno, si la necesitas...",
		"No importa, yo sé donde encontrar una.",
		"¡Como quieras!",
		"¡Es tu problema!",
		"Grrr, nunca lograré encontrar una...",
	];
	static var BAZAR_QUIT = [
		"Bueno, no hay modo de hacer negocios contigo, ¡me voy!",
		"Ok, creo que puedo encontrar un vendedor menos tacaño.",
		"No tengo suficientes fichas, lo siento...",
		"Creo que me llaman, ¡hasta pronto!",
		"Bueno,  volveré otro día. Ojalá seas más simpático...",
		"Estoy pasando por un 'shhhhh' túnel, no te oigo, 'sshhh' hablamos otro día 'sssshhhhh'"
	];
	static var BAZAR_FINISH = [
		"No hay nada que me interese en este momento...",
		"Bueno a parte de esa, no hay cartas de tu colección que me interesen.",
	];
	static var BAZAR_DEAL = [
		"¡¡Genial!! ¡la busqué por más de 3 días!",
		"¡Gracias!",
		"¡Estupendo!",
		"¡Muchísimas gracias!",
		"¡Es un placer hacer negocios contigo!",
	];
	
	static var BAZAR_NO = [ "Me la quedo", "¡No!", "Primero muerto", "Nunca!", "No, gracias"];
	static var BAZAR_UP = [ "No es suficiente", "¡Más fichas!", "Un esfuerzo más", "Está casi regalado","Un poco más, vamos." ];
	static var BAZAR_YES = [ "¡Acepto!", "¡Ok!", "¡Hecho!" ];
	
	static var BAZAR_CHOICES = ["Me la quedo", "Cuesta más", "Acepto" ];
	static var BAZAR_NO_ENTER = "¡Necesitas por lo menos " + col("%1","#FF6666") + " cartas para entrar al bazar!";
	static var BAZAR_END = "¡Mefistof se fue! Si está de buen humor, tal vez vuelva mañana para comprarte nuevas cartas.";
	static var FREQ = ["común", "normal", "rara"];
	
	
	// DRAFT
	static var DRAFT_DESC_CLOSE = "Cada día, iniciamos torneos de %1 jugadores entre las %2 horas y %3 horas.\n\nActualmente el torneo está  "+ col("cerrado", WHITE) + ". Próximo torneo en %4 ";
	static var DRAFT_DESC_OPEN = "Las inscripciones para el torneo están abiertas durante %1.\n¡Quedan aún %2 lugar(es) libre(s)!";
	static var DRAFT_SUBSCRIBE_ERROR = ["¡Tu inscripción no ha sido aceptada!", "No tienes suficientes fichas.", "Ya no hay espacio en este torneo."];
	
	static var DRAFT_RULES = white("Reglas del torneo")+": Cada jugador recibe "+pink("10 nuevas cartas")+", escoge "+pink("una")+" y pasa la baraja a su vecino. Repetimos esta operación hasta agotar las cartas. Cada uno juega las partidas que pueda con las 10 cartas elegidas, y "+pink("el score más alto")+" gana el torneo.\nUna partida de torneo puede contener entre "+green("1")+" y "+green("6 puntos")+" de karma.\nTodos se quedan con sus 10 cartas y los 3 mejores reciben un premio.";
	static var DRAFT_TEASING = "Los torneos están abiertos  todos los días entre %1h y %2h --- Las 10 cartas seleccionadas en un torneo irán a tu colección --- En un torneo una partida puede ser lanzada con sólo un punto de karma --- Ve las partidas de tu torneo en la sección de clasificación --- ";
	static var DRAFT_CARD_NOT_AVAILABLE = "Esta carta no puede ser utilizada en el torneo.";
	static var DRAFT_LEFT_TIME = "Tiempo restante" ;
	static var SERVER_CONNECT = "Conectando con el servidor...";
	static var WAITING_FOR_PLAYER = "Esperando a un jugador: ";
	static var PLEASE_WAIT = "Espera un instante...";
	static var WAITING_NEW_PLAYERS = "A la espera de %1 jugador(es) más";
	static var ABORT = "¡El torneo ha sido " + red("anulado") + "!\n" + green("(Esto un escándalo)") + "\nTus " + Data.DRAFT_COST + " fichas te serán devueltas.";
	static var DISCONNECT = "Estás desconectado.\nNo hay problema, puedes ingresar de nuevo a un torneo:";
	static var RECONNECT = "Reconectar";
	static var CANT_CONNECT = "Imposible de conectarse al servidor. Por favor inténtalo en unos minutos.";
	static var PRIZES = "Premios";
	static var POS = ["1ro.", "2do.", "3ro."];
	
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
