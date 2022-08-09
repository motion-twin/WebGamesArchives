import swapou2.Manager;
import swapou2.Data;

class swapou2.TItem {

	static var TITEMS = [
		"$sel","","$poivre","$epee","$piment","$dent","$sucre",
		"$metal01","$metal02","$metal03","$ice01","$ice02","$ice03","$star01","$star02","$star03",
		"$fruit01","$fruit02","$fruit03","$fruit04","$fruit05","$fruit06","$fruit07","$fruit08","$fruit09","$fruit10","$fruit11",
		"$combo01","$combo02","$combo03","$combo04","$combo05","$combo06","$combo07","$combo08","$combo09","$combo10","$combo11",
		"$photo01","$photo02","$photo03","$photo04","$photo05","$photo06","$photo07","$photo08"
	];

	public static var combo_nitems = 0;

	static var HISTO_TITEMS = 0;	
	static var HISTO_END_TITEMS = 7;
	static var FRUIT_TITEMS = 16;
	static var COMBO_TITEMS = 27;
	static var PHOTO_TITEMS = 38;

	static function histoItems() {		
		var n = 0;
		if( giveItem(HISTO_TITEMS + Data.histoPhase) )
			n++;
		if( Data.histoPhase == 6 ) {
			var ntrys = 100;
			while( ntrys-- > 0 ) {
				if( giveItem(HISTO_END_TITEMS+random(9)) ) {
					n++;
					break;
				}
			}
		}
		return n;
	}

	static function addCombo(n) {
		var ac = Std.cast(Manager.client.slots[0]).$combos;
		if( ac[n] == undefined )
			ac[n] = 0;
		ac[n]++;		
		if( ac != undefined ) {			
			if( ac[n] >= 5 && giveItem(COMBO_TITEMS+n) ) {
				combo_nitems++;
				Manager.client.saveSlot(0,undefined);
			} else if( ac[n] < 5 ) {
				Manager.client.saveSlot(0,undefined);
			}
		}
	}

	static function duelItem() {
		return giveItem(PHOTO_TITEMS + Data.players[1]) ? 1 : 0;
	}

	static function classicItems(level) {
		var n = 0;
		level = Math.min(level,11);
		while( level >= 0 ) {			
			if( giveItem(level+FRUIT_TITEMS) )
				n++;
			level--;
		}
		return n;
	}

	static function giveItem(i) {
		var fc = Std.cast(Manager.client.slots[0]).$items;
		if( fc[i] || TITEMS[i] == "" )
			return false;
		fc[i] = true;		
		Manager.client.giveItem(TITEMS[i]);
		Manager.client.saveSlot(0,undefined);
		return true;
	}

}