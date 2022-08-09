import Protocole;
import mt.bumdum9.Lib;

class Cs implements haxe.Public{//}
	
	// DEV
	#if dev
	static var TEST_GAMES = [] ;		//8, 36, 84
	static var TEST_GAME_SWAP:Null<Int> = null;
	static var TEST_DIF = 0;
	static var TEST_LAG = 50;

	
	static var FORCE_REWARD = null;//Item(Shoes);
	static var FORCE_MONSTER:Null<Int> = null;
	//static var START_ITEMS = [Voodoo_Mask,Clover];
	static var START_ITEMS = [Rune_0, Rune_1, Rune_2, Rune_3, Rune_4, Rune_5, Rune_6, MagicRing, ChromaX, Voodoo_Mask ];
	static var FORCE_HEARTS:Null<Int> = 40;
	static var CARTRIDGES = [0,1,2,3,4];

	static var NO_MONSTER = false;
	//static var TELEPORT = null;
	//static var TELEPORT = {_x:0,_y:66};
	static var TELEPORT = {_x:59,_y:60};
	#end
	
	//
	static var mcw = 400;
	static var mch = 400;
	static var mcrh = 436;
	
	static var omcw = 240;
	static var omch = 240;

	static var DIR = [[1, 0], [0, 1], [ -1, 0], [0, -1]];
	static var DDIR = [[1, 0], [1, 1], [0, 1], [ -1, 1], [ -1, 0], [ -1, -1], [0, -1], [1, -1]];
	static var GDIR = [[1, 1],[ -1, 1],[ -1, -1], [1, -1]];
	
	static function getRandRep(n):Array<Float>{
		var list:Array<Float> = [];
		var sum = 0;
		for(i in 0...n){
			var p = Std.random(100);
			list[i] = p;
			sum += p;
		}
		var rep = [];
		for( i in 0...n ){
			var p = list[i];
			list[i] = p/sum;
		}

		return list;
	}
	
	#if flash
	static function ySort(a:flash.display.MovieClip,b:flash.display.MovieClip){
		if(a.y<b.y)return-1;
		return 1;
	}

	static function getField(color=0xFFFFFF,size=10,align=0,font="04b03") {
		var field = new flash.text.TextField();
		field.selectable = false;
		field.embedFonts = true;
		//field.gridFitType = flash.text.GridFitType.PIXEL;
		//field.antiAliasType = flash.text.AntiAliasType.NORMAL;
		var tf = field.getTextFormat();
		tf.color = color;
		tf.font = font;
		tf.size = size;
		tf.align = [flash.text.TextFormatAlign.LEFT, flash.text.TextFormatAlign.CENTER, flash.text.TextFormatAlign.RIGHT][align + 1];
		field.defaultTextFormat = tf;
		return field;
		
		//flash.text.TextRenderer.setAdvancedAntiAliasingTable("04b03",flash.text.FontStyle.REGULAR,flash.text.TextColorType.LIGHT_COLOR,
		
	}
	
#end

	static function getDir(sx,sy,ex,ey) {
		var dx = ex - sx;
		var dy = ey - sy;
		dx = Std.int(Num.hMod(dx, WorldData.me.size>>1));
		dy = Std.int(Num.hMod(dy, WorldData.me.size>>1));
		var di = 0;
		for( d in DIR ) {
			if( dx == d[0] && dy == d[1] ) return di;
			di++;
		}
		return -1;
	}
	
	static function getAngleDir(a:Float) {
		for( di in 0...4 ) {
			var da = Num.hMod(a - di * 1.57, 3.14);
			if( Math.abs(da) < 0.785 ) 	return di;
		}
		return -1;
	}
	
	
//{
}


// TODO : voleur d'item













