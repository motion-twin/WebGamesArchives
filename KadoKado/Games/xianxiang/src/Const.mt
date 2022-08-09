class Const {

	static var LVL_WIDTH = 6;
	static var LVL_HEIGHT = 7;

	static var BASE_X = 23 ;
	static var BASE_Y = 20 ;
	static var CARD_WIDTH = 43 ;
	static var CARD_HEIGHT = 34 ;

    static var auto = 0 ;
	static var PLAN_BG = auto++;
	static var PLAN_CARD = auto++;
	static var PLAN_PATH = auto++;
	static var PLAN_MATCH = auto++;
	static var PLAN_FX = auto++;

	static var NTURNS = 1;

    static var COLOR_ALPHA = 100 ;

	static var POINTS_ENCODE = KKApi.aconst([1,50,300,1000]);

	static var COLORS = [
		{
			r : 100,
			g : 50,
			b : 0
		},
		{
			r : 0,
			g : 100,
			b : 0
		},
		{
			r : 0,
			g : 0,
			b : 100
		},
		{
			r : 75,
			g : 50,
			b : 100
		}
	]
}
