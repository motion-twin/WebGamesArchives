package ;

/**
 * ...
 * @author de
 */

class BitArray
{
	public var data : Array<Int>;
	
	public static inline function bitSet( _v : Int , _i : Int) : Int 						return _v | _i;
	public static inline function bitIs( _v : Int , _i : Int) : Bool						return  (_v & _i) == _i;
	public static inline function bitClear( _v : Int, _i : Int) : Int 						return (_v & ~_i);
	public static inline function bitNeg(  _i : Int) : Int									return ~_i;
	public static inline function bitToggle( _v : Int , _onoff : Bool, _i : Int) : Int 		return 	_onoff ? bitSet(_v,  _i) : bitClear(_v, _i);
	
	public function new()
	{
		data =  new	Array<Int>();
	}
	
	public function rawData() return data;
	public inline function rawFill( a : Array<Int> ) 
	{
		clear();
		for ( i in 0...a.length)
			data[i] = a[i];
	}
	
	public inline function fill(v : Bool)
	{
		if ( v == false )
			clear();
		else
		for( i in 0...data.length )
			data[i] = 0xFFFF;
	}
	
	public function copy(v : BitArray)
	{
		clear();
		
		for( i in 0...v.data.length )
		{
			data[i] = v.data[i];
		}
	}
	
	public inline function clear()
	{
		data = [];
	}
	
	public inline function set( i : Int , v : Bool)
	{
		var cell = i >> 4;
		
		#if !flash
		if (data[cell] == null) data[cell] = 0;
		#end
		
		data[cell] = bitToggle( data[cell], v, 1 << (i & 0xF));
	}
	
	inline public function has( i : Int )  : Bool
	{
		return get(i);
	}
	
	inline public function get( i : Int )  : Bool
	{
		var cell = i >> 4;
		
		#if !flash
		if (data[cell] == null)
		{
			data[cell] = 0;
			return false;
		}
		else
		#end
		
		return bitIs( data[cell], 1 << (i & 0xF));
	}

	
	
	public static function unitTest()
	{
		#if debug
		var ba = new BitArray();
		
		ba.fill(false);
		ba.set( 1 ,true);
		ba.set( 15 ,true);
		ba.set( 18 , true);
		
		ba.set( 31 , true);
		ba.set( 32 , true);
		
		ba.set( 43 , true);
		
		Debug.ASSERT( ba.get(1) );
		Debug.ASSERT( ba.get(15) );
		Debug.ASSERT( ba.get(18) );
		Debug.ASSERT( ba.get(31) );
		Debug.ASSERT( ba.get(32) );
		Debug.ASSERT( ba.get(43) );
		
		Debug.ASSERT( !ba.get(42) );
		Debug.ASSERT( !ba.get(0) );
		Debug.ASSERT( !ba.get(2) );
		Debug.ASSERT( !ba.get(3) );
		Debug.ASSERT( !ba.get(16) );
		Debug.ASSERT( !ba.get(14) );
		
		ba.fill(false);
		Debug.ASSERT( !ba.get(0) );
		Debug.ASSERT( !ba.get(1) );
		
		ba.fill(false);
		ba.set(3,true);
		ba.set(163,true);
		ba.set(164,true);
		Debug.ASSERT( ba.get(3) );
		Debug.ASSERT( ba.get(163) );
		Debug.ASSERT( ba.get(165) );
		#end
	}
	
}