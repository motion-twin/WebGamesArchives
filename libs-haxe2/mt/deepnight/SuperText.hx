package mt.deepnight;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.Sprite;
import mt.deepnight.Color;


/*
 * USAGE:
 *
 * var stf = new SuperText(0xFFFFFF, "myFont", 8);
 * addChild( stf.wrapper );
 *
 * USAGE 1:
 * stf.registerImage("mana", new ManaIcon());
 * stf.registerImage("gold", new GoldIcon());
 * stf.setText("This spell costs 5{mana} and 100{gold}");
 *
 * USAGE 2:
 * stf.setText("This spell costs 5{} and 100{}", [ new ManaIcon(), new GoldIcon() ] );
 *
 * USAGE 3:
 * SuperText.registerGlobalImage("mana", new ManaIcon());
 * SuperText.registerGlobalImage("gold", new GoldIcon());
 * stf.setText("This spell costs 5{mana} and 100{gold}");
 *
 * COLORS ARE SUPPORTED (both 0x and # formats):
 * stf.setText("You have <font color='0xFFFF00'>100{gold}</font> my friend");
 *
 * NON-BREAKABLE SPACES:
 * stf.setText("Bienvenue_! C'est cool_!");
 *
 * IMPORTANT:
 * stf.disposeImages() should be called when destroying object. The images registered in
 * the SuperText are actually flattened bitmaps.
 * Call SuperText.disposeGlobalImages() to destroy global ones.
 *
 */


 typedef Image = {
	 var bd		: flash.display.BitmapData;
	 var matrix	: flash.geom.Matrix;
 }


class SuperText {
	static var BITMAP_PADDING = 8;
	static var GLOBAL_BANK : Hash<Image> = new Hash();
	
	public var wrapper				: Sprite;
	public var imgWrapper			: Sprite;
	var tf							: TextField;
	var format						: TextFormat;
	var lastText					: Null<String>;
	var lastImages					: Array<flash.display.DisplayObject>;
	public var width(default,null)	: Float;
	public var height(default,null)	: Float;
	public var textWidth(default,null): Float;
	public var textHeight(default,null): Float;
	public var imgOffsetX			: Int;
	public var imgOffsetY			: Int;
	
	public var x(default,setX)		: Int;
	public var y(default,setY)		: Int;
	
	var localBank			: Hash<Image>;
	var boldTag				: {begin:String, end:String};

	
	public function new() {
		lastImages = [];
		localBank = new Hash();
		boldTag = {begin:"<b>", end:"</b>"}
		
		imgOffsetX = imgOffsetY = 0;
		wrapper = new Sprite();
		width = height = 0;
		textWidth = textHeight = 0;
		
		tf = new flash.text.TextField();
		wrapper.addChild(tf);
		tf.textColor = 0xFFFFFF;
		tf.width = 0;
		tf.height = 0;
		tf.multiline = true;
		tf.wordWrap = false;
		tf.mouseEnabled = tf.selectable = false;
		
		setFont(0xFFFFFF);
		
		imgWrapper = new Sprite();
		wrapper.addChild(imgWrapper);
		
		setSize(200,200);
	}
	
	public function enableMouse() {
		wrapper.mouseChildren = wrapper.mouseEnabled = true;
	}
	public function disableMouse() {
		wrapper.mouseChildren = wrapper.mouseEnabled = false;
	}
	
	public function setX(v:Float) {
		x = Std.int(v);
		wrapper.x = x;
		return x;
	}
	
	public function setY(v:Float) {
		y = Std.int(v);
		wrapper.y = y;
		return y;
	}
	
	public function setFont(color:Int, ?name:String, ?size=10) {
		format = new TextFormat(name==null ? "Arial" : name, size);
		format.color = color;
		tf.defaultTextFormat = format;
		tf.embedFonts = name!=null;
		if( lastText!=null )
			setText(lastText, lastImages);
	}
	
	
	/**
		Dispose all images registered in this object (they are actually bitmaps internaly)
	**/
	public function disposeImages() {
		for(inf in localBank)
			inf.bd.dispose();
		localBank = new Hash();
	}
	
	public static function disposeGlobalImages() {
		for(inf in GLOBAL_BANK)
			inf.bd.dispose();
		GLOBAL_BANK = new Hash();
	}
	
	/**
		Register an image for later use in this object:
		registerImage("gold", new Icon());  /  setText("100{gold}");
	**/
	public function registerImage(id:String, img:flash.display.DisplayObject) {
		addToBank(id, img, localBank);
	}
	
	/**
		Register an image for later use in any SuperText:
		registerImage("gold", new Icon());  /  setText("100{gold}");
	**/
	public static function registerGlobalImage(id:String, img:flash.display.DisplayObject) {
		addToBank(id, img, GLOBAL_BANK);
	}
	
	static inline function addToBank(id, img:flash.display.DisplayObject, bank:Hash<Image>) {
		var id = StringTools.trim(id.toLowerCase());
		if( bank.exists(id) )
			bank.get(id).bd.dispose();
		var bmp = mt.deepnight.Lib.flatten(img, BITMAP_PADDING);
		bmp.smoothing = true;
		bmp.pixelSnapping = flash.display.PixelSnapping.NEVER;
		var m = new flash.geom.Matrix();
		m.translate(-BITMAP_PADDING, -BITMAP_PADDING);
		m.scale(img.scaleX, img.scaleY);
		bank.set(id, {bd:bmp.bitmapData, matrix:m});
	}
	
	
	/**
	 * Occurences of "**" in the text will be replaced by this tag:
	 * ex: Hello **world**  ->  Hello <b>world</b>  (default)
	 */
	public function setBoldTag(begin:String, end:String) {
		boldTag.begin = begin;
		boldTag.end = end;
	}
	

	/**
	 * Resize the textfield.
	 */
	public function setSize(w:Float,h:Float, ?redrawText=true) {
		w = Math.max(0,w);
		h = Math.max(0,h);
		width = w;
		height = h;
		tf.width = width;
		tf.height = height;
		
		if( lastText!=null && redrawText )
			_set(lastText,lastImages);
			
		//#if debug
		//wrapper.graphics.lineStyle(1, 0xFFFF00, 0.25);
		//wrapper.graphics.drawRect(0,0,wid,hei);
		//#end
	}
	
	/**
	 * Resize the textfield to its CURRENT content.
	 */
	public inline function autoResize() {
		setSize(tf.textWidth+4, tf.textHeight+4, false);
	}
	
	/**
	 * USAGE 1: setText("Costs 100{gold}");
	 * USAGE 2: setText("Costs 100{}", [ new GoldIcon() ]);
	 */
	public function setText(txt:String, ?images:Array<flash.display.DisplayObject>, ?fitSizeToContent=false) {
		if( images==null )
			images = [];
		_set(txt, images);
		if( fitSizeToContent )
			autoResize();
	}
	
	/**
	 * Clear the textfield content
	 */
	public function clear(?wid:Float, ?hei:Float) {
		#if debug
		wrapper.graphics.clear();
		#end
		
		lastText = null;
		lastImages = [];
		tf.htmlText = "";
		if( wid!=null && hei!=null )
			setSize(wid, hei);
		
		#if flash11
		imgWrapper.removeChildren();
		#else
		while( imgWrapper.numChildren>0 )
			imgWrapper.removeChildAt(0);
		#end
	}
	
	
	function error(msg:String, ?critical=false) {
		//trace("ERROR(SuperText): "+msg+"    txt="+txt);
		if( critical )
			throw msg;
	}
	
	
	function _set(txt:String, images:Array<flash.display.DisplayObject>) {
		clear();
		lastText = txt;
		lastImages = images;
		
		// Special tags
		txt = Lib.replaceTag(txt, "**", boldTag.begin, boldTag.end);
		
		// Automaticaly add unbreakable spaces (FR)
		for( c in ["!","?",":"] )
			txt = StringTools.replace(txt, " "+c, "_"+c);
		
		// Supports both 0xRRGGBB and #RRGGBB color codes
		var r = ~/0x([0-9A-F]+)/gi;
		txt = r.replace(txt, "#$1");
		
		var padChar = " ";
		tf.htmlText = padChar;
		var bounds = tf.getCharBoundaries(0);
		if( bounds==null ) {
			error("font doesn't support SPACE character o_O", true);
			return;
		}
		var padSize = bounds.width;
		tf.htmlText = txt;
		
		var idx = 0;
		var htmlTags : Array<{raw:String, pos:Int}> = [];
		var images = images.copy();
		var lastSecIdx = 0;
		var lastWordWrap = 0;
		var imgAnchors : Array<{img:flash.display.DisplayObject, idx:Int, slotWid:Float}> = [];
		while( idx<txt.length ) {
			var c = txt.charAt(idx);
			
			if( c==" " || c=="-" )
				lastSecIdx = idx;
			
			if( c=="_" )
				txt = txt.substr(0,idx) + " " + txt.substr(idx+1);
				
			if( c=="\n" )
				lastWordWrap = idx;
				
			// Manual word-wrap
			var bounds = tf.getCharBoundaries(idx);
			if( idx!=lastWordWrap && bounds!=null && bounds.x+bounds.width>=width ) {
				lastWordWrap = idx;
				txt = txt.substr(0,lastSecIdx) + "\n" + txt.substr(lastSecIdx+1);
				tf.htmlText = txt;
				continue;
			}

			if( c=="<" ) {
				// Found an HTML tag
				var end = txt.indexOf(">", idx) + 1;
				var raw = txt.substr(idx, end-idx);
				htmlTags.push({
					raw		: raw,
					pos		: idx,
				});
				txt = txt.substr(0,idx) + txt.substr(end);
				continue;
			}
			
			if( c=="{" ) {
				// Found an IMAGE
				var b = idx;
				var e = txt.indexOf("}", b);
				var k = StringTools.trim(txt.substr(b+1, e-b-1).toLowerCase());
				
				// Gets actual image
				var img : flash.display.DisplayObject;
				var imgWid = 0.;
				if( k.length==0 ) {
					if( images.length==0 ) {
						error("too many image references in text");
						idx++;
						continue;
					}
					else {
						img = images.shift();
						img.x = -BITMAP_PADDING;
						img.y = -BITMAP_PADDING;
						imgWid = img.width;
					}
				}
				else {
					if( localBank.exists(k) ) {
						var inf = localBank.get(k);
						img = new flash.display.Bitmap(inf.bd);
						img.transform.matrix = inf.matrix.clone();
						imgWid = img.width - BITMAP_PADDING*2*img.scaleX;
					}
					else if( GLOBAL_BANK.exists(k) ) {
						var inf = GLOBAL_BANK.get(k);
						img = new flash.display.Bitmap(inf.bd);
						img.transform.matrix = inf.matrix.clone();
						imgWid = img.width - BITMAP_PADDING*2*img.scaleX;
					}
					else {
						error("unknown image "+k);
						idx++;
						continue;
					}
				}
				
				// Insert placeholder characters
				var padString = "";
				var n = Math.ceil(imgWid/padSize);
				for(i in 0...n)
					padString += padChar;
				var before = txt.substr(0,b);
				var after = padString + txt.substr(e+1);
				tf.htmlText = txt = before+after;
				
				// Inserts image
				imgAnchors.push({ img:img, idx:idx, slotWid:padSize*n });
				
				idx+=padString.length-1;
			}
			idx++;
		}

		
		// Put HTML tags back in the flow
		var offset = 0;
		for(t in htmlTags) {
			txt = txt.substr(0,t.pos+offset) + t.raw + txt.substr(t.pos+offset);
			offset+=t.raw.length;
		}
		tf.htmlText = txt;
		
		
		// Attach images
		for(inf in imgAnchors) {
			var bounds = tf.getCharBoundaries(inf.idx);
			if( bounds==null )
				error("no bounds for char '"+tf.text.charAt(inf.idx)+"' @ "+inf.idx);
			else {
				//#if debug
				//wrapper.graphics.lineStyle(1,0x00FF00,0.7);
				//wrapper.graphics.drawRect(bounds.x, bounds.y, inf.slotWid, bounds.height);
				//#end
				imgWrapper.addChild(inf.img);
				var imgWid = inf.img.width - BITMAP_PADDING*2*inf.img.scaleX;
				var imgHei = inf.img.height - BITMAP_PADDING*2*inf.img.scaleY;
				inf.img.x += Math.round( bounds.x + inf.slotWid*0.5 - imgWid*0.5   );
				inf.img.y += Math.round( bounds.y + bounds.height*0.5 - imgHei*0.5   );
			}
		}
		
		textWidth = tf.textWidth;
		textHeight = tf.textHeight;
	}
}