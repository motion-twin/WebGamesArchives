package exp;
import ExploreProtocol;

class Lang {
	static var h : Hash<String> = new Hash();
	
	public static function init( infos : ExploreInfos ) {
		h = infos.texts;
	}
	
	public static inline function get(k) {
		if( !h.exists(k) )
			return "%"+k+"%";
		else
			return h.get(k);
	}
}