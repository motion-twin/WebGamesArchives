package ;

/**
 * ...
 * @author de
 */

class IsoConst
{
	public static inline var EDITOR :Bool = #if editor true #else false #end;
	public static inline var WALK : Bool = true;
	
	public static inline var BG_PRIO : Int = 10;
	public static inline var DECAL_PRIO : Int = 5;
	public static inline var CHAR_PRIO : Int = 0;
	public static inline var FX_PRIO : Int = -10;

	public static inline var BG_ANIM  = true;
}