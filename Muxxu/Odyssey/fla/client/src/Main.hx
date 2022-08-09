import mt.bumdum9.Lib;
import Protocole;

class Main {//}
	
	static var mode = 1;
	
	static public var player:mt.player.Core;
	static public var path:String = "";
	static public var ADMIN = false;
	

	static function main() {
		#if dev
		ADMIN = true;
		Gfx.init();
		if ( !Folk.FAKE ) player = new mt.player.Core();
		
		initHint(flash.Lib.current);
		
		switch(mode) {
			case 0 :
				var a = [];
				for ( i in 0...1 ) 	a.push( Hero.getRandomBuild(Celeide,20) );
				var game = new Game(Cs.getGameInit(a,[PANTHER, LOST_SOUL]) );
				flash.Lib.current.addChildAt(game, 0);
				
			case 1 :
				new mod.Grid();
		}
		#end
	}
	
	// HINT
	static function initHint(mc:SP){
		var hint = new mt.bumdum9.Hint();
		mc.addChild(hint);
		mt.bumdum9.Hint.ECX = 16;
		mt.bumdum9.Hint.ECY = 16;
		hint.field.embedFonts = true;
		hint.field.defaultTextFormat = new flash.text.TextFormat("nokia", 8, 0x444444);
		hint.filters = [ new flash.filters.DropShadowFilter(2, 45, 0, 0.5)];
		return hint;
	}
	
	// LOG
	static var fieldLog:TF;
	public static function log(str:String) {
		if ( fieldLog == null ) {
			fieldLog = Cs.getField(0x888888, 8);
			fieldLog.multiline = fieldLog.wordWrap = true;
			fieldLog.width = 400;
			fieldLog.height = 600;
			fieldLog.x = Cs.mcw + 2;
			flash.Lib.current.addChild(fieldLog);
			
		}
		
		fieldLog.htmlText += str + "<br/>";
		fieldLog.scrollH = fieldLog.maxScrollH;
	}
	
	//
	public static var PHASE = 0;
	public static function startGame( str : String, mc : SP, save : Bool -> String -> Void, tip : Null<String> -> Void ) {
		PHASE = 0;
		if( Gfx.icons == null ) Gfx.init();
		PHASE++;
		if( player == null ) player = new mt.player.Core();
		PHASE++;
		initHint(mc);
		PHASE++;
		var init : GameInit = haxe.Unserializer.run(str);
		PHASE++;
		var game = new Game(init);
		PHASE++;
		game.showExternalTips = tip;
		game.hideExternalTips = callback(tip, null);
		game.onFinish = function(gc:GameClose) {
			var s = new haxe.Serializer();
			s.useEnumIndex = true;
			s.serialize(gc);
			save(gc._w, s.toString());
			game.kill();
			Game.me = null;
		};
		mc.addChildAt(game, 0);
		PHASE++;
	}
	
	//
	public static function isRefillable() {
		if( Game.me == null ) return false;
		return Game.me.isRefillable();
	}
	public static function refill() {
		Game.me.waitRefill = true;
	}
	public static function isMyTurn() {
		if( Game.me == null ) return false;
		return Game.me.active;
	}
	
//{
}