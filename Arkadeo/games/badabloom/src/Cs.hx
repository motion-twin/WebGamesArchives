package ;

class Cs
{
	public static var VIEW_WIDTH = 600;
	public static var VIEW_HEIGHT = 480;
	
	public static var WAIT_TIME = 80;
	
	public static var FPS = api.AKApi.const(30);
	public static var COMPLEX_COMBO = api.AKApi.const(5000);
	public static var SIMPLE_COMBO = api.AKApi.const(1000);
	
	public static var GRID_POINTS_COEF = api.AKApi.const( 100 );
	public static var LEAGUE_DURATION = api.AKApi.const(120 * FPS.get());//seconds
	
	public static var BONUS_TIME = api.AKApi.const(10 * FPS.get());//seconds
	public static var BONUS_POINTS = api.AKApi.const(2000);
	
	inline public static var MAX_LIVES = api.AKApi.const(7);
	
	inline public static var PADDING_TOP = 20;
	inline public static var PADDING_BOTTOM = 60;
}
