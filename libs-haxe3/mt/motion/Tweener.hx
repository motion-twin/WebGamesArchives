package mt.motion;
import mt.motion.Tween;
using mt.Std;
/**
 *  Documentation https://bible.motion-twin.com/dev/libs
 */
class Tweener
{
	//public var active(get, null):Int;
	//inline function get_active() { return mTweens.length; }
	
	public function print()
	{
		trace("count = " + mTweens.length);
		for ( t in mTweens )
		{
			trace("t.active = " + (!t.disposed));
		}
	}
	var mTweens: List<Tween>;
	public function new()
	{
		mTweens = new List();
	}
	
	public function clean()
	{
		dispose();
		mTweens = new List();
	}
	
	public function dispose()
	{
		if( mTweens != null )
			for( t in mTweens )
				t.dispose();
		mTweens = null;
	}
	
	public function update()
	{
		if( mTweens != null )
			for( t in mTweens )
				t.update();
	}
	
	public function pause():Void
	{
		if( mTweens != null )
			for( t in mTweens )
				t.pause();
	}
	
	public function resume():Void
	{
		if( mTweens != null )
			for( t in mTweens )
				t.resume();
	}
	
	public function remove(p_tween:Tween)
	{
		mTweens.remove(p_tween);
	}
	
	//TODO fix the poool
	public function create(?p_autoStart:Bool):Tween
	{
		if ( mTweens == null ) throw "invalid tween request";
		
		var t = new Tween( p_autoStart );
		t.tweener = this;
		mTweens.add(t);
		return t;
	}
}
