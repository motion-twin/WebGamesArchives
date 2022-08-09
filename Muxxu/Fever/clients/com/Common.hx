import Protocole;
#if flash
import mt.bumdum9.Lib;
#end

class Common implements haxe.Public {//}
	

	// Permet de savoir si l'obtention du reward nécéssite la dépense d'une clé.
	static public function isChest(rew:_Reward) {
		if( rew == null ) 		return false;
		switch(rew) {
			case Item(item):		return true;
			case IBonus(b) :		return true;
			case IceBig :			return true;
			case Heart :			return true;
			case Cartridge(id) :	return true;
			default:				return false;
		}
	}
	
	//
	public static function majScore(data:_DataRankInfo) {
		var score = 0;
		score += data._wid * 20000;
		score += data._frags;
		score += data._isl_visited * 2;
		score += data._isl_done * 5;
		score += data._carts * 10;
		score += data._statues * 100;
		for( it in data._items ) {
			switch(it) {
				case Rune_0, Rune_1, Rune_2, Rune_3, Rune_4, Rune_5, Rune_6 :
					score += 500;
				default :
					score += 200;
							
			}
		}
		data._score = score;
	}
		
	// POUR LE SERVEUR UNIQUEMENT
	//#if neko
	static public function getWorldData(wid) {
		
		var data = new WorldData(wid);
		data.init() ;
		while( !data.ready ) data.update();
		var portal = data.rooms[ Std.int(data.rooms.length * WorldData.COEF_PORTAL) ];
		return {size : data.size, limits : data.getLimits(), portal:{x:portal.x,y:portal.y}} ;
	}
//	#end
	

	
	
//{
}
