import Protocole;
import mt.bumdum9.Lib;


class Main{//}
	
	public static var root:flash.display.MovieClip;
	public static var XMAX = 4;
	public static var YMAX = 2;
	public static var MARGIN = 2;
	public static var domain : String ;

	
	static function main() {
		
		root = new flash.display.MovieClip();
		Codec.VERSION = Data.CODEC_VERSION ;
		Lang.init();
		Gfx.init();
		
		var params = flash.Lib.current.loaderInfo.parameters;
		domain = Reflect.field(flash.Lib.current.loaderInfo.parameters, "dom") ;
		
		var data:_QuestPage;
		if( domain != null ) {
			data = Codec.getData("data");
		}else {
			data = { _list:[] };
			for( i in 0...8 ) {
				var o = { _id:ARROSOIR,_desc:"bonjour",_success:Std.random(2)==0,_visible:Std.random(4)>0};
				data._list.push(o);
			}
		}
		

		var ma = MARGIN;
		var ww = Vig.WIDTH + ma;
		var hh = Vig.HEIGHT + ma;
		var width = ma+ww*XMAX * 2;
		var height = ma + hh * YMAX * 2;
		root.graphics.beginFill(0xFFFFFF);
		root.graphics.drawRect(0, 0, width, height);
		
		for( y in 0...YMAX  ) {
			for( x in 0...XMAX  ) {
				var vig = new Vig(data._list.shift());
				vig.x = MARGIN + x * ww;
				vig.y = MARGIN + y * hh;
				root.addChild(vig);
			}
		}
		
		// SCREEN
		var screen = new pix.Screen(root,width, height, 2);
		flash.Lib.current.addChild(screen);

		// UPDATE
		screen.update();
		
	}

//{
}


class Vig extends flash.display.Sprite {//}
	
	public static var WIDTH = 102;
	public static var HEIGHT = 94;
	public var data:_DataQuest;

	public function new(d) {
		super();
		data = d;

		// BG
		var bg = new pix.Element();
		var bgId = ( data._visible )?0:1;
		bg.drawFrame(Gfx.bg.get(bgId),0,0 );
		addChild(bg);
		
		if( bgId == 0 ) displayInfos();
		
	}
	public function displayInfos() {
		
		// CARD
		var card = new GfxCard();
		card.setType( data._id);
		card.x = WIDTH * 0.5;
		card.y = HEIGHT * 0.5 - 11;
		card.coef = 0.25;
		card.majSprite();
		addChild(card);
		if( data._success ) {
			card.blendMode = flash.display.BlendMode.LAYER;
			card.alpha = 0.25;
		}
		
		// TEXT
		var txt = mt.db.Phoneme.removeAccentsUTF8( data._desc ).toUpperCase();
		
		var f = Snk.getField(0xFFFFFF, 8, -1);
		f.multiline = true;
		f.wordWrap = true;
		f.width = WIDTH;
		f.text = txt;
		f.height = f.textHeight + 4;
		f.x = Std.int((WIDTH-(f.textWidth+3)) * 0.5);
		f.y = HEIGHT - Std.int(12+f.textHeight*0.5);
		addChild(f);
		
		if( !data._success ) return;
		
		f.alpha = 0.5;
		
		// SUCCESS
		var f = Snk.getField(0xFF4444, 8, -1, "nokia");
		f.text = Lang.SUCCESS;
		addChild(f);
		f.x = card.x - (f.textWidth+3)*0.5;
		f.y = card.y-8;
		f.filters = [new flash.filters.GlowFilter(0xFFFFFF,1,2,2,100)];
		
	}


	
	
//{
}










