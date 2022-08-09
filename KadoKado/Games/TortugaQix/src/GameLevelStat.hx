import KKApi;

typedef StatZone = { size:Int, nSlow:Int, nFast:Int, value:Int };

class GameLevelStat {
	public var slow : mt.flash.Volatile<Int>;
	public var fast : mt.flash.Volatile<Int>;
	public var empty : mt.flash.Volatile<Int>;
	public var n : mt.flash.Volatile<Int>;
	public var pcent : mt.flash.Volatile<Float>;
	public var goal : mt.flash.Volatile<Float>;
	public var list : List<StatZone>;
	public var lastZone : StatZone;
	public var score : mt.flash.Volatile<Float>;

	public function new(){
		slow = 0;
		fast = 0;
		empty = 0;
		n = 0;
		pcent = 0.0;
		goal = 0.0;
		score = 0.0;
		list = new List();
	}

	public function update( newSlow:Int, newFast:Int, newEmpty:Int, newTotal:Int, goal:Float ){
		this.goal = goal;
		n = newTotal;
		if (newSlow != slow || newFast != fast){
			lastZone = {
				size: empty-newEmpty,
				nSlow: newSlow-slow,
				nFast: newFast-fast,
				value: 0
			};
			lastZone.value =
				Math.round(
					lastZone.nSlow*lastZone.nSlow*0.002
					+ lastZone.nFast*lastZone.nFast*0.001
				);
			list.push(lastZone);
			score += lastZone.value;
		}
		empty = newEmpty;
		slow = newSlow;
		fast = newFast;
		pcent = (n == 0) ? 0.0 : Math.round(((n-empty) / n ) * 1000) / 10;
	}
}