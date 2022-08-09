import Protocole;


class Cs implements haxe.Public
{//}
	static var mcw = 400;
	static var mch = 210;

	// DEV
	static var TEST_FRUIT = 		[];
	static var TEST_FRUIT_WITH = 	null;
	static var TEST_BONUS = 		[];

	//static var START_CARDS =  [BLACK_HOLE, MAGIC_POWDER,SQUIRREL];
	static var START_CARDS =  [POO, SQUIRREL, RUNE_BOOST, PIN, HORMONES ];
	
	// GAMEPLAY
	static var MAX_HAND = 	6;
	static var MAX_MOJO = 	6;
	
	static var SNAKE_DEFAULT_LENGTH = 		120;
	static var SNAKE_AUTO_ACC = 			0.3;
	
	static var SNAKE_SPEED = 				1.3;
	static var SNAKE_THRUST = 				2;
	static var SNAKE_SPEED_PENALTY = 		6;
	
	static var SNAKE_TURN_SPEED = 			0.105;
		
	static var FRUIT_TIMER = 				360;
	static var BONUS_TIMER = 				360;
	
	static var FRUTIPOWER_MAX =				100;
	static var FRUTIPOWER_PENALTY =			200;
	
	static var FREQ_FRUIT = 				90;
	static var FREQ_BONUS = 				10000;
	static var TIME_BLINK =					80;
	
	
	//
	static var DEFAULT_KEYS = [65, 90, 69, 82, 84, 89];
	//
	static var PIX = "<font color='#92d930'>.</font>";
	static var PIX2 = "<font color='#52b31e'>.</font>";
	
	
	static function getField(color=0xFFFFFF,size=10,align=0,font="04b03") {
		var field = new flash.text.TextField();
		field.selectable = true;
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
	
	static function getEnum<T>(en:Enum<T>,n:Int):T {
		return Type.createEnum(en, Type.getEnumConstructs(en)[n] );
	}
	
	static function formatTime(time:Float) {
	
		var sec = Std.string(Std.int(time/1000)%60);
		var min = Std.string(Std.int(time / 60000)%60);
		var h = Std.int(time / (60000 * 60));
		
		while(sec.length < 2) sec = "0" + sec;
		while(min.length < 2) min = "0" + min;
		if( h == 0 ) return min + ":" + sec;
		
		var hou = Std.string(h);
		while(hou.length < 2) hou = "0" + hou;
		return hou + ":" + min + ":" + sec;
		
		
	}
	
	static function getLoadingBox():LoadingBox {
		
		var box = new pix.Sprite();
		box.x = Cs.mcw * 0.5;
		box.y = Cs.mch * 0.5;
		box.setAnim( Gfx.main.getAnim("loading_bar") );
	

		var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		f.text = Lang.LOADING;
		f.width = f.textWidth + 3;
		f.x = -Std.int(f.width * 0.5);
		f.y = - 15;
		box.addChild(f);
	
		
		
		return { base:box, field:f, field2:f, n:0 };
		
		
	}
	
	static function getMousePos(mc:flash.display.DisplayObject) {

		var xm:Float = 0;
		var ym:Float = 0;
		
		while( mc != null ) {
			xm += mc.x;
			ym += mc.y;
			mc = mc.parent;
		}
		
		var root = flash.Lib.current;
		xm = -(xm - root.mouseX*0.5);
		ym = -(ym - root.mouseY*0.5);
		
		return { x:xm, y:ym };
	}
	
//{
}








