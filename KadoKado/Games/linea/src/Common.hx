/*
*/

import mt.flash.Volatile;
import flash.MovieClip;
import mt.bumdum.Lib;


class Const {
	public static var inc = 0;
	public static var DP_BG	 = ++inc;
	public static var DP_BMP	 = ++inc;
	public static var DP_UNDER	 = ++inc;
	public static var DP_OBJECTS = ++inc;
	public static var DP_PERLIN = ++inc;
	public static var DP_BONUS = ++inc;
	public static var DP_DOT = ++inc;
	public static var DP_UI = ++inc;

	public static var FRAME_RATE = 40;
	public static var MARGIN = 22;
	public static var XMARGIN = 10;

	public static var LINE_BONUS = KKApi.const( 5 );
	public static var BASE_SCORE = KKApi.const( 2000 );
	public static var ADDDECSPEED = KKApi.const( 1 );
	public static var ADDSPEED = KKApi.const( 1 );
	public static var SPEED = KKApi.const( 50 );
	public static var BASESPEED = KKApi.const( 40 );
	public static var VSCROLL = KKApi.const( 1 );
	public static var BACKSPEED = KKApi.const( 5 );
	public static var MINSPEED = KKApi.const( KKApi.val( BASESPEED ) - 20 );
	public static var CAMPER = 300;
	public static var DIF = KKApi.const( 1 );
	public static var ADDDIF = KKApi.const( 1 );
	public static var BONUS_COMBO = KKApi.const( 12000 );

	public static var BONUS_GLOW = 20;

	public static var BASE_DOT_UP_SPEED = KKApi.const( -30 );
	public static var BASE_DOT_DOWN_SPEED = KKApi.const( 30 );
	public static var BASE_DOT_LEFT_SPEED = KKApi.const( -20 );
	public static var BASE_DOT_RIGHT_SPEED = KKApi.const( 20 );

	public static var DOT_X_SPEED = 2;
	public static var DOT_Y_SPEED = 0;
	public static var WIDTH = 600;
	public static var HEIGHT = 300;
	public static var START = 50;
	public static var DOT_START_POS = 150;
	public static var MAINCYCLE = KKApi.const( 800 );

	public static var OCYCLE = KKApi.const( 10 );
	public static var MINADD = KKApi.const( 250 );
	public static var MAXADD = KKApi.const( 50 );

	public static var BONUSX2_THRESHOLD = KKApi.const( 100 );
	public static var BONUSX2 = KKApi.const( 2 );
	public static var BONUSX3_THRESHOLD = KKApi.const( 175 );
	public static var BONUSX3 = KKApi.const( 3 );
	public static var BONUSX4_THRESHOLD = KKApi.const( 250 );
	public static var BONUSX4 = KKApi.const( 8 );
	public static var KEYPRESSED = KKApi.const( 8 );

	public static var DOTCOLORS = [ 
//										[0xCF0226,0x237ABF,0x2CB431, 0xF5D300],
//										[Col.rgb2Hex( 238,156,0),Col.rgb2Hex( 233,113,23),Col.rgb2Hex( 223,0,41),Col.rgb2Hex(0,170,189)],
										//[Col.rgb2Hex( 128,124,171),Col.rgb2Hex( 93,53,121),Col.rgb2Hex( 108,194,175),Col.rgb2Hex(79,123,138)],
										[Col.rgb2Hex( 125,198,34),Col.rgb2Hex( 0,170,189),Col.rgb2Hex( 243,194,0),Col.rgb2Hex(226,0,120)],
										[Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 44,180,49),Col.rgb2Hex( 150,129,183),Col.rgb2Hex(207,2,38)],
										[Col.rgb2Hex( 191,177,211),Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 249,244,0),Col.rgb2Hex(191,2,34)],
										[Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 241,175,0),Col.rgb2Hex(207,2,38)],
										[Col.rgb2Hex( 0,177,174),Col.rgb2Hex( 94,189,71),Col.rgb2Hex( 212,85,33),Col.rgb2Hex(254,248,134)],
										[Col.rgb2Hex( 112,199,212),Col.rgb2Hex( 255,213,114),Col.rgb2Hex( 250,114,54),Col.rgb2Hex(205,208,10)],
										[Col.rgb2Hex( 220,151,161),Col.rgb2Hex( 197,107,35),Col.rgb2Hex( 161,17,53),Col.rgb2Hex(163,47,117)],
										//[Col.rgb2Hex( 230,205,122),Col.rgb2Hex( 75,121,123),Col.rgb2Hex( 113,68,62),Col.rgb2Hex(182,102,72)],
//										[Col.rgb2Hex( 181,156,30),Col.rgb2Hex( 0,166,173),Col.rgb2Hex( 140,96,45),Col.rgb2Hex(41,78,107)],
										//[Col.rgb2Hex( 202,179,10),Col.rgb2Hex( 164,150,96),Col.rgb2Hex( 177,0,93),Col.rgb2Hex(37,44,88)],
//										[Col.rgb2Hex( 0,59,34),Col.rgb2Hex( 37,44,88),Col.rgb2Hex( 190,17,40),Col.rgb2Hex(198,126,31)],
										//[Col.rgb2Hex( 202,197,10),Col.rgb2Hex( 0,166,173),Col.rgb2Hex( 43,94,54),Col.rgb2Hex(190,17,40)],
									];
	public static var OBJECTS_COLOR = [
//										[0xCF0226,0x237ABF,0x2CB431, 0xF5D300, 0xFFFFFF],
//										[Col.rgb2Hex( 238,156,0),Col.rgb2Hex( 233,113,23),Col.rgb2Hex( 223,0,41),Col.rgb2Hex(0,170,189), 0xFFFFFF],
										//[Col.rgb2Hex( 128,124,171),Col.rgb2Hex( 93,53,121),Col.rgb2Hex( 108,194,175),Col.rgb2Hex(79,123,138), 0xFFFFFF],
										[Col.rgb2Hex( 125,198,34),Col.rgb2Hex( 0,170,189),Col.rgb2Hex( 243,194,0),Col.rgb2Hex(226,0,120), 0xFFFFFF],
										[Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 44,180,49),Col.rgb2Hex( 150,129,183),Col.rgb2Hex(207,2,38), 0xFFFFFF],
										[Col.rgb2Hex( 191,177,211),Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 249,244,0),Col.rgb2Hex(191,2,34), 0xFFFFFF],
										[Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 241,175,0),Col.rgb2Hex(207,2,38), 0xFFFFFF],
										[Col.rgb2Hex( 0,177,174),Col.rgb2Hex( 94,189,71),Col.rgb2Hex( 212,85,33),Col.rgb2Hex(254,248,134), 0xFFFFFF],
										[Col.rgb2Hex( 112,199,212),Col.rgb2Hex( 255,213,114),Col.rgb2Hex( 250,114,54),Col.rgb2Hex(205,208,10), 0xFFFFFF],
										[Col.rgb2Hex( 220,151,161),Col.rgb2Hex( 197,107,35),Col.rgb2Hex( 161,17,53),Col.rgb2Hex(163,47,117), 0xFFFFFF],
										//[Col.rgb2Hex( 230,205,122),Col.rgb2Hex( 75,121,123),Col.rgb2Hex( 113,68,62),Col.rgb2Hex(182,102,72), 0xFFFFFF],
//										[Col.rgb2Hex( 181,156,30),Col.rgb2Hex( 0,166,173),Col.rgb2Hex( 140,96,45),Col.rgb2Hex(41,78,107), 0xFFFFFF],
										//[Col.rgb2Hex( 202,179,10),Col.rgb2Hex( 164,150,96),Col.rgb2Hex( 177,0,93),Col.rgb2Hex(37,44,88), 0xFFFFFF],
//										[Col.rgb2Hex( 0,59,34),Col.rgb2Hex( 37,44,88),Col.rgb2Hex( 190,17,40),Col.rgb2Hex(198,126,31), 0xFFFFFF],
										//[Col.rgb2Hex( 202,197,10),Col.rgb2Hex( 0,166,173),Col.rgb2Hex( 43,94,54),Col.rgb2Hex(190,17,40), 0xFFFFFF],
									];

}
