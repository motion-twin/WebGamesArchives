import mb2.Manager;

class mb2.TItems {

	static var TITEMS = [
		"$c1or","$c1argent","$c1", // jaune
		"$c2or","$c2argent","$c2", // verte
		"$c3or","$c3argent","$c3", // rouge
		"$c4or","$c4argent","$c4", // orange
		"$c5or","$c5argent","$c5", // bleue
		"$c6or","$c6argent","$c6", // metal
		"$c7or","$c7argent","$c7", // violette
		"$bfacettes",
		"$bnormal","$btime","$bdeath","$bmagnet","$bshadow",
		"$oeil","$masque",
		// 0 : eau
		// 1 : feu
		// 2 : air
		// 3 : terre
		"$eca0","$eca1","$eca2","$eca3",
		"$symb0","$symb1","$symb2","$symb3"
	];

	static var TITEMS_COURSE = 0;
	static var TITEM_CLASSIC = 21;
	static var TITEMS_END = 22;
	static var TITEMS_SERPENT = 29;
	static var TITEMS_SYMBOL = 33;

	static function giveCourse(cnb,inb) {
		var t = 0;
		if( giveItem(TITEMS_COURSE + inb + cnb * 3) )
			t++;
		if( inb < 2 )
			t += giveCourse(cnb,inb+1);
		return t;
	}

	static function giveClassic(lvl) {
		if( lvl < 40 )
			return false;
		return giveItem(TITEM_CLASSIC);
	}

	static function giveAventure(av) {
		if( av < 4 ) {
			if( giveItem(TITEMS_SYMBOL + av) )
				return true;
			return giveItem(TITEMS_SERPENT + av);
		} else {
			var ntry = 100;
			while( ntry-- > 0 ) {
				if( giveItem(TITEMS_END+random(7)) )
					return true;
			}
			return false;
		}
	}

	private static function giveItem(i) {
		var fc = Manager.client.fcard.$items;
		if( fc[i] || TITEMS[i] == "" )
			return false;
		fc[i] = true;
		Manager.client.giveItem(TITEMS[i]);
		Manager.client.saveSlot(0);
		return true;
	}

}