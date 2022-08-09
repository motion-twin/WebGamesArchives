

class Core {//}

	public var pop:Int;
	public var ind:Int;
	public var tra:Int;
	public var sec:Int;
	public var env:Int;
	public var com:Int;

	public var deb:Int;
	public var build:Array<Int>;



	public function new(){

	}

	public function getIncomes(){
		return  Std.int((pop*1.5 + ind*2.5 + com*4) *100);
	}


	// pop 50 -> industrie
	// pop 100 -> Transport
	// pop 500 -> Environemment
	// pop 500 -> Sécurité
	// pop 1000 -> Commerces

	// PRC
	public function getChomCoef(){
		var n = ((ind*3+com)+50) / pop;
		return 1-Math.min(n,1);
	}
	public function getRoadCoef(){
		var n = (tra*5+100) / pop;
		return  Math.min( n , 1 );
	}
	public function getPolCoef(){
		var n = ( (ind+pop*0.1+com*0.3) - (env*2+200) ) / ind;
		return Math.min(Math.max(0, n), 1 );
	}
	public function getCrimCoef(){
		var n = (sec*4+300) / pop;
		return 1- Math.min( n , 1 );
	}


//{
}
