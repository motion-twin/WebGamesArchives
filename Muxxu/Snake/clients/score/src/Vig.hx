import Protocole;
import mt.bumdum9.Lib;

class Vig extends flash.display.Sprite {//}
	public static var WIDTH = 280;
	public static var HEIGHT = 22;
	var replayId:Int;
	var dm :mt.DepthManager;
	var score:_ScoreData;
	var vx:Int;
	
	public function new(data:_PlayerScore, sid:Int, pos ) {
		score = data._score[sid];
		replayId = score._replayId;
		super();
		
		// ROOT
		Main.root.addChild(this);
		dm = new mt.DepthManager(this);
		//this.scaleX = this.scaleY = 2;
		
		// BG
		var bg = new pix.Sprite();
		bg.drawFrame(Gfx.bg.get(0),0,0);
		dm.add(bg, 0);
		
		// POS
		var num = getField(1,-1, 8,"nokia");
		num.x = 0;
		num.y = 5;
		num.text = Std.string(pos + 1);
		//if( Inter.me.activeSection == SS_ARCHIVE ) num.text = "av.h";
		num.width = num.textWidth + 3;
		num.x = 9 - Std.int(num.width * 0.5);
		
		
		// NAME
		var f = getField(1,-1);
		f.x = 40;
		f.y = 0;
		f.text = data._name;
		f.width = 100;
		if( data._name == Inter.me.data._me && Inter.me.activeSection != SS_ARCHIVE ) new mt.fx.Blink(f,-1,12,4);
		
		// SCORE
		var f = getField(0,-1,8,"nokia");
		f.x = 40;
		f.y = 9;
		f.text = Std.string(score._score);
		f.width = 100;
		//if( data._name == Inter.me.data._me ) new mt.fx.Blink(f,-1,8,2);
		//if( data._name == Inter.me.data._me ) new mt.fx.Rainbow(f);
		
		
		
		// AVATAR
		if( data._avatar != null ) load(data._avatar);
		
		// CARD
		var ww = 20;
		var hh = 22;
		vx = Vig.WIDTH - (ww + 2) * 7;
		var x = vx;
		for( i in 0...6 ) {
		
			if( i < score._cards.length ){
				var type = score._cards[i];
				var sp = new pix.Sprite();
				sp.drawFrame(Gfx.arts.get(Type.enumIndex(type)), 0, 0);
				
				var bmp = new flash.display.Bitmap( new flash.display.BitmapData(ww, hh, false, 0xFF0000) );
				dm.add(bmp, 1);
				bmp.x = x;
				var m = new flash.geom.Matrix();
				m.translate( -9, -10);
				bmp.bitmapData.draw(sp, m);
				Gfx.bg.get(3).drawAt(bmp.bitmapData, 0, 0);
			}else {
				var p = new pix.Element();
				p.drawFrame( Gfx.bg.get(4), 0, 0);
				dm.add(p, 1);
				p.x = x;
			}
			
			//
			x += (ww+2);
			
		}
		
		//BUT
		var a  = [];
		for( i in 0...2 ) a.push( Gfx.bg.get(i,"but_replay") );
		var b = new ButPix(replay, a);
		b.x = WIDTH - 11;
		b.y = 11;
		dm.add(b, 1);
		Main.buts.push(b);
		
		//
		//setPrize(0);
		
		
	}
	function replay() {
		var url = new flash.net.URLRequest( Main.domain + "/game/replay?id=" + replayId );
		flash.Lib.getURL(url,"_self");
	}
	
	// LOADING AVATAR
	var loaded:Int;
	var fdl:flash.display.Loader;
	public function load( url ) {
		
		var loadContext = new flash.system.LoaderContext();
		loadContext.checkPolicyFile = true ;
		
		loaded = 0;
		fdl = new flash.display.Loader();
		//fdl.contentLoaderInfo.
		fdl.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, onLoaded );
		fdl.contentLoaderInfo.addEventListener( flash.events.Event.INIT, onLoaded );
		fdl.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, error);
		fdl.load( new flash.net.URLRequest(url), loadContext );
		fdl.x = 19;
		fdl.y = 1;
	
		
		var mask = new pix.Sprite();
		mask.drawFrame(Gfx.bg.get(1),0,0);
		mask.x = fdl.x;
		mask.y = fdl.y;
		dm.add(mask,2);
		
	}
	function error(e) {
		//trace(e);
	}
	function onLoaded(e) {
		loaded++;
		if( loaded == 2 ) {
			dm.add(fdl, 1);
			fdl.width = 20;
			fdl.height = 20;
			Main.screen.update();
			
		}
	}
	
	// FIELD
	public function getField(col=0, align = 0, size = 8, font="04b03") {
		
		var field = new flash.text.TextField();
		field.selectable = false;
		field.embedFonts = true;
		var tf = field.getTextFormat();
		tf.color = [0xFFFFFF,0xc7ff77,0x319202,0xFFDDDD][col];
		tf.font = font;
		tf.size = size;
		tf.align = [flash.text.TextFormatAlign.LEFT, flash.text.TextFormatAlign.CENTER, flash.text.TextFormatAlign.RIGHT][align + 1];
		field.defaultTextFormat = tf;
		dm.add(field, 1);
		return field;
		
	}
	
	//
	public function setPrize(n) {
		var el  = new pix.Element();
		el.drawFrame(Gfx.bg.get(n, "prize"));
		dm.add(el, 1);
		el.x = vx-10;
		el.y = HEIGHT >> 1;
		
	}
	
	//
	public function kill() {
		if( parent != null) parent.removeChild(this);
		
	}
	
	
//{
}












