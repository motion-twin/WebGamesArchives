#if flash8

enum KKConst {
}

extern class KKApi {

	static function available() : Bool;
	static function isLocal() : Bool;

	static function saveScore( params : Dynamic ) : Void;
	static function setScore( s : KKConst ) : Void;
	static function addScore( s : KKConst ) : KKConst;
	static function getScore() : KKConst;
	static function gameOver( params : Dynamic ) : Void;

	static function const( v : Int ) : KKConst;
	static function aconst( a : Array<Int> ) : Array<KKConst>;
	static function cadd( a : KKConst , b : KKConst ) : KKConst;
	static function cmult( a : KKConst , b : KKConst ) : KKConst;
	static function val( c : KKConst ) : Int;

	static function flagCheater() : Void;
	static function registerButton( but : flash.MovieClip ) : Void;
	static function processing( b : Bool ) : Void;

	static function getPeriod() : Int;

	static function t( s : String ) : String;

}

#else

typedef KKConst = Dynamic; // enum KKConst {}
// typedef KKConst = mt.flash.VarSecure;

class KKApi {
	static var api : Dynamic;

	public static function setApi( a:Dynamic ){ api = a; }

	public inline static function available() : Bool { return api.available(); }
	public inline static function isLocal() : Bool { return api.isLocal(); }

	public inline static function saveScore( params : Dynamic ) : Void { api.saveScore(params); }
	public inline static function setScore( s : KKConst ) : Void { api.setScore(s); }
	public inline static function addScore( s : KKConst ) : KKConst { return api.addScore(s); }
	public inline static function getScore() : KKConst { return api.getScore(); }
	public inline static function gameOver( params : Dynamic ) : Void { api.gameOver(params); }

	public inline static function const( v : Int ) : KKConst { return api.const(v); }
	public inline static function aconst( a : Array<Int> ) : Array<KKConst> { return api.aconst(a); }
	public inline static function cadd( a : KKConst , b : KKConst ) : KKConst { return api.cadd(a,b); }
	public inline static function cmult( a : KKConst , b : KKConst ) : KKConst { return api.cmult(a,b); }
	public inline static function val( c : KKConst ) : Int { return api.val(c); }

	public inline static function flagCheater() : Void { api.flagCheater(); }
	public inline static function registerButton( but:flash.display.Sprite ) : Void { api.registerButton(but); }

	public inline static function getPeriod() : Int { return api.getPeriod(); }

	public inline static function t( s : String ) : String { return api.t(s); }
}

#end