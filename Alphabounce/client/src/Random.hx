
class Random{//}

	var seed:Int;

	public function new(s){
		seed = s;
	}
	//
	public function rand(){
		//return Math.random();
		seed = Std.int(1664525.0 * seed + 1013904223.0) & 0x3FFFFFFF;
		return (seed%1000)/1000;
	}
	public function random(n){
		//return Std.random(n);
		seed = Std.int(1664525.0 * seed + 1013904223.0) & 0x3FFFFFFF;
		return seed%n;
	}

//{
}













