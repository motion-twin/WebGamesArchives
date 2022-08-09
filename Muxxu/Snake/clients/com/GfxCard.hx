import Protocole;
import mt.bumdum9.Lib;


class GfxArts extends flash.display.BitmapData { }

class GfxCard extends flash.display.Sprite{//}
	
	
	public static var WIDTH = 	43;	//86
	public static var HEIGHT = 	62;	//124
	
	public var type:_CardType;
	public var data:DataCard;
	public var coef:Float;
	public var glowScale:Float;
	
	public var illus:pix.Element;
	var iconFlash:pix.Element;
	var iconFreq:pix.Element;
	public var title:flash.text.TextField;
	var mojo:flash.text.TextField;
	
	public var face:flash.display.Sprite;
	public var back:flash.display.Sprite;
	public var box:flash.display.Sprite;
		
	public function new(gs=1.0) {
		initStore();
		super();
		coef = 0;
		glowScale = gs;
		genSprite();
		setType(ARROSOIR);
		
		
	}
	
	// SPRITE
	public function genSprite() {
		
		var mx  = Std.int(WIDTH * 0.5 );
		var my  = Std.int(HEIGHT * 0.5 );
		
		var textFilter = new flash.filters.GlowFilter(0x553300, 1, 2*glowScale, 2*glowScale, 30);
		var textColor = 0xEEDD88;
		
		// FACE
		face = new flash.display.Sprite();
		illus = new pix.Element();
		illus.setAlign(0, 0);
		//illus.drawFrame(Gfx.arts.get(Type.enumIndex(type)));
		illus.x = Std.int( (WIDTH - illus.width) * 0.5 - mx);
		illus.y = (HEIGHT - illus.height) * 0.5 - my - 1;
		illus.pxx();
		
		iconFlash = new pix.Element();
		iconFlash.drawFrame( Gfx.main.get("icon_flash") );
		iconFlash.x = -13;
		iconFlash.y = HEIGHT * 0.5 - 6;
		
		iconFreq = new pix.Element();
		iconFreq.x = 13;
		iconFreq.y = HEIGHT * 0.5 - 7;
		
		// FACE-MOJO
		var f = Snk.getField(textColor, 8,-1);
		f.width = 12;
		f.x = 3-Std.int(f.width*0.5);
		f.y = HEIGHT*0.5 - 12;
		f.filters = [textFilter];
		mojo = f;
		
		// FACE-TITLE
		title = Snk.getField(textColor, 8,0);
		title.y = - HEIGHT * 0.5;
		title.filters = [textFilter];
		
		//
		var cover = new pix.Element();
		cover.drawFrame( Gfx.main.get(1, "cards"));
		face.addChild(illus);
		face.addChild(cover);
		face.addChild(f);
		face.addChild(title);
		face.addChild(iconFlash);
		face.addChild(iconFreq);
			
		// BACK
		back = new flash.display.Sprite();
		var cover = new pix.Element();
		cover.drawFrame( Gfx.main.get(0, "cards"));
		back.addChild(cover);
		
		
		//
		box = new flash.display.Sprite();
		addChild(box);
		box.addChild(face);
		box.addChild(back);
		
	}
	public function majSprite() {
		
		face.scaleX = Snk.sin(coef * 6.28);
		back.scaleX = -face.scaleX;
		face.visible = face.scaleX > 0;
		back.visible = back.scaleX > 0;
		
		var bright = 120;
		var n = Std.int(Snk.cos(coef * 6.28 ) * bright);
		Col.setColor( face, 0, -n );
		Col.setColor( back, 0, n );
		

	}
	
	// ACTION
	public function setType(t) {
		type = t;
		
		var n = Type.enumIndex(type);
		data = Data.CARDS[n];
		
		
		illus.drawFrame(art.get(n), 0.5, 0.5);
		title.text = Data.TEXT[n].name;
		title.width = Math.min(WIDTH,title.textWidth + 3);
		title.x = -Std.int(title.width * 0.5);
		
		mojo.text = Std.string(data.mojo);
		
		//
		iconFlash.visible = data.multi != null;
		//trace(getFreq(data.freq));
		iconFreq.drawFrame( Gfx.main.get(getFreq(data.freq),"icon_freq") );
		
	}
	function getFreq(str:String) {
		if( str == "C" ) return 0;
		if( str == "U" ) return 1;
		if( str == "R" ) return 2;
		return -1;
	}
	
	
	// KILL
	public function kill() {
		parent.removeChild(this);
	}
	
	//
	var fieldCopies:flash.text.TextField;
	public function displayCopies(n) {
		if( fieldCopies == null ) {
			fieldCopies = Snk.getField(0xFFFFFF, 8, -1, "nokia");
			face.addChild(fieldCopies);
			fieldCopies.filters = [ new flash.filters.GlowFilter(0, 1, 2*glowScale, 2*glowScale, 20)];
			//fieldCopies.x = 9;
			//fieldCopies.y = 20;
			//fieldCopies.x = -18;
			//fieldCopies.y = -23;
			fieldCopies.x = 7;
			fieldCopies.y = 10;
			fieldCopies.width = 20;
			//fieldCopies.blendMode = flash.display.BlendMode.OVERLAY;
		}
		fieldCopies.text = "x" + Std.string(n);
		fieldCopies.x = 10 - Std.int(fieldCopies.textWidth * 0.5);
		fieldCopies.visible = n > 1;
		
	}
	
	// STORES
	static public var art:pix.Store;
	static public function initStore() {
		if( art != null) return;
		/// ARTS ///
		var bmp = new GfxArts(0, 0);
		mt.flash.DecodeBitmap.run(bmp);
		art = new pix.Store(bmp);
		art.addIndex("main");
		
		var ww = 10;
		var hh = Math.ceil(Data.getCardMax() / ww);
		art.slice(0, 0, 37, 43, ww, hh);
		
		
	}
	
	
	

//{
}












