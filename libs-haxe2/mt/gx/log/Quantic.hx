package mt.gx.log;

class Quantic
{
	public var last:Date;
	public var cur:Date;
	public var every_s:Int;//in seconds
	public var security: Int;
	
	//last call date / current call date / every e second
	public function new(l,c,e)
	{
		last = l; cur = c; every_s = e; security = 128;
		mt.gx.Debug.assert( l.getTime() <= cur.getTime(),"can't work that way last:"+l+" cur:"+c );
	}
	
	public inline function step()		return every_s * 1000
	
	public function lastTick() : Date
	{
		return DateTools.delta( nextTick(), - step() );
	}
	
	public function nextTick() : Date
	{
		var ldt = last.getTime()+ step();
		var mod = ldt % step();
		ldt -= mod;
		return Date.fromTime( ldt + step() );
	}
	
	public function tick( tick : Date -> Void)
	{
		var lcur = Date.fromTime( last.getTime() );
		var s = 0;
		while( lcur.getTime() + step() <= cur.getTime() )
		{
			var ldt = lcur.getTime() + step();
			var mod = ldt % step();
			ldt -= mod;
			var tickTime = Date.fromTime( ldt );
			mt.gx.Debug.assert( tickTime.getTime() >= this.last.getTime() - step());
			tick(tickTime);
			lcur = tickTime;
			s++;
			if ( s > security)
				mt.gx.Debug.brk("quantic security overflow");
		}
	}
	
//	public static var check = 0;
	public function nbTick()
	{
		var n = 0;
		//check = 0;
		
		mt.gx.Debug.assert( last != null);
		mt.gx.Debug.assert( cur != null);
		
		tick(function(_)
		{
			n++;
		});
		return n;
	}
}