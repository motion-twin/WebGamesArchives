package mt.gx;

@:publicFields
class Quantic {
	
	var start:Date;
	var end:Date;
	var every_s:Int;//in ms
	var security: Int;
	
	/**
	 * @param l start call date 
	 * @param c current call date 
	 * @param e interval should be multiple of 1000 because neko doesn't have a better precision
	 */
	function new(start:Date,end:Date,e:Int, ?sec=128)
	{
		#if neko
		if ( e % 1000 != 0 )
			throw "impossible to go below second precision on neko :"+e;
		#end
		this.start = start; this.end = end; every_s = e; security = sec;
		mt.gx.Debug.assert( start.getTime() <= end.getTime() );
	}
	
	inline function step()		return every_s;
	
	/**
	 * @return date of the previous tick before last
	 */
	function firstTick() : Date{
		if ( start.getTime() % step() == 0 )
			return start;
		else {
			var ldt = start.getTime() + step();
			var mod = MathEx.posModF(start.getTime(), step());
			ldt -= mod;
			return Date.fromTime( ldt );
		}
	}
	
	//this is inclusive
	function lastTick() : Date{
		if ( end.getTime() % step() == 0 )
			return end;
		else {
			var ldt = end.getTime();
			var mod = MathEx.posModF(end.getTime(), step());
			ldt -= mod;
			return Date.fromTime( ldt );
		}
	}
	
	function tick( tick : Date -> Void)
	{
		var lcur = firstTick();
		var s = 0;
		while( lcur.getTime() <= end.getTime() )
		{
			tick(lcur);
			lcur = Date.fromTime(lcur.getTime()+every_s);
			s++;
			if ( s > security)
				mt.gx.Debug.brk("quantic security overflow");
		}
	}
	
	inline function nbTicksSlow()
	{
		var nb = 0;
		tick( inline function(_) nb++ );
		return nb;
	}
	
	inline function nbTicks() {
		return nbTicksFast();
	}
	
	inline function nbTicksFast(){
		var end = lastTick().getTime() + step();
		var interval : Int = Math.floor(end - firstTick().getTime());
		if ( interval <= 0 ) return 0;
		if ( interval % step() == 0)
			return Std.int( interval / step());
		else	
			return 1+Std.int( interval / step());
	}
}