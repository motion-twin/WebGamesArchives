package mt.gx;

/**
 * ...
 * @author de
 */

class BitArray{
	public var data : Array<Int>;
	
	//#if haxe3
	public static inline var BIT_WIDTH = 32;
	public static inline var BIT_SHIFT = 5;
	public static inline var BIT_MASK = BIT_WIDTH-1; 
	
	public static inline function bitSet( _v : Int , _i : Int) : Int 						return _v | _i;
	public static inline function bitIs( _v : Int , _i : Int) : Bool						return  (_v & _i) == _i;
	public static inline function bitClear( _v : Int, _i : Int) : Int 						return (_v & ~_i);
	public static inline function bitNeg(  _i : Int) : Int									return ~_i;
	public static inline function bitToggle( _v : Int , _onoff : Bool, _i : Int) : Int 		return 	_onoff ? bitSet(_v,  _i) : bitClear(_v, _i);
	
	public inline function new(){
		data =  new	Array<Int>();
	}
	
	public inline function rawData() return data;
	public inline function rawFill( a : Array<Int> ){
		clear();
		for ( i in 0...a.length)
			data[i] = a[i];
	}
	
	public inline function fill(v : Bool){
		if ( v == false )
			clear();
		else
		for( i in 0...data.length )
			data[i] = 0xFFffFFff;
	}
	
	public function copy(v : BitArray) {
		if( data.length > v.data.length ) 
			data.splice( data.length -1 , v.data.length - data.length );
		
		for( i in 0...v.data.length )
			data[i] = v.data[i];
	}
	
	public inline function clear(){
		data = [];
	}
	
	public inline function set( i : Int , v : Bool = true){
		var cell = i >> BIT_SHIFT;
		
		#if ((!flash)&&(!cpp))
		if (data[cell] == null) data[cell] = 0;
		#end
		
		data[cell] = bitToggle( data[cell], v, 1 << (i & BIT_MASK ));
	}
	
	inline public function has( i : Int )  : Bool{
		return get(i);
	}
	
	inline public function get( i : Int )  : Bool{
		var cell = i >> BIT_SHIFT;
		
		#if ((!flash)&&(!cpp))
		if (data[cell] == null)
		{
			data[cell] = 0;
			return false;
		}
		else
		#end
		
		return bitIs( data[cell], 1 << (i & BIT_MASK ));
	}

	public static function test(){
		#if debug
		function assrt(a) mt.gx.Debug.assert(a);
		var ba = new BitArray();
		
		ba.fill(false);
		ba.set( 1 ,true);
		ba.set( 15 ,true);
		ba.set( 18 , true);
		
		ba.set( 31 , true);
		ba.set( 32 , true);
		
		ba.set( 43 , true);
		
		ba.set( 1024 , true);
		
		assrt( ba.get(1) );
		assrt( ba.get(15) );
		assrt( ba.get(18) );
		assrt( ba.get(31) );
		assrt( ba.get(32) );
		assrt( ba.get(43) );
		assrt( ba.get(1024) );
		
		assrt( !ba.get(42) );
		assrt( !ba.get(0) );
		assrt( !ba.get(2) );
		assrt( !ba.get(3) );
		assrt( !ba.get(16) );
		assrt( !ba.get(14) );
		assrt( !ba.get(1025) );
		
		ba.fill(false);
		assrt( !ba.get(0) );
		assrt( !ba.get(1) );
		
		ba.fill(false);
		ba.set(3,true);
		ba.set(163,true);
		ba.set(164,true);
		assrt( ba.get(3) );
		assrt( ba.get(163) );
		assrt( ba.get(164) );
		assrt( !ba.get(165) );
		#end
	}
	
}