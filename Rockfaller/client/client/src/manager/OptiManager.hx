package manager;

/**
 * ...
 * @author Tipyx
 */
class OptiManager
{
	public static var IS_WEB			: Bool;
	
	public static function INIT() {
	#if standalone
		IS_WEB = true;
	#else
		IS_WEB = false;
	#end
	}
}