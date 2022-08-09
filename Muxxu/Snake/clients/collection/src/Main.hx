import Protocole;
import mt.bumdum9.Lib;


class Main{//}
	
	public static var root:flash.display.MovieClip;
	public static var price:String;
	public static var mcw = 300;
	public static var mch = 120;
	public static var domain : String ;
	public static var data : _DataCollection ;
	
	static function main() {
		Codec.VERSION = Data.CODEC_VERSION ;
		Lang.init();
		
		// PARAMS
		var params = flash.Lib.current.loaderInfo.parameters;
		domain = Reflect.field(flash.Lib.current.loaderInfo.parameters, "dom") ;
		
		// CONTIENT NULL MAIS DOIT ETRE DESERIALIZE POUR INIT
		data = Codec.getData("data");
		
		// DEFAULT
		if( data == cast 1586 ) {
			var cons = Type.getEnumConstructs(_CardType);
			data = {
				_priceCard:50,
				_pricePack:460,
				_priceTicket:10,
				_tickets:0,
				_totalTickets:0,
				_cards:[],
				_deal:{ _card:BUCKET, _price:8 },
				_lotteryCard:BUCKET,
				_lotteryWinner:{_name:"bumdum",_url:"http://www.frutiparc.com"},
			}
			
			for( id in 0...100 ) {
				var num = 0;
				for( i in 0...30 ) if( Std.random(10) < 3 ) num++;
				data._cards.push( { _type:Type.createEnum(_CardType, cons[id]),_num:num } );
				
			}
			
		}

		// GFX
		Gfx.init();
		
		//
		var mc = new Collection();
		flash.Lib.current.addChild(mc);
		mc.scaleX  = mc.scaleY = 2;
	}

	static public function getField(color=0xFFFFFF,size=10,align=0,font="04b03") {
		var field = new flash.text.TextField();
		field.selectable = true;
		field.embedFonts = true;
		field.gridFitType = flash.text.GridFitType.PIXEL;
		//field.antiAliasType = flash.text.AntiAliasType.NORMAL;
		var tf = field.getTextFormat();
		tf.color = color;
		tf.font = font;
		tf.size = size;
		tf.align = [flash.text.TextFormatAlign.LEFT, flash.text.TextFormatAlign.CENTER, flash.text.TextFormatAlign.RIGHT][align + 1];
		field.defaultTextFormat = tf;
		field.selectable = false;
		return field;
		
		//flash.text.TextRenderer.setAdvancedAntiAliasingTable("04b03",flash.text.FontStyle.REGULAR,flash.text.TextColorType.LIGHT_COLOR,
		
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
	
	static public function addCard(t:_CardType) {
		var obj = null;
		for( o in data._cards ) {
			if( o._type == t ) {
				obj = o;
				break;
			}
		}
		if( obj == null ) {
			obj = { _type:t, _num:0 };
			data._cards.push(obj);
		}
		obj._num++;
	}
	
//{
}












