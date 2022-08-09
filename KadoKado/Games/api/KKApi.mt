native class KKApi {

	static function available() : bool;
	static function isLocal() : bool;

	static function saveScore( params : 'a ) : void;
	static function setScore( s : KKConst ) : void;
	static function addScore( s : KKConst ) : KKConst;
	static function getScore() : KKConst;
	static function gameOver( params : 'a ) : void;

	static function const( v : int ) : KKConst;
	static function aconst( a : Array<int> ) : Array<KKConst>;
	static function cadd( a : KKConst , b : KKConst ) : KKConst;
	static function cmult( a : KKConst , b : KKConst ) : KKConst;
	static function val( c : KKConst ) : int;

	static function flagCheater() : void;
	static function registerButton( but : MovieClip ) : void;
	static function processing( flag : bool ) : void;

}
