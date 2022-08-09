package mt.bumdum9;


//import mt.bumdum9.Lib;
//import mt.bumdum9.Phys;

private typedef WeightListSlot<T> = { we:Int, max:Int, type:T };

class WeightList<T> {//}

	var list : Array<WeightListSlot<T>>;
	var sum:Int;
	public var rnd:Int->Int;
	public var filters:Array < T->Bool > ;
	
	public function new(?seed:mt.Rand){

		list = [];
		filters = [];
		sum = 0;
		rnd = Std.random;
		if( seed != null ) rnd = seed.random;
	}


	public function add(t:T,weight=8,max=0){
		list.push( { type: t, we:weight, max:max } );
		sum += weight;
	}
	
	public function remove(o:WeightListSlot<T>) {
		sum -= o.we;
		list.remove(o);
	}
	
	public function getRandom() {
		
		var tot = sum;
		var a = list;
		
		// FILTERS
		if( filters.length > 0 ) {
			a = [];
			tot = 0;
			for( o in list ) {
				var ok = true;
				for( f in filters )	ok = ok && f(o.type);
				if( ok ) {
					a.push(o);
					tot += o.we;
				}
			}
		}
		
		// TEST
		var k = rnd(tot);
		var cur  = 0;
		for( o in a ) {
			cur += o.we;
			if( cur > k ) {
				if( --o.max == 0 ) remove(o);
				return o.type;
			}
		}
		throw("ERROR : weight list result = null ( elements:"+a.length+", sum:"+tot+" )" );
		return null;
	}



//{
}

