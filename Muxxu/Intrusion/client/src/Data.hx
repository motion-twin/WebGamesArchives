import Types;

class Data {
	public static inline var WID		= 600;
	public static inline var HEI		= 400;
	public static inline var MATRIX_WID	= 3;

	public static var UNIQ				= 0;

	public static inline var GREEN		= 0xa5f231;
	public static inline var CORRUPT	= 0xFF2709;
	public static inline var RED		= 0xDE2929;
	public static inline var WARNING	= 0xFFDF00;
	public static inline var BLUE		= 0x73BBF7;


	public static var DP_BG			= UNIQ++;
	public static var DP_BG_ITEM	= UNIQ++;
	public static var DP_ITEM		= UNIQ++;
	public static var DP_FS			= UNIQ++;
	public static var DP_FX			= UNIQ++;
	public static var DP_APP		= UNIQ++;
	public static var DP_TOP		= UNIQ++;
	public static var DP_TOPTOP		= UNIQ++;


	public static inline function SECONDS(?n=1.0) {
		return n*32;
	}

//	public inline static function getFraction(rseed:mt.Rand, n, pctMin:Int, pctMax:Int) {
//		return (rseed.random(pctMax-pctMin) + pctMin)/100 * n;
//	}

	public static function spread(seed:Int, total:Int,n:Int, min:Int, ?moves=10, ?movePct=10) : Array<Int> {
		if (n==1) return [total];

		var rseed = newRandSeed(seed);
		var list = new Array();

		// division en N tas équivalents
		var sum = 0;
		for (i in 0...n) {
			list[i] = Math.floor(total/n);
			sum+=list[i];
		}
		while (total>sum) {
			list[rseed.random(list.length)]++;
			sum++;
		}

		// on transvase
		for (i in 0...rseed.random(moves)+1) {
			var from = rseed.random(list.length);
			var to=null;
			do {
				to = rseed.random(list.length);
			} while (to==from);
			var val = Math.ceil(rseed.random(movePct)/100 * list[from]);
			if ( list[from]-val >= min ) {
				list[from]-=val;
				list[to]+=val;
			}
		}

		return list;
	}

	public static function shuffle(seed:Int, list:Array<Dynamic>) {
		if ( list==null || list.length<=1 ) return list;
		var rseed = new mt.Rand(seed);
		var n = Math.ceil( Math.min(list.length,500) );
		for (i in 0...n) {
			var from = rseed.random(list.length);
			var to = rseed.random(list.length);
			while(to==from) {
				to = rseed.random(list.length);
			}
			var tmp = list[from];
			list[from] = list[to];
			list[to] = tmp;
		}
		return list;
	}

	public static function localToGlobal(parent:flash.MovieClip, x:Float, y:Float) {
		var pt = {x:x, y:y};
		while ( parent!=null ) {
			pt.x += parent._x;
			pt.y += parent._y;
			parent = parent._parent;
		}
		return pt;
	}


	public static function newRandSeed(s) {
		var rseed = new mt.Rand(0);
		rseed.initSeed(s);
		return rseed;
	}


	public static function compareStrings(a:String,b:String) {
		var la = a.toLowerCase();
		var lb = b.toLowerCase();
		if (la<lb) return -1;
		if (la>lb) return 1;
		return 0;
	}

	public static function htmlize(str:String) {
		return "<p>"+str.split("\n").join("</p><p>")+"</p>";
	}

	public static function trimSpaces(str:String) {
		return trim(str," ");
	}

	public static function trim(str:String,c:String) {
		while (str.charAt(0)==c ) str = str.substr(1);
		while (str.charAt(str.length-1)==c ) str = str.substr(0,str.length-1);
		return str;
	}

	public static function leadingZeros(n:Int, ?l=2) {
		var s = Std.string(n);
		while (s.length<l)
			s="0"+s;
		return s;
	}

	public static function toIso(x,y,hexWid) {
		var hexHei = hexWid*0.5;
		return {
			x	: x*hexWid*0.5 + y*hexWid*0.5,
			y	: -x*hexHei*0.5 + y*hexHei*0.5,
		}
	}

	public static function zsort(dm:mt.DepthManager, mcList:Array<flash.MovieClip>) {
		mcList.sort( function(a,b) {
			return Std.int(a._y-b._y);
		});
		for (mc in mcList)
			dm.over(mc);
	}

	public static function hasLine(matrix:Array<Array<Bool>>) {
		var wid = matrix.length;
		for (x in 0...wid) {
			if ( isFullCol(matrix,x) )
				return true;
			for (y in 0...wid)
				if ( isFullRow(matrix,y) )
					return true;
		}
		return false;
	}

	static function isFullRow(matrix:Array<Array<Bool>>,y) {
		for (i in 0...matrix.length)
			if ( matrix[i][y]!=true )
				return false;
		return true;
	}

	static function isFullCol(matrix:Array<Array<Bool>>,x) {
		for (i in 0...matrix.length)
			if ( matrix[x][i]!=true )
				return false;
		return true;
	}


//	public static function createCombatProg( fx:CombatFx, power:Int, ?ct=0.0, ?tics=0, ?tt=0.0) : CombatProg {
//		return {
//			fx		: fx,
//			power	: power,
//			ct		: SECONDS(ct),
//			tt		: SECONDS(tt),
//			tics	: tics,
//			timer	: 0.0,
//		}
//	}

}
