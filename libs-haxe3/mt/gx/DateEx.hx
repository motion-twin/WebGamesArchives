package mt.gx;

/**
 * ...
 * @author de
 */

class DateEx
{

	public static function cmp(d1:Date, d2:Date)  : Int
	{
		return Std.int(d2.getTime() - d1.getTime());
	}
		
	public static function lt(d1:Date,d2:Date)  : Bool
	{	return d1.toString() < d2.toString() ; }
	
	public static function gt(d1:Date,d2:Date)  : Bool
	{	return d1.toString() < d2.toString() ; }
	
	public static function eq(d1:Date,d2:Date)  : Bool
	{	return d1.toString() == d2.toString() ; }
	
	public static function diff(d1:Date,d2:Date)  : Float
	{	return d1.getTime() - d2.getTime() ; }
	
	public static function diffHours(d1:Date,d2:Date)  : Float
	{	return (d1.getTime() - d2.getTime()) / (3600 * 1000) ; }
	
	public static function diffSeconds(d1:Date,d2:Date)  : Float
	{	return (d1.getTime() - d2.getTime()) / 1000 ; }
	
	public static function toSec(d : Date) : Float
	{	return d.getTime() * 0.001 ; }
	
	public static inline function addSeconds( d : Date,t : Float )  : Date
	{	return Date.fromTime( d.getTime() + DateTools.seconds( t ) ); }
		
	public static inline function addMins( d : Date,t : Float )  : Date
	{	return Date.fromTime( d.getTime() + DateTools.minutes( t ) ); }
	
	public static function addHours( date : Date, t : Float )  : Date
	{	return  Date.fromTime( date.getTime() + DateTools.hours( t ) ); }
		
	public static function addDays( d : Date,t : Float )  : Date
	{	return Date.fromTime( d.getTime() + DateTools.days( t ) ); }
	
	
	public static function round( d : Date, secSlice : Float)
	{
		var secs = d.getHours()  * 3600 + d.getMinutes() * 60 + d.getSeconds();
		var nb : Int = Std.int( Std.int(secs / secSlice) * secSlice );
		
		var remHrs = Std.int(nb / 3600);
		nb -= remHrs * 3600;
		var remMin = Std.int(nb / 60);
		nb -= remMin * 60;
		var remSec = nb;
		
		return new Date( 	d.getFullYear(), d.getMonth(), 
							d.getDate(), Std.int(remHrs), Std.int(remMin), Std.int(remSec));
	}
}