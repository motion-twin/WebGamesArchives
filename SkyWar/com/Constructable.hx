import Datas;

typedef Cost = {
	var material : Int;
	var cloth : Int;
	var ether : Int;
	var population : Int;
}

class Constructable {
	public var life : Int;
	public var cost : Cost;

	public function getBuildTime() : Float {
		return life * GamePlay.TIME_FACTOR;
	}

	public function getIsleBuildTime( b:List<_Bld>, t:List<_Tec> ) : Float {
		return getBuildTime();
	}

	#if neko
	public function canBuild( i:db.Isle ) : Bool {
		return false;
	}
	#end
}
