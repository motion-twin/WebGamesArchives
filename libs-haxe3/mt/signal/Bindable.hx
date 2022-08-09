package mt.signal;

class Bindable<T> implements Signaler2
{
	@:signal public var onChange:T-> Void;
	@:isVar public var value(get, set):Null<T>;
	
	public function new( p_value:T )
	{
		value = p_value;
	}
	
	inline function set_value(p_v:T):T
	{
		value = p_v;
		onChange.dispatch(value);
		return value;
	}
	
	inline function get_value():T
	{
		return value;
	}
	
	inline public function set(p_value:T)
	{
		value = p_value;
	}
	
	inline public function get():Null<T>
	{
		return value;
	}
}
