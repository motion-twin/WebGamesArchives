import Protocole;
import mt.bumdum9.Lib;


class Main{//}
	
	public static var root:flash.display.MovieClip;
	public static var price:String;
	public static var mcw = 300;
	public static var mch = 120;
	public static var domain : String ;
	
	static function main() {
		
		Data.init();
		
		// PARAMS
		var params = flash.Lib.current.loaderInfo.parameters;
		price  = Reflect.field(params, "price");
		domain = Reflect.field(flash.Lib.current.loaderInfo.parameters, "dom") ;
		
		// CONTIENT NULL MAIS DOIT ETRE DESERIALIZE POUR INIT
		var data = Codec.getData("data");


		// DEFAULT
		if( price == null ) {
			price = "99";
		}

		// GFX
		Gfx.init();
		
		
		new CardRandomizer();
	
		
	}

	static public function getField(color=0xFFFFFF,size=10,align=0,font="04b03") {
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
	
	static public function getEnum<T>(en:Enum<T>,n:Int):T {
			return Type.createEnum(en, Type.getEnumConstructs(en)[n] );
	}
	

	static public function getMousePos(mc:flash.display.DisplayObject) {

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












