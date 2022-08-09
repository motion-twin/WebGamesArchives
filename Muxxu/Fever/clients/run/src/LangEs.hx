
class LangEs implements haxe.Public {//}
	
	static var 	ITEM_NAMES  = [
		"Cóctel", "Libro de hechizos", "Zapatos", "Espejo", "Trébol", "Muñeco vudú", "Máscara tribal",
		"Varita",	"Anteojos", "Radar", "Prisma", "FeverX", "Paraguas", "Dado",
		"Molino de viento", "Helado químico", "Reloj de arena", "ChromaX", "Anillo mágico", "Tenedor encantado", "Hilo de Ariadna",
		"Runa Ini","Runa Sed","Runa Aarg","Runa Olh","Runa Al","Runa Laf","Runa Hep"
	];
	
	static var 	ITEM_DESC  = [
		"Disminuye en 10° la temperatura al inicio de la partida",
		"Anota el juego que quieres prohibir",
		"Duplica tu velocidad de desplazamiento",
		"Las medusas no pueden paralizarte",
		"Detecta los cartuchos de juego cercanos",
		"Los monstruos empiezan con un corazón menos",
		"Los monstruos tienen 2% de probabilidades de huir al inicio del combate",		// TODO
		
		"Abre los cofres verdes",
		"Revela la lista de juegos del monstruo más próximo",
		"Indica la posición de las islas descubiertas",
		"Transforma un cubo de hielo en tres\nArco Iris",
		"¡La famosa consola FeverX!",
		"+1 Arco Iris adicional cada día",
		"Haz "+col("1","#FF0000")+" para ganar un Cubo de Hielo \nCada intento cuesta un Arco Iris",
		
		"Cuando pierdes un duelo, la temperatura no sube",
		"+1 cubo de hielo adicional cada día",
		"+25% de tiempo en los juegos de reflexión",
		"La FeverX consume principalmente Arco Iris",
		"Los monstruos brutales te hacen un daño menos",
		"10% de probabilidades de romper 2 corazones en un ataque",
		"Te teleporta a la última estatua tocada por un Arco Iris",
		
		"Una piedra rara...",
		"Una piedra misteriosa...",
		"Una piedra enigmática...",
		"Una piedra desconocida...",
		"Una piedra oscura...",
		"Una piedra singular...",
		"Una piedra inquietante...",
	];
	
	static var BONUS_ISLAND_NAMES = [ "Fulgo", "Ignik", "Rasen" ];
	static var BONUS_ISLAND_DESC = [ "Destruye el monstruo más próximo", "Destruye todos los monstruos que se encuentran en la isla", "Destruye todos los monstruos en una línea" ];
	
	static var BONUS_GAME_NAMES = [ "Queso", "Volantín" , "Buril", ];
	static var BONUS_GAME_DESC = [
		grey("Toca "+pink("[C]")+" entre dos pruebas:")+"\nRecupera todos tus corazones",
		grey("Toca "+pink("[V]")+" durante una prueba:")+"\nHuye del minijuego en curso",
		grey("Toca "+pink("[B]")+" entre dos pruebas:")+"\nDaña al adversario"
	];
	static var BONUS_DAILY_NAMES = ["Reserva de Arco Iris","Reserva de cubos de hielo"];
	static var BONUS_DAILY_DESC = [
		"Consigue " +pink(BONUS_GAME_NAMES[0]) + ", un " + pink(BONUS_GAME_NAMES[1]) + " y un " + pink(BONUS_GAME_NAMES[2]) + " para recibir un Arco Iris adicional cada día.",
		"Consigue un " +pink(BONUS_ISLAND_NAMES[0])+", un "+pink(BONUS_ISLAND_NAMES[1])+" y un "+pink(BONUS_ISLAND_NAMES[2])+" para recibir un Cubo de Hielo adicional cada día.",
		"+1 Arco Iris adicional cada día",
		"+1 Cubo de Hielo adicional cada día",
	];
	
	static var GODS = [
		"Koan", "Barchenold", "Piluvian", "Dumerost",
		"Chankron", "Malvenel", "Lifolet", "Tarabluff",
		"Sidron", "Chomniber", "Pata", "Droenix",
		"Lancurno","Jomil","Tokepo","Grazuli",
	];
	static var BLESS = "El ojo de %1 de está cuidando de ti";
	
	// ----------------- //
	
	static var PERMANENT_OBJECT = 	"Objeto utilizado permanentemente";
	static var NO_MORE_ICECUBE = 	"¡Ya no tienes Cubos de Hielo!";
	static var NO_MORE_RAINBOW = 	"¡Ya no tienes Arco Iris!";
	static var NO_CARTRIDGE = 		"¡No hay cartuchos de juegos!";
	static var NO_STATUE = 			"¡Ninguna estatua descubierta!";
	static var TOO_MUCH_RAINBOW = 	"¡Ya tienes suficientes!";
	static var NEED_KEY = 			"¡Necesitas una llave!";
	static var NEED_WAND = 		"Necesitas una varita!";
	
	static var HEARTS_DESC  = [ "Recipiente cardíaco", "Espacio para corazones abandonados", "X cuartos de corazón", "Encuentra los cuartos de corazón faltantes para ganar 1 vida adicional"];

	// ----- //
	static var ENDING_TEXT = "Con la Gran Bakelita Sargon destruida, el portal dimensional se abre a Pousty.\nEl más valeroso de los pingüinos no le teme a nada. A pesar de las heridas de su último combate, está decidido a cruzar la misteriosa puerta...\n¡Un torbellino de colores envuelve a Pousty! Poco a poco, las energías refluyen. A unos metros, un camino le llevará hacia otro mundo. Un mundo parecido pero...\ntal vez más hostil. Nuestro palmípedo héroe siente la amenaza de Bakelita, y esta vez, ¡no será nada fácil!";

	static var ENDING_QUESTION =  "¿Deseas quedarte en el archipiélago de %1 para eliminar a tus últimos enemigos, o dar el gran salto para unirte a %2 en una nueva aventura?";
	static var ENDING_EXPLORE = "Retornar a %1";
	static var ENDING_LEAVE_TO = "Ir a %1";
	
	static var ARCHIPELS =  ["Gonkrome","Sultura","Baniflok","Grizantol","Marshukrev","Dishigan","Lavulite","Koleporsh","Murumuru","Frisantem","Zulebi"];
	
	static var GENERIC_ERROR = "Ha surgido un error. Por favor, vuelve a lanzar el juego." ;
	
	static var CREATE_WORLD = "Generando el mundo...";
	static var CHECK_INVENTORY = "Ver el inventario";
	static var BACK_TO_GAME = "Retornar al juego";
	static var ISLAND = "Isla";
	static var NO_MONSTER = "¡No hay monstruos a la vista!";
	static var FEVER_X_LABELS = ["Jugar","Etapa"];
	static var SELECT_STEP = "Selecciona\n  una etapa";
	static var SERVER_CNX = "Conexión al servidor...";
	
	
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


