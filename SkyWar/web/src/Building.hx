import Datas;

class Building {
	public var kind : _Bld;
	public var x : Int;
	public var y : Int;
	public var life : Int;
	public var progress : Float;

	public var logic(getLogic,null) : BuildingLogic;

	public function new(k:_Bld, x:Int, y:Int, damages:Int, yardProgress:Float=1.0){
		this.kind = k;
		this.x = x;
		this.y = y;
		this.life = Std.int(Math.max(1, logic.life*yardProgress - damages));
		this.progress = yardProgress;
	}

	public function isYard() : Bool {
		return progress != null && progress < 1.0;
	}

	function getLogic() : BuildingLogic {
		return BuildingLogic.get(kind);
	}
}
