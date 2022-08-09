
class CryptoEx {
	#if ((flash) || (neko))
	static inline function innScramble<A>( arr : Array<A>, r : mt.Rand ){
		for(x in 0...3 *( arr.length + r.random(arr.length)))
		{
			var b = r.random(arr.length);
			var a = r.random(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
		return arr;
	}
	
	//reindex and interlace
	public static inline function getIndex(seed, nb) : Array<Int>{
		var idx : Array<Int> = [for (i in 0...nb) i];
		var rd = new Rand(seed);
		rd.initSeed(0xdead + 0xbeef + seed - nb + 0x1337);
		innScramble( idx, rd );
		return idx;
	}
	
	public static inline function reindex(str:String,seed:Int){
		var idx = getIndex( seed,str.length );
		var s = new StringBuf();
		for ( i in 0...str.length)
			s.add( str.charAt(idx[i])  );
		return s;
	}
	
	public static inline function deindex(str,seed){
		var idx = getIndex( seed,str.length );
		var a = [];
		for ( i in 0...str.length ) {
			a[idx[i]] = str.charAt(i);
		}
		return a.join("");
	}
	#end
}
	