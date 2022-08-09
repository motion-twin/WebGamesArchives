class Const {

	static var NUMCARDS = 10;
	static var MAXLIFE = 20;
	static var STARTLIFE = 10;


	static var LEVELS = [
		{ width : 4, height : 2 },
		{ width : 4, height : 3 },
		{ width : 4, height : 4 },
		{ width : 5, height : 4 },
		{ width : 5, height : 4 },
		{ width : 5, height : 4 },
		{ width : 6, height : 4 },
	]

    static var inc = 0 ;
	static var PLAN_BG = inc++;
    static var PLAN_FX = inc++;
	static var PLAN_CARD = inc++;
	static var PLAN_LIFE = inc++;

	static var POINTS = KKApi.aconst([1000,500,400,300,300,200,200,200,100]);
}