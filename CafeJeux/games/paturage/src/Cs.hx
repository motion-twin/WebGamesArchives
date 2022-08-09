

class Cs {//}

	static public var mcw = 300;
	static public var mch = 300;

	static public var DIR = [[1,0],[0,1],[-1,0],[0,-1]];

	// GFX VALUE
	static public var MARGIN_TOP = 0.0;
	static public var MARGIN_LEFT = 0.0;
	static public var SIZE = 50;
	static public var COLORS = [0x00CC00,0x8800AA];

	// GAMEPLAY VALUE
	static public var GSIZE = 5;
	static public var HERB_MAX = 2;


	// COMPUTED VALUE
	static public function init(){
		MARGIN_LEFT =  (Cs.mcw - GSIZE *SIZE)*0.5;
		MARGIN_TOP = (Cs.mch - GSIZE *SIZE)*0.5;
	}

	static public function getX(px:Float){
		return MARGIN_LEFT + px*SIZE;
	}
	static public function getY(py:Float){
		return MARGIN_TOP + py*SIZE;
	}

//{
}
