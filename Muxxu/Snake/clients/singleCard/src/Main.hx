import Protocole;
import mt.bumdum9.Lib;


class Main{//}
	
	public static var root:MC;
	public static var mcw = 300;
	public static var mch = 120;
	public static var domain : String ;
	public static var data : _DataCollection ;
	
	static function main() {
		/*if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;*/


		Codec.VERSION = Data.CODEC_VERSION ;
		Lang.init();
		
		// PARAMS
		var params = flash.Lib.current.loaderInfo.parameters;
		domain = Reflect.field(flash.Lib.current.loaderInfo.parameters, "dom") ;
		
		// CONTIENT NULL MAIS DOIT ETRE DESERIALIZE POUR INIT
		//data = Codec.getData("data");
		
		// DEFAULT
		/*if( data == cast 1586 ) {
			
		}*/

		// GFX
		Gfx.init();
		GfxCard.initStore();
		
		//
		var card = new GfxCard(2);

		var d = Reflect.field(flash.Lib.current.loaderInfo.parameters, "d") ; //for test : 061252e61e9a82688c7dd388ecea2893
		if (d == null)
			return ;
		
		var cd = getCardFromData(d) ;

		card.setType(cd) ;
		card.coef = 0.25;
		card.majSprite();
		flash.Lib.current.addChild(card);
		
		card.scaleX  = card.scaleY = 2;
		card.x = GfxCard.WIDTH;
		card.y = GfxCard.HEIGHT;
		
	}

	static public function getField(color=0xFFFFFF,size=10,align=0,font="04b03") {
		var field = new flash.text.TextField();
		field.selectable = true;
		field.embedFonts = true;
		field.gridFitType = flash.text.GridFitType.PIXEL;
		var tf = field.getTextFormat();
		tf.color = color;
		tf.font = font;
		tf.size = size;
		tf.align = [flash.text.TextFormatAlign.LEFT, flash.text.TextFormatAlign.CENTER, flash.text.TextFormatAlign.RIGHT][align + 1];
		field.defaultTextFormat = tf;
		field.selectable = false;
		return field;

	}
	
	static public function getEnum<T>(en:Enum<T>,n:Int):T {
			return Type.createEnum(en, Type.getEnumConstructs(en)[n] );
	}
	
	static public function getLoadingBox() {
		
		var box = new pix.Sprite();
		box.setAnim( Gfx.main.getAnim("loading_bar") );
		
		var f = Snk.getField(0xFFFFFF, 8, -1, "nokia");
		f.text = Lang.LOADING;
		f.width = f.textWidth + 3;
		f.x = -Std.int(f.width * 0.5);
		f.y = - 15;
		box.addChild(f);
		
		return box;
		
	}


	static public function getCardFromData(d : String) : _CardType {
		var i = 0 ;
		for (j in 0... Data.TEXT.length) {
			if (Data.TEXT[j].desc == null)
				break ;
			i++ ;
		}

		while(i >= 0) {
			i-- ;
			//var infos = Data.TEXT[i] ;
			if (haxe.Md5.encode(Std.string(i) + "#" + Std.string(Data.CARDS[i].mojo) + "#" + Std.string(i)) != d)
				continue ;
			return Type.createEnumIndex(_CardType, i) ;
		}
		return null ;
	}

//{
}












